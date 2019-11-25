// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Simulation.Core;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// Stores information about Q# stack frames. During successful execution keeps track only of Callable and Argument.
    /// When the exception happens, the rest of the information is populated by <see cref="PopulateSourceLocations(Stack{StackFrame}, System.Diagnostics.StackFrame[])"/>
    /// method.
    /// </summary>
    [Serializable]
    public class StackFrame
    {
        /// <summary>
        /// Callable corresponding to the stack frame
        /// </summary>
        public ICallable Callable { get; private set; }
        
        /// <summary>
        /// Arguments passed to the callable in the stack frame
        /// </summary>
        public IApplyData Argument { get; private set; }

        /// <summary>
        /// The path to the source where operation is defined
        /// </summary>
        public string SourceFile { get; private set; }

        /// <summary>
        /// One based line number in the operation that resulted in failure. Note that for automatically derived Adjoint and Controlled 
        /// variants of the operation, the line always points to the operation declaration
        /// </summary>
        public int FailedLineNumber { get; private set; }

        /// <summary>
        /// One based line number where the declaration starts.
        /// </summary>
        public int DeclarationStartLineNumber { get; private set; }

        /// <summary>
        /// One based line number of the first line after the declaration.
        /// The value -1, if the declaration ends on the last line of the file.
        /// </summary>
        public int DeclarationEndLineNumber { get; private set; }

        public StackFrame(ICallable callable, IApplyData argument)
        {
            Callable = callable;
            Argument = argument;
        }

        /// <summary>
        /// Uses PortablePDBs and SourceLink to get the source of failed operation.
        /// </summary>
        public string GetOperationSourceFromPDB()
        {
            string pdbFileLocation = PortablePdbSymbolReader.GetPDBLocation(Callable);
            return PortablePDBEmbeddedFilesCache.GetEmbeddedFileRange(
                pdbFileLocation,
                SourceFile,
                DeclarationStartLineNumber,
                DeclarationEndLineNumber,
                showLineNumbers: true, markedLine: FailedLineNumber);
        }

        /// <summary>
        /// Uses PortablePDBs and SourceLink to get URL for file and line number.
        /// </summary>
        /// <returns></returns>
        public string GetURLFromPDB()
        {
            string pdbFileLocation = PortablePdbSymbolReader.GetPDBLocation(Callable);
            string result = PortablePDBPathRemappingCache.TryGetFileUrl(pdbFileLocation, SourceFile);
            return PortablePdbSymbolReader.TryFormatGitHubUrl(result, FailedLineNumber);
        }

        private const string messageFormat = "{0} on {1}";

        public override string ToString()
        {
            return string.Format(messageFormat, Callable.FullName, $"{SourceFile}:line {FailedLineNumber}");
        }

        /// <summary>
        /// The same as <see cref="ToString"/>, but tries to point to best source location.
        /// If the source is not available on local machine, source location will be replaced 
        /// by URL pointing to GitHub repository.
        /// This is more costly than <see cref="ToString"/> because it checks if source file exists on disk.
        /// If the file does not exist it calls <see cref="GetURLFromPDB"/> to get the URL
        /// which is also more costly than <see cref="ToString"/>.
        /// </summary>
        public virtual string ToStringWithBestSourceLocation()
        {
            string message = ToString();
            if (System.IO.File.Exists(SourceFile))
            {
                return message;
            }
            else
            {
                string url = GetURLFromPDB();
                if (url == null)
                {
                    return message;
                }
                else
                {
                    return string.Format(messageFormat, Callable.FullName, url);
                }
            }
        }

        /// <summary>
        /// Finds correspondence between Q# and C# stack frames and populates Q# stack frame information from C# stack frames
        /// </summary>
        public static StackFrame[] PopulateSourceLocations(Stack<StackFrame> qsharpCallStack, System.Diagnostics.StackFrame[] csharpCallStack)
        {
            foreach (StackFrame currentFrame in qsharpCallStack)
            {
                ICallable op = currentFrame.Callable.UnwrapCallable();
                object[] locations = op.GetType().GetCustomAttributes(typeof(SourceLocationAttribute), true);
                foreach (object location in locations)
                {
                    SourceLocationAttribute sourceLocation = (location as SourceLocationAttribute);
                    if (sourceLocation != null && sourceLocation.SpecializationKind == op.Variant)
                    {
                        currentFrame.SourceFile = System.IO.Path.GetFullPath(sourceLocation.SourceFile);
                        currentFrame.DeclarationStartLineNumber = sourceLocation.StartLine;
                        currentFrame.DeclarationEndLineNumber = sourceLocation.EndLine;
                    }
                }
            }

            StackFrame[] qsharpStackFrames = qsharpCallStack.ToArray();
            int qsharpStackFrameId = 0;
            for (int csharpStackFrameId = 0; csharpStackFrameId < csharpCallStack.Length; ++csharpStackFrameId)
            {
                string fileName = csharpCallStack[csharpStackFrameId].GetFileName();
                if (fileName != null)
                {
                    fileName = System.IO.Path.GetFullPath(fileName);
                    int failedLineNumber = csharpCallStack[csharpStackFrameId].GetFileLineNumber();
                    StackFrame currentQsharpStackFrame = qsharpStackFrames[qsharpStackFrameId];
                    if (fileName == currentQsharpStackFrame.SourceFile &&
                        currentQsharpStackFrame.DeclarationStartLineNumber <= failedLineNumber &&
                            (
                                (failedLineNumber < currentQsharpStackFrame.DeclarationEndLineNumber) ||
                                (currentQsharpStackFrame.DeclarationEndLineNumber == -1)
                            )
                        )
                    {
                        currentQsharpStackFrame.FailedLineNumber = failedLineNumber;
                        qsharpStackFrameId++;
                        if (qsharpStackFrameId == qsharpStackFrames.Length) break;
                    }
                }
            }
            return qsharpStackFrames;
        }
    }

    /// <summary>
    /// Tracks Q# operations call-stack till the first failure resulting in <see cref="SimulatorBase.OnFail"/>
    /// event invocation.  
    /// </summary>
    /// <remarks>
    /// Only Q# operations are tracked and reported in the stack trace. Q# functions or calls from 
    /// classical hosts like C# or Python are not included.
    /// </remarks>
    public class StackTraceCollector : IDisposable
    {
        private readonly Stack<StackFrame> callStack;
        private readonly SimulatorBase sim;
        private System.Diagnostics.StackFrame[] frames = null;
        StackFrame[] stackFramesWithLocations = null;
        bool hasFailed = false;

        public StackTraceCollector(SimulatorBase sim)
        {
            callStack = new Stack<StackFrame>();
            this.sim = sim;

            this.Start();
        }

        private void Start()
        {
            sim.OnOperationStart += this.OnOperationStart;
            sim.OnOperationEnd += this.OnOperationEnd;
            sim.OnFail += this.OnFail;
        }

        private void Stop()
        {
            sim.OnOperationStart -= this.OnOperationStart;
            sim.OnOperationEnd -= this.OnOperationEnd;
            sim.OnFail -= this.OnFail;
        }

        void OnOperationStart(ICallable callable, IApplyData arg)
        {
            if (!hasFailed)
            {
                callStack.Push(new StackFrame(callable, arg));
            }
        }

        void OnOperationEnd(ICallable callable, IApplyData arg)
        {
            if (!hasFailed)
            {
                callStack.Pop();
            }
        }

        void OnFail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionInfo)
        {
            if (!hasFailed)
            {
                hasFailed = true;
            }

            System.Diagnostics.StackTrace stackTrace = new System.Diagnostics.StackTrace(exceptionInfo.SourceException, 0, true);
            System.Diagnostics.StackFrame[] currentFrames = stackTrace.GetFrames();

            if (frames == null)
            {
                frames = currentFrames;
            }
            else
            {
                // When the exception is thrown, OnFail can be called multiple times.
                // With every next call we see bigger part of the call stack, so we save the biggest call stack
                if (currentFrames.Length > frames.Length)
                {
                    Debug.Assert((frames.Length == 0) || (frames[0].ToString() == currentFrames[0].ToString()));
                    frames = currentFrames;
                }
            }
        }

        

        /// <summary>
        /// If failure has happened returns the call-stack at time of failure.
        /// Returns null if the failure has not happened.
        /// </summary>
        public StackFrame[] CallStack
        {
            get
            {
                if (hasFailed)
                {
                    if( stackFramesWithLocations == null )
                    {
                        stackFramesWithLocations = StackFrame.PopulateSourceLocations(callStack, frames);
                    }
                    return stackFramesWithLocations;
                }
                else
                {
                    return null;
                }
            }
        }

        #region IDisposable Support
        private bool disposedValue = false; // To detect redundant calls

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    this.Stop();
                }

                disposedValue = true;
            }
        }

        // This code added to correctly implement the disposable pattern.
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
            Dispose(true);
        }
        #endregion
    }
}
