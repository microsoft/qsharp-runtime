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

        public StackFrame(ICallable _operation, IApplyData _argument)
        {
            operation = _operation;
            argument = _argument;
            sourceFile = null;
            failedLineNumber = -1;
            declarationStartLineNumber = -1;
            declarationEndLineNumber = -1;
        }

        public string GetOperationSourceFromPDB()
        {
            string result = null;
            try
            {
                //TODO:
            }
            catch (Exception)
            {

            }
            return result;
        }

        public string GetURLFromPDB()
        {
            string result = null;
            try
            {
                //TODO:
            }
            catch (Exception)
            {

            }
            return result;
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

        public static ICallable UnwrapCallable(ICallable op)
        {
            ICallable res = op;
            while (res as IWrappedOperation != null)
            {
                res = (res as IWrappedOperation).BaseOperation;
            }
            return res;
        }

        class HalfOpenInterval : IEquatable<HalfOpenInterval>
        {
            public readonly int start;
            public readonly int end;

            public HalfOpenInterval(int start, int end)
            {
                if( start > end ) throw new ArgumentException($"Interval start:{start} must be less or equal to end:{end}.");
                this.start = start;
                this.end = end;
            }

            public override bool Equals(object obj)
            {
                return Equals(obj as HalfOpenInterval);
            }

            public bool Equals(HalfOpenInterval other)
            {
                return other != null &&
                       start == other.start &&
                       end == other.end;
            }

            public override int GetHashCode()
            {
                return HashCode.Combine(start, end);
            }
        }

        class NonOverlappingHalfOpenIntervalSet
        {
            class NonOverlappinIntervalsComparator : IComparer<HalfOpenInterval>
            {
                public int Compare(HalfOpenInterval x, HalfOpenInterval y)
                {
                    if (x.end <= y.start) return -1;
                    if (x.start >= y.end) return 1;
                    if (x.start == y.start && x.end == y.end) return 0;
                    throw new ArgumentException("Compared intervals must be non-overlapping");
                }
            }

            public NonOverlappingHalfOpenIntervalSet(IEnumerable<HalfOpenInterval> inervals)
            {
                throw new NotImplementedException();
            }

            public bool Contains(int value)
            {
                throw new NotImplementedException();
            }
        }

        static void PopulateSourceLocations(Stack<StackFrame> qsharpCallStack, System.Diagnostics.StackFrame[] csharpCallStack)
        {
            // TODO: change logic to check if given location in the known Q# call-stack locations 
            //List<Tuple<string, int>> qsharpSourceLocations = new List<Tuple<string, int>>();
            //foreach (System.Diagnostics.StackFrame csStackFrame in csharpCallStack)
            //{
            //    string fileName = csStackFrame.GetFileName();
            //    if (System.IO.Path.GetExtension(fileName) == ".qs")
            //    {
            //        qsharpSourceLocations.Add(new Tuple<string, int>(fileName, csStackFrame.GetFileLineNumber()));
            //    }
            //}

            //string fileName = System.IO.Path.GetFullPath(qsharpSourceLocations[i].Item1);
            //int failedLineNumber = qsharpSourceLocations[i].Item2;
            //if (fileName == stackFrames[i].sourceFile &&
            //    sourceLocation.StartLine <= failedLineNumber &&
            //    ((failedLineNumber <= sourceLocation.EndLine) || sourceLocation.EndLine == -1))
            //{
            //    stackFrames[i].failedLineNumber = failedLineNumber;
            //}

            Dictionary<string, List<HalfOpenInterval>> sourceLocations = new Dictionary<string, List<HalfOpenInterval>>();
            foreach (StackFrame currentFrame in qsharpCallStack )
            {
                ICallable op = UnwrapCallable(currentFrame.operation);
                object[] locations = op.GetType().GetCustomAttributes(typeof(SourceLocationAttribute), true);
                foreach (object location in locations)
                {
                    SourceLocationAttribute sourceLocation = (location as SourceLocationAttribute);
                    if (sourceLocation != null && sourceLocation.SpecializationKind == op.Variant)
                    {
                        currentFrame.sourceFile = System.IO.Path.GetFullPath(sourceLocation.SourceFile);
                        currentFrame.declarationStartLineNumber = sourceLocation.StartLine + 1; // note that attribute has base 0 line numbers
                        currentFrame.declarationEndLineNumber = sourceLocation.EndLine == -1 ? -1 : sourceLocation.EndLine + 1;

                        List<HalfOpenInterval> intervals = sourceLocations.GetValueOrDefault(currentFrame.sourceFile);
                        HalfOpenInterval currentRange = new HalfOpenInterval(
                            currentFrame.declarationStartLineNumber,
                            currentFrame.declarationEndLineNumber == -1 ? int.MaxValue : currentFrame.declarationEndLineNumber);
                        if (intervals == null)
                        {
                            sourceLocations.Add(currentFrame.sourceFile, new List<HalfOpenInterval>(Enumerable.Repeat(currentRange,1));
                        }
                        else
                        {
                            intervals.Add(currentRange);
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
