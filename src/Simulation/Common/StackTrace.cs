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
    [Serializable]
    public class StackFrame
    {
        public readonly ICallable operation;
        public readonly IApplyData argument;

        /// <summary>
        /// The path to the source where operation is defined
        /// </summary>
        public string sourceFile;

        /// <summary>
        /// One based line number in the operation that resulted in failure. Note that for automatically derived Adjoint and Controlled 
        /// variants of the operation, the line always points to the operation declaration
        /// </summary>
        public int failedLineNumber;

        /// <summary>
        /// One based line number where the declaration starts.
        /// </summary>
        public int declarationStartLineNumber;

        /// <summary>
        /// One based line number of the first line after the declaration.
        /// The value -1, if the declaration ends on the last line of the file.
        /// </summary>
        public int declarationEndLineNumber;

        private readonly Lazy<string> pdbFileLocation;

        public StackFrame(ICallable _operation, IApplyData _argument)
        {
            operation = _operation;
            argument = _argument;
            sourceFile = null;
            failedLineNumber = -1;
            declarationStartLineNumber = -1;
            declarationEndLineNumber = -1;
            pdbFileLocation = new Lazy<string>(() => PortablePdbSymbolReader.GetPDBLocation(operation));
        }

        public string GetOperationSourceFromPDB()
        {
            return PortablePDBEmbeddedFilesCache.GetEmbeddedFileRange(
                pdbFileLocation.Value,
                sourceFile,
                declarationStartLineNumber,
                declarationEndLineNumber,
                showLineNumbers: true, markedLine: failedLineNumber);
        }

        public string GetURLFromPDB()
        {
            string result = PortablePDBPathRemappingCache.TryGetFileUrl(pdbFileLocation.Value, sourceFile);
            return PortablePdbSymbolReader.TryFormatGitHubUrl(result, failedLineNumber);
        }

        public override string ToString()
        {
            string location = GetURLFromPDB() ?? $"{sourceFile}:line {failedLineNumber}";
            return $"in {operation.FullName} on {location}";
        }
    }

    public class StackTraceCollector
    {
        private readonly Stack<StackFrame> callStack;
        private System.Diagnostics.StackFrame[] frames = null;
        bool hasFailed = false;

        public StackTraceCollector(SimulatorBase sim)
        {
            sim.OnOperationStart += this.OnOperationStart;
            sim.OnOperationEnd += this.OnOperationEnd;
            sim.OnFail += this.OnFail;
            callStack = new Stack<StackFrame>();
        }

        void OnOperationStart(ICallable callable, IApplyData arg)
        {
            callStack.Push(new StackFrame(callable, arg));
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



        static StackFrame[] PopulateSourceLocations(Stack<StackFrame> qsharpCallStack, System.Diagnostics.StackFrame[] csharpCallStack)
        {
            foreach (StackFrame currentFrame in qsharpCallStack)
            {
                ICallable op = currentFrame.operation.UnwrapCallable();
                object[] locations = op.GetType().GetCustomAttributes(typeof(SourceLocationAttribute), true);
                foreach (object location in locations)
                {
                    SourceLocationAttribute sourceLocation = (location as SourceLocationAttribute);
                    if (sourceLocation != null && sourceLocation.SpecializationKind == op.Variant)
                    {
                        currentFrame.sourceFile = System.IO.Path.GetFullPath(sourceLocation.SourceFile);
                        currentFrame.declarationStartLineNumber = sourceLocation.StartLine; // note that attribute has base 0 line numbers
                        currentFrame.declarationEndLineNumber = sourceLocation.EndLine;
                    }
                }
            }

            StackFrame[] qsharpStackFrames = qsharpCallStack.ToArray();
            int qsharpStackFrameId = 0;
            for (int csharpStackFrameId = 0; csharpStackFrameId < csharpCallStack.Length; ++csharpStackFrameId)
            {
                string fileName = csharpCallStack[csharpStackFrameId].GetFileName();
                if ( fileName != null )
                {
                    fileName = System.IO.Path.GetFullPath(fileName);
                    int failedLineNumber = csharpCallStack[csharpStackFrameId].GetFileLineNumber();
                    StackFrame currentQsharpStackFrame = qsharpStackFrames[qsharpStackFrameId];
                    if (fileName == currentQsharpStackFrame.sourceFile &&
                        currentQsharpStackFrame.declarationStartLineNumber <= failedLineNumber &&
                            (
                                (failedLineNumber < currentQsharpStackFrame.declarationEndLineNumber) ||
                                (currentQsharpStackFrame.declarationEndLineNumber == -1)
                            )
                        )
                    {
                        currentQsharpStackFrame.failedLineNumber = failedLineNumber;
                        qsharpStackFrameId++;
                    }
                }
            }
            return qsharpStackFrames;
        }

        public StackFrame[] CallStack
        {
            get
            {
                return PopulateSourceLocations(callStack, frames);
            }
        }
    }
}
