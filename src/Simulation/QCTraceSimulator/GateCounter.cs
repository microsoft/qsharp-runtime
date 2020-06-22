// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    [Serializable]
    public class PrimitiveOperationsCounterConfiguration
    {
        public string[] primitiveOperationsNames;
    }

    public class PrimitiveOperationsCounter : IQCTraceSimulatorListener, ICallGraphStatistics
    {
        class OperationCallRecord
        {
            public CallGraphTreeEdge CallEdge;
            public double[] GlobalCountersAtOperationStart;
        }

        private readonly PrimitiveOperationsCounterConfiguration configuration;

        /// <summary>
        /// Number of primitive operations performed since the beginning of the execution.
        /// Double type is used because all the collected statistics are of type double.
        /// </summary>
        private readonly double[] globalCounters;

        private readonly Stack<OperationCallRecord> operationCallStack;

        private readonly int primitiveOperationsCount;

        private readonly HybridStatisticsCollector stats;

        public PrimitiveOperationsCounterConfiguration GetConfigurationCopy() { return Utils.DeepClone(configuration); }
        public IHybridStatisticsCollectorResults Results => stats;

        /// <param name="statisticsToCollect">
        /// Statistics to be collected. If set to null, the
        /// statistics returned by <see cref="StatisticsCollector.DefaultStatistics"/>
        /// are used. </param>
        public PrimitiveOperationsCounter(PrimitiveOperationsCounterConfiguration config, IDoubleStatistic[]  statisticsToCollect = null )
        {
            configuration = Utils.DeepClone(config);
            primitiveOperationsCount = configuration.primitiveOperationsNames.Length;
            globalCounters = new double[primitiveOperationsCount];
            operationCallStack = new Stack<OperationCallRecord>();
            stats = new HybridStatisticsCollector(
                config.primitiveOperationsNames,
                statisticsToCollect ?? StatisticsCollector<CallGraphTreeEdge>.DefaultStatistics()
                );
        }

        private void AddToCallStack(CallGraphTreeEdge callEdge)
        {
            operationCallStack.Push(
                new OperationCallRecord()
                {
                    GlobalCountersAtOperationStart = new double[primitiveOperationsCount],
                    CallEdge = callEdge
                });
            globalCounters.CopyTo(operationCallStack.Peek().GlobalCountersAtOperationStart, 0);
        }

        #region ITracingSimulatorListener implementation
        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnAllocate(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnRelease(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnReturn(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            Debug.Assert(id < primitiveOperationsCount);
            globalCounters[id] += 1.0;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationStart(CallGraphTreeEdge callEdge, object[] qubitsTraceData)
        {
            AddToCallStack(callEdge);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationEnd(CallGraphTreeEdge callEdge, object[] returnedQubitsTraceData)
        {
            OperationCallRecord record = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            stats.AddSample(
                callEdge,
                Utils.ArrayDifference(globalCounters, record.GlobalCountersAtOperationStart)
                );
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public object NewTracingData(long qubitId)
        {
            return null;
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => false;
        #endregion

    }
}
