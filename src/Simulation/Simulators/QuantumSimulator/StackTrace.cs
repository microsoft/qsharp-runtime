// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;
using System.Diagnostics;

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
            string result = PortablePDBSourceLinkInfoCache.TryGetFileUrl(pdbFileLocation, SourceFile);
            return PortablePdbSymbolReader.TryFormatGitHubUrl(result, FailedLineNumber);
        }

        private const string messageFormat = "{0} on {1}";

        public override string ToString()
        {
            return string.Format(messageFormat, Callable.FullName, $"{SourceFile}:line {FailedLineNumber}");
        }

        /// <summary>
        ///     Gets the best possible source location for this stack frame.
        ///     If the source is not available on local machine, the source
        //      location will be replaced by a URL pointing to GitHub repository.
        /// </summary>
        /// <remarks>
        ///     This is more costly than <see cref="SourceFile"/> because it
        ///     checks if source file exists on disk.
        ///     If the file does not exist it calls <see cref="GetURLFromPDB"/> to get the URL
        ///     which is also more costly than <see cref="SourceFile"/>.
        /// </remarks>
        public virtual string GetBestSourceLocation() =>
            System.IO.File.Exists(SourceFile)
            ? SourceFile
            : GetURLFromPDB() ?? SourceFile;

        /// <summary>
        /// The same as <see cref="ToString"/>, but tries to point to best source location.
        /// If the source is not available on local machine, source location will be replaced 
        /// by URL pointing to GitHub repository.
        /// This is more costly than <see cref="ToString"/> because it checks if source file exists on disk.
        /// If the file does not exist it calls <see cref="GetURLFromPDB"/> to get the URL
        /// which is also more costly than <see cref="ToString"/>.
        /// </summary>
        public virtual string ToStringWithBestSourceLocation() =>
            string.Format(messageFormat, Callable.FullName, $"{GetBestSourceLocation()}:line {FailedLineNumber}");

        /// <summary>
        /// Finds correspondence between Q# and C# stack frames and populates Q# stack frame information from C# stack frames
        /// </summary>
        public static StackFrame[] PopulateSourceLocations(Stack<StackFrame> qsharpCallStack, System.Diagnostics.StackFrame[] csharpStackFrames)
        {
            // Populate source location information in QSharp stack from attributes
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
                        break;
                    }
                }
            }

            StackFrame[] qsharpStackFrames = qsharpCallStack.ToArray();
            int currentQSharpFrameIndex = -1;
            int currentCSharpFrameIndex = -1;

            // A set of Q# stack frames is assumed to be a subset of C# stack frames.
            // When a C# stack frame doesn't have enough information to match with corresponding Q# frame
            // this assumption is essentially broken, which results in missing matches.
            System.Diagnostics.StackFrame csharpFrame = GetNextCSharpStackFrame(csharpStackFrames, ref currentCSharpFrameIndex);
            StackFrame qsharpFrame = GetNextQSharpStackFrame(qsharpStackFrames, ref currentQSharpFrameIndex);
            while (csharpFrame != null && qsharpFrame != null)
            {
                if (IsMatch(csharpFrame, qsharpFrame))
                {
                    PopulateQSharpFrameFromCSharpFrame(csharpFrame, qsharpFrame);
                    // Advance to the next Q# stack frame only when it matches C# stack frame.
                    // If corresponding C# stack frame doesn't have enough information to match
                    // this and all subsequent Q# stack frames will not match.
                    qsharpFrame = GetNextQSharpStackFrame(qsharpStackFrames, ref currentQSharpFrameIndex);
                }
                csharpFrame = GetNextCSharpStackFrame(csharpStackFrames, ref currentCSharpFrameIndex);
            }
            return qsharpStackFrames;
        }

        /// <summary>
        /// Return next Q# stack frame that has enough information to match
        /// </summary>
        private static StackFrame GetNextQSharpStackFrame(StackFrame[] qsharpStackFrames, ref int currentFrameIndex)
        {
            if (currentFrameIndex >= qsharpStackFrames.Length)
            {
                return null;
            }
            currentFrameIndex++;
            while (currentFrameIndex < qsharpStackFrames.Length)
            {
                StackFrame currentFrame = qsharpStackFrames[currentFrameIndex];
                if (!string.IsNullOrEmpty(currentFrame.SourceFile))
                {
                    return currentFrame;
                }
                currentFrameIndex++;
            }
            return null;
        }

        /// <summary>
        /// Return next C# stack frame
        /// </summary>
        private static System.Diagnostics.StackFrame GetNextCSharpStackFrame(System.Diagnostics.StackFrame[] csharpStackFrames, ref int currentFrameIndex)
        {
            if (currentFrameIndex >= csharpStackFrames.Length)
            {
                return null;
            }
            currentFrameIndex++;
            if (currentFrameIndex >= csharpStackFrames.Length)
            {
                return null;
            }
            return csharpStackFrames[currentFrameIndex];
        }

        /// <summary>
        /// Check if Q# stack frame and C# stack frame match (refer to the same location in the code)
        /// </summary>
        private static bool IsMatch(System.Diagnostics.StackFrame csharpFrame, StackFrame qsharpFrame)
        {
            string fileName = csharpFrame.GetFileName();
            if (string.IsNullOrEmpty(fileName))
            {
                return false;
            }
            string fullPath = System.IO.Path.GetFullPath(fileName);
            if (fullPath != qsharpFrame.SourceFile)
            {
                return false;
            }
            int failedLineNumber = csharpFrame.GetFileLineNumber();
            if (failedLineNumber < qsharpFrame.DeclarationStartLineNumber)
            {
                return false;
            }
            return
                (failedLineNumber < qsharpFrame.DeclarationEndLineNumber) ||
                (qsharpFrame.DeclarationEndLineNumber == -1);
        }

        /// <summary>
        /// Copy information missing in Q# stack frame from C# stack frame (only FailedLineNumber curently)
        /// </summary>
        private static void PopulateQSharpFrameFromCSharpFrame(System.Diagnostics.StackFrame csharpFrame, StackFrame qsharpFrame)
        {
            qsharpFrame.FailedLineNumber = csharpFrame.GetFileLineNumber();
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
