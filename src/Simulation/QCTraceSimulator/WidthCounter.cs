// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using static System.Math;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{

    /// <summary>
    /// Collects statistics about number of qubits used
    /// </summary>
    public class WidthCounter : ICallGraphStatistics, IQCTraceSimulatorListener
    {
        class OperationCallRecord
        {
            public HashedString OperationName;
            public OperationFunctor Variant;
            public long MaxAllocated; // maximal value of allocatedQubits during the operation execution
            public long InputWidth;
            public long QubitsAllocatedAtStart;
            public long CurrentBorrowWidth;
            public long MaxBorrowed; // maximal value of currentBorrowWidth during the operation execution
        }

        StatisticsCollector<CallGraphEdge> statisticsCollector;
        public IStatisticCollectorResults<CallGraphEdge> Results => statisticsCollector;

        Stack<OperationCallRecord> operationCallStack;

        long allocatedQubits = 0;

        public WidthCounter( IDoubleStatistic[] statisticsToCollect = null )
        {
            statisticsCollector = new StatisticsCollector<CallGraphEdge>(
                Utils.MethodParametersNames(this,"StatisticsRecord"),
                statisticsToCollect ?? StatisticsCollector<CallGraphEdge>.DefaultStatistics()
                );
            operationCallStack = new Stack<OperationCallRecord>();
            AddToCallStack(CallGraphEdge.CallGraphRootHashed, OperationFunctor.Body);
        }

        public static class Metrics
        {
            public const string InputWidth = "InputWidth";
            public const string ExtraWidth = "ExtraWidth";
            public const string ReturnWidth = "ReturnWidth";
            public const string BorrowedWith = "BorrowedWidth";
        }

        public double[] StatisticsRecord( double InputWidth, double ExtraWidth, double ReturnWidth, double BorrowedWidth )
        {
            return new double[] { InputWidth, ExtraWidth, ReturnWidth, BorrowedWidth };
        }

        private void AddToCallStack(HashedString operationName, OperationFunctor variant)
        {
            operationCallStack.Push(
                new OperationCallRecord()
                {
                    OperationName = operationName,
                    QubitsAllocatedAtStart = allocatedQubits,
                    Variant = variant
                });
        }

        #region IQCTraceSimulatorListener implementation
        public object NewTracingData(long qubitId)
        {
            return null;
        }

        public void OnAllocate(object[] qubitsTraceData)
        {
            allocatedQubits += qubitsTraceData.Length;
            OperationCallRecord opRec = operationCallStack.Peek();
            opRec.MaxAllocated = Max(opRec.MaxAllocated, allocatedQubits);
        }

        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated)
        {
            allocatedQubits += newQubitsAllocated;
            OperationCallRecord opRec = operationCallStack.Peek();
            opRec.MaxAllocated = Max(opRec.MaxAllocated, allocatedQubits);
            opRec.CurrentBorrowWidth += qubitsTraceData.Length - newQubitsAllocated ;
            opRec.MaxBorrowed = Max(opRec.MaxBorrowed, opRec.CurrentBorrowWidth);
        }

        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            OperationCallRecord or = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack is empty. This likely caused by unbalanced OnOperationStart/End");
            OperationCallRecord opCaller = operationCallStack.Peek();
            opCaller.MaxAllocated = Max(opCaller.MaxAllocated, or.MaxAllocated);

            double[] statRecord = StatisticsRecord(
                InputWidth : or.InputWidth,
                ExtraWidth : or.MaxAllocated - or.QubitsAllocatedAtStart,
                ReturnWidth : returnedQubitsTraceData.Length,
                BorrowedWidth : or.MaxBorrowed);
            CallGraphEdge callGraphEdge = new CallGraphEdge(or.OperationName,  opCaller.OperationName, or.Variant, opCaller.Variant);

            statisticsCollector.AddSample(callGraphEdge, statRecord);
        }

        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            AddToCallStack(name,variant);
            operationCallStack.Peek().InputWidth = qubitsTraceData.Length;
            operationCallStack.Peek().QubitsAllocatedAtStart = allocatedQubits;
            operationCallStack.Peek().MaxAllocated = allocatedQubits;
        }

        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
        }

        public void OnRelease(object[] qubitsTraceData)
        {
            allocatedQubits -= qubitsTraceData.Length;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnReturn(object[] qubitsTraceData, long qubitsReleased )
        {
            allocatedQubits -= qubitsReleased;
            OperationCallRecord or = operationCallStack.Peek();
            or.CurrentBorrowWidth -= qubitsTraceData.Length - qubitsReleased;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion 
    }
}
