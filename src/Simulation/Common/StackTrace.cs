// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Simulation.Core;

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
        /// Line in the operation that resulted in failure. Note that for automatically derived Adjoint and Controlled 
        /// variants of the operation, the line always points to the operation declaration
        /// </summary>
        public int failedLineNumber;

        public int declarationStartLineNumber;
        public int declarationEndLineNumber;

        public StackFrame(ICallable _operation, IApplyData _argument)
        {
            operation = _operation;
            argument = _argument;
            sourceFile = null;
            failedLineNumber = -1;
            declarationStartLineNumber = -1;
            declarationEndLineNumber = -1;
        }
    }

    public class StackTraceCollector
    {
        private readonly Stack<StackFrame> callStack;
        private System.Diagnostics.StackFrame[] frames = null;
        bool hasNotFailed = true;

        public StackTraceCollector(SimulatorBase sim)
        {
            sim.OnOperationStart += OnOperationStart;
            sim.OnOperationEnd += OnOperationEnd;
            sim.OnFail += OnFail;
            callStack = new Stack<StackFrame>();
        }

        void OnOperationStart(ICallable callable, IApplyData arg)
        {
            callStack.Push(new StackFrame(callable, arg));
        }

        void OnOperationEnd(ICallable callable, IApplyData arg)
        {
            if (hasNotFailed)
            {
                callStack.Pop();
            }
        }

        void OnFail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionInfo)
        {
            if (hasNotFailed)
            {
                hasNotFailed = false;
            }

            System.Diagnostics.StackTrace stackTrace = new System.Diagnostics.StackTrace(exceptionInfo.SourceException, 0, true);
            System.Diagnostics.StackFrame[] currentFrames = stackTrace.GetFrames();

            if (frames == null)
            {
                frames = currentFrames;
            }
            else
            {
                // When the exception is thrown, OnFail can be called mutiple times.
                // With every next call we see bigger part of the call stack, so we save the biggest call stack
                if (currentFrames.Length > frames.Length)
                {
                    frames = currentFrames;
                }
            }
        }

        public static ICallable UnwrapCallable(ICallable op)
        {
            ICallable res = op;
            while (res as IWrappedOperation != null)
            {
                res = (res as IWrappedOperation).BaseOperation;
            }
            return res;
        }

        static void PopulateSourceLocations(Stack<StackFrame> qsharpCallStack, System.Diagnostics.StackFrame[] csharpCallStack)
        {
            List<Tuple<string, int>> qsharpSourceLocations = new List<Tuple<string, int>>();
            foreach (System.Diagnostics.StackFrame csStackFrame in csharpCallStack)
            {
                string fileName = csStackFrame.GetFileName();
                if (System.IO.Path.GetExtension(fileName) == ".qs")
                {
                    qsharpSourceLocations.Add(new Tuple<string, int>(fileName, csStackFrame.GetFileLineNumber()));
                }
            }

            StackFrame[] stackFrames = qsharpCallStack.ToArray();
            for (int i = 0; i < stackFrames.Length; ++i)
            {
                ICallable op = UnwrapCallable(stackFrames[i].operation);
                object[] locations = op.GetType().GetCustomAttributes(typeof(SourceLocationAttribute), true);
                foreach (object location in locations)
                {
                    SourceLocationAttribute sourceLocation = (location as SourceLocationAttribute);
                    if (sourceLocation != null && sourceLocation.SpecializationKind == op.Variant)
                    {
                        stackFrames[i].sourceFile = System.IO.Path.GetFullPath(sourceLocation.SourceFile);
                        stackFrames[i].declarationStartLineNumber = sourceLocation.StartLine;
                        stackFrames[i].declarationEndLineNumber = sourceLocation.EndLine;

                        string fileName = System.IO.Path.GetFullPath(qsharpSourceLocations[i].Item1);
                        int failedLineNumber = qsharpSourceLocations[i].Item2;
                        if (fileName == stackFrames[i].sourceFile &&
                            sourceLocation.StartLine <= failedLineNumber &&
                            ((failedLineNumber <= sourceLocation.EndLine) || sourceLocation.EndLine == -1))
                        {
                            stackFrames[i].failedLineNumber = failedLineNumber;
                        }
                    }
                }
            }
        }

        public Stack<StackFrame> CallStack
        {
            get
            {
                PopulateSourceLocations(callStack, frames);
                return callStack;
            }
        }
    }
}
