﻿// Copyright (c) Microsoft Corporation. All rights reserved.
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
            public long MaxQubitIdAtStart = -1;
            public QubitTimeMetrics[] InputQubitMetrics;
        }

        StatisticsCollector<CallGraphEdge> stats;
        Stack<OperationCallRecord> operationCallStack;
        QubitAvailabilityTimeTracker qubitAvailabilityTime = new QubitAvailabilityTimeTracker(
            initialCapacity: 128,
            defaultAvailabilityTime: 0);

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
            public const string Width = "Width";
        }

        public double[] StatisticsRecord(double Depth, double StartTimeDifference, double Width)
        {
            return new double[] { Depth, StartTimeDifference, Width };
        }

        #region IQCTraceSimulatorListener implementation 
        public object NewTracingData(long qubitId)
        {
            return new QubitTimeMetrics(qubitId);
        }

        public void OnAllocate(object[] qubitsTraceData)
        {
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            foreach (QubitTimeMetrics metric in qubitsMetrics)
            {
                qubitAvailabilityTime.MarkQubitIdUsed(metric.QubitId);
            }
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
                maxReturnedQubitsAvailableTime = MaxAvailableTime(qubitsMetrics);
            }
            OperationCallRecord opRec = operationCallStack.Pop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            double inputQubitsAvailableTime = MaxAvailableTime(opRec.InputQubitMetrics);
            double operationEndTime =
                Max(
                    Max(maxReturnedQubitsAvailableTime, opRec.ReturnedQubitsAvailableTime),
                    Max(opRec.ReleasedQubitsAvailableTime, inputQubitsAvailableTime ));
            OperationCallRecord caller = operationCallStack.Peek();
            HashedString callerName = caller.OperationName;

            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime );
            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime );

            double[] metrics =
                StatisticsRecord( 
                    Depth : operationEndTime - opRec.MaxOperationStartTime,
                    StartTimeDifference: opRec.MaxOperationStartTime - opRec.MinOperationStartTime,
                    Width: qubitAvailabilityTime.GetMaxQubitId() - opRec.MaxQubitIdAtStart );

            stats.AddSample(new CallGraphEdge(opRec.OperationName, callerName,opRec.FunctorSpecialization, caller.FunctorSpecialization), metrics);
        }

        public void OnOperationStart(HashedString name, OperationFunctor functorSpecialization, object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);
            OperationCallRecord opRec = new OperationCallRecord();
            opRec.FunctorSpecialization = functorSpecialization;
            opRec.OperationName = name;
            opRec.InputQubitMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.MaxOperationStartTime = MaxAvailableTime(opRec.InputQubitMetrics);
            opRec.MinOperationStartTime = MinAvailableTime(opRec.InputQubitMetrics);
            opRec.MaxQubitIdAtStart = qubitAvailabilityTime.GetMaxQubitId();
            operationCallStack.Push(opRec);
        }

        private double MinAvailableTime(QubitTimeMetrics[] qubitTimeMetrics)
        {
            Debug.Assert(qubitTimeMetrics != null);
            double min = Double.MaxValue;
            foreach (QubitTimeMetrics metric in qubitTimeMetrics)
            {
                min = Min(min, qubitAvailabilityTime[metric.QubitId]);
            }
            return min != Double.MaxValue ? min : 0;
        }

        private double MaxAvailableTime(QubitTimeMetrics[] qubitTimeMetrics)
        {
            Debug.Assert(qubitTimeMetrics != null);
            double max = 0;
            foreach (QubitTimeMetrics metric in qubitTimeMetrics)
            {
                max = Max(max, qubitAvailabilityTime[metric.QubitId]);
            }
            return max;
        }

        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);

            double startTime = MaxAvailableTime(qubitsMetrics);
            foreach (QubitTimeMetrics q in qubitsMetrics )
            {
                qubitAvailabilityTime[q.QubitId] = startTime + primitiveOperationDuration;
                // TODO: Remove! This is not needed. If qubit id is in the metrics data, it was already seen by this class.
                // this.MaxQubitId = System.Math.Max(this.MaxQubitId, qubitId);
            }
        }

        public void OnRelease(object[] qubitsTraceData)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, MaxAvailableTime(qubitsMetrics));
        }

        public void OnReturn(object[] qubitsTraceData, long qubitReleased)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            QubitTimeMetrics[] qubitsMetrics = Utils.UnboxAs<QubitTimeMetrics>(qubitsTraceData);
            opRec.ReturnedQubitsAvailableTime = Max(opRec.ReturnedQubitsAvailableTime, MaxAvailableTime(qubitsMetrics));
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion
    }
}
