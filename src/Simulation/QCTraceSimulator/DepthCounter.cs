// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static System.Math;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    public class DepthCounter : IQCTraceSimulatorListener, ICallGraphStatistics
    {
        class OperationCallRecord
        {
            public HashedString OperationName;
            public OperationFunctor FunctorSpecialization;
            public double MinOperationStartTime;
            public double MaxOperationStartTime;
            public double ReleasedQubitsAvailableTime;
            public double ReturnedQubitsAvailableTime;
            public QubitTimeMetrics[] InputQubitMetrics;
        }

        StatisticsCollector<CallGraphEdge> stats;
        Stack<OperationCallRecord> operationCallStack;

        public IStatisticCollectorResults<CallGraphEdge> Results => stats;

        public DepthCounter(IDoubleStatistic[] statisticsToCollect = null)
        {
            stats = new StatisticsCollector<CallGraphEdge>(
                Utils.MethodParametersNames(this, "StatisticsRecord"),
                statisticsToCollect ?? StatisticsCollector<CallGraphEdge>.DefaultStatistics()
                );
            operationCallStack = new Stack<OperationCallRecord>();

            OperationCallRecord opRec = new OperationCallRecord();
            opRec.OperationName = CallGraphEdge.CallGraphRootHashed;
            operationCallStack.Push(opRec);
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

        public void OnOperationEnd(object[] returnedQubitsTraceData)
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
            HashedString callerName = caller.OperationName;

            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime);
            caller.ReturnedQubitsAvailableTime = Max(opRec.ReturnedQubitsAvailableTime, caller.ReturnedQubitsAvailableTime);

            double[] metrics =
                StatisticsRecord( 
                    Depth : operationEndTime - opRec.MaxOperationStartTime,
                    StartTimeDifference: opRec.MaxOperationStartTime - opRec.MinOperationStartTime );

            stats.AddSample(new CallGraphEdge(opRec.OperationName, callerName,opRec.FunctorSpecialization, caller.FunctorSpecialization), metrics);
        }

        public void OnOperationStart(HashedString name, OperationFunctor functorSpecialization, object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);
            OperationCallRecord opRec = new OperationCallRecord();
            opRec.FunctorSpecialization = functorSpecialization;
            opRec.OperationName = name;
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
