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
        private class OperationCallRecord
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
            initialCapacity: 128, // Reasonable number to preallocate.
            defaultAvailabilityTime: 0.0);
        bool optimizeDepth = false;

        public IStatisticCollectorResults<CallGraphEdge> Results => stats;

        public DepthCounter(IDoubleStatistic[] statisticsToCollect = null, bool optimizeDepth = false)
        {
            stats = new StatisticsCollector<CallGraphEdge>(
                Utils.MethodParametersNames(this, "StatisticsRecord"),
                statisticsToCollect ?? StatisticsCollector<CallGraphEdge>.DefaultStatistics()
                );
            operationCallStack = new Stack<OperationCallRecord>();

            OperationCallRecord opRec = new OperationCallRecord();
            opRec.OperationName = CallGraphEdge.CallGraphRootHashed;
            operationCallStack.Push(opRec);
            this.optimizeDepth = optimizeDepth;
        }

        public static class Metrics
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
            return new QubitTimeMetrics(qubitId) { StartTime = ComplexTime.MinValue, EndTime = ComplexTime.Zero };
        }

        public void OnAllocate(object[] qubitsTraceData)
        {
            foreach (QubitTimeMetrics metric in qubitsTraceData.Cast<QubitTimeMetrics>())
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
                maxReturnedQubitsAvailableTime = MaxAvailableTime(returnedQubitsTraceData.Cast<QubitTimeMetrics>());
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

            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime);
            caller.ReturnedQubitsAvailableTime = Max(opRec.ReturnedQubitsAvailableTime, caller.ReturnedQubitsAvailableTime);

            double[] metrics =
                StatisticsRecord( 
                    Depth : operationEndTime - opRec.MaxOperationStartTime,
                    StartTimeDifference: opRec.MaxOperationStartTime - opRec.MinOperationStartTime,
                    Width: optimizeDepth ? WidthWithReuse : qubitAvailabilityTime.GetMaxQubitId() - opRec.MaxQubitIdAtStart );

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

        private double MinAvailableTime(IEnumerable<QubitTimeMetrics> qubitTimeMetrics)
        {
            Debug.Assert(qubitTimeMetrics != null);
            double min = Double.MaxValue;
            foreach (QubitTimeMetrics metric in qubitTimeMetrics)
            {
                min = Min(min, qubitAvailabilityTime[metric.QubitId]);
            }
            return min != Double.MaxValue ? min : 0;
        }

        private double MaxAvailableTime(IEnumerable<QubitTimeMetrics> qubitTimeMetrics)
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
            IEnumerable<QubitTimeMetrics> qubitsMetrics = qubitsTraceData.Cast<QubitTimeMetrics>();

            double startTime = MaxAvailableTime(qubitsMetrics);
            foreach (QubitTimeMetrics q in qubitsMetrics)
            {
                qubitAvailabilityTime[q.QubitId] = startTime + primitiveOperationDuration;
            }

            // Doing adjustments for width-with-reuse computation.
            if (qubitsTraceData.Length == 1) {
                // Single qubit gate always advances end time by operation duration
                // in case qubit is fixed or not fixed in time.
                ((QubitTimeMetrics)qubitsTraceData[0]).EndTime =
                    ((QubitTimeMetrics)qubitsTraceData[0]).EndTime.AdvanceBy(primitiveOperationDuration);
            } else {
                // Multi-qubit gate fixes all qubits in time and advances end time
                // First, figure out what time it is. It's max over fixed and not fixed times.
                ComplexTime maxEndTime = ComplexTime.Zero;
                foreach (QubitTimeMetrics q in qubitsMetrics) {
                    maxEndTime = ComplexTime.Max(maxEndTime, q.EndTime);
                }
                // Now we fix qubits that are not yet fixed by adjusting their start time.
                // And adjust end time for all qubits involved.
                foreach (QubitTimeMetrics q in qubitsMetrics) {
                    if (ComplexTime.Compare(q.StartTime, ComplexTime.MinValue) == 0) {
                        q.StartTime = maxEndTime.Subtract(q.EndTime);
                    }
                    q.EndTime = maxEndTime.AdvanceBy(primitiveOperationDuration);
                }
            }

        }

        SortedQubitPool qubitStartTimes = new SortedQubitPool();
        SortedQubitPool qubitEndTimes = new SortedQubitPool();
        long WidthWithReuse = 0;

        public void OnRelease(object[] qubitsTraceData)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            opRec.ReleasedQubitsAvailableTime = Max(
                opRec.ReleasedQubitsAvailableTime,
                MaxAvailableTime(qubitsTraceData.Cast<QubitTimeMetrics>()));

            // Doing width reuse heuristics and width computation.
            foreach (QubitTimeMetrics q in qubitsTraceData.Cast<QubitTimeMetrics>()) {
                // If qubit wasn't used in any gate. We don't allocate it.
                if (ComplexTime.Compare(q.EndTime, ComplexTime.Zero) == 0) {
                    continue;
                }

                // If qubit is not fixed in time we fix it at zero.
                if (ComplexTime.Compare(q.StartTime, ComplexTime.MinValue) == 0) {
                    q.StartTime = ComplexTime.Zero;
                }

                // Then we find if we can reuse
                bool reuseExistingAfterNew = qubitStartTimes.FindBound(q.EndTime, getLowerBound: false, out ComplexTime existingStart);
                bool reuseNewAfterExising = qubitEndTimes.FindBound(q.StartTime, getLowerBound: true, out ComplexTime existingEnd);
                if (reuseNewAfterExising && reuseExistingAfterNew) {
                    if (ComplexTime.Compare(q.StartTime.Subtract(existingEnd), existingStart.Subtract(q.EndTime)) > 0) {
                        reuseNewAfterExising = false;
                    } else {
                        reuseExistingAfterNew = false;
                    }
                }

                if (reuseNewAfterExising) {
                    long idToReuse = qubitEndTimes.Remove(existingEnd);
                    qubitEndTimes.Add(idToReuse, q.EndTime);
                } else if (reuseExistingAfterNew) {
                    long idToReuse = qubitStartTimes.Remove(existingStart);
                    qubitStartTimes.Add(idToReuse, q.StartTime);
                } else {
                    // Cannot reuse existing qubits. Use new qubit.
                    long id = WidthWithReuse;
                    WidthWithReuse++;
                    qubitStartTimes.Add(id, q.StartTime);
                    qubitEndTimes.Add(id, q.EndTime);
                }

            }
        }

        public void OnReturn(object[] qubitsTraceData, long qubitReleased)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            opRec.ReturnedQubitsAvailableTime = Max(
                opRec.ReturnedQubitsAvailableTime,
                MaxAvailableTime(qubitsTraceData.Cast<QubitTimeMetrics>()));
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion
    }
}
