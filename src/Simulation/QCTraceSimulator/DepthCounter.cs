// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using static System.Math;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    public class DepthCounter : IQCTraceSimulatorListener, ICallGraphStatistics
    {
        class OperationCallRecord
        {
            public CallGraphTreeEdge callEdge;
            public double MinOperationStartTime;
            public double MaxOperationStartTime;
            public double ReleasedQubitsAvailableTime;
            public double ReturnedQubitsAvailableTime;
            public QubitTimeMetrics[] InputQubitMetrics;
        }

        HybridStatisticsCollector stats;
        Stack<OperationCallRecord> operationCallStack;

        public IHybridStatisticsCollectorResults Results => stats;

        public DepthCounter(IDoubleStatistic[] statisticsToCollect = null)
        {
            stats = new HybridStatisticsCollector(
                Utils.MethodParametersNames(this, "StatisticsRecord"),
                statisticsToCollect ?? StatisticsCollector<CallGraphEdge>.DefaultStatistics()
                );
            operationCallStack = new Stack<OperationCallRecord>();
        }

        public class Metrics
        {
            public const string Depth = "Depth";
            public const string StartTimeDifference = "StartTimeDifference";
        }

        public double[] StatisticsRecord(double Depth, double StartTimeDifference)
        {
            return new double[] { Depth, StartTimeDifference };
        }

        #region IQCTraceSimulatorListener implementation 
        public object NewTracingData(long qubitId)
        {
            return new QubitTimeMetrics();
        }

        public void OnAllocate(object[] qubitsTraceData)
        {
        }

        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        public void OnOperationEnd(CallGraphTreeEdge callEdge, object[] returnedQubitsTraceData)
        {
            double maxReturnedQubitsAvailableTime = 0;
            if ( returnedQubitsTraceData != null )
            {
                QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(returnedQubitsTraceData);
                maxReturnedQubitsAvailableTime = QubitsMetricsUtils.MaxQubitAvailableTime(qubitsMetrics);
            }
            OperationCallRecord opRec = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            double inputQubitsAvailableTime = QubitsMetricsUtils.MaxQubitAvailableTime(opRec.InputQubitMetrics);
            double operationEndTime =
                Max(
                    Max(maxReturnedQubitsAvailableTime, opRec.ReturnedQubitsAvailableTime),
                    Max(opRec.ReleasedQubitsAvailableTime, inputQubitsAvailableTime ));
            OperationCallRecord caller = operationCallStack.Peek();

            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime );
            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime );

            double[] metrics =
                StatisticsRecord( 
                    Depth : operationEndTime - opRec.MaxOperationStartTime,
                    StartTimeDifference: opRec.MaxOperationStartTime - opRec.MinOperationStartTime );

            stats.AddSample(callEdge, metrics);
        }

        public void OnOperationStart(CallGraphTreeEdge callEdge, object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);
            OperationCallRecord opRec = new OperationCallRecord();
            opRec.callEdge = callEdge;
            opRec.InputQubitMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.MaxOperationStartTime = QubitsMetricsUtils.MaxQubitAvailableTime(opRec.InputQubitMetrics);
            opRec.MinOperationStartTime = QubitsMetricsUtils.MinQubitAvailableTime(opRec.InputQubitMetrics);
            operationCallStack.Push(opRec);
        }

        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            double startTime = QubitsMetricsUtils.MaxQubitAvailableTime(qubitsMetrics);
            foreach (QubitTimeMetrics q in qubitsMetrics )
            {
                q.RecordQubitUsage(startTime, primitiveOperationDuration);
            }
        }

        public void OnRelease(object[] qubitsTraceData)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, QubitsMetricsUtils.MaxQubitAvailableTime(qubitsMetrics));
        }

        public void OnReturn(object[] qubitsTraceData, long qubitReleased)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.ReturnedQubitsAvailableTime = Max(opRec.ReturnedQubitsAvailableTime, QubitsMetricsUtils.MaxQubitAvailableTime(qubitsMetrics));
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion
    }
}
