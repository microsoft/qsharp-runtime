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

        private readonly bool optimizeDepth = false;
        private readonly StatisticsCollector<CallGraphEdge> stats;
        private readonly Stack<OperationCallRecord> operationCallStack;

        // Used when OptimizeDepth = false. We track availability time for each underlying qubits identified by id.
        private readonly QubitAvailabilityTimeTracker qubitAvailabilityTime;

        // Used when OptimizeDepth = true. We reuse qubits based on busy intervals.
        // These pools track start and end time during which qubits are busy.
        private readonly SortedQubitPool qubitStartTimes;
        private readonly SortedQubitPool qubitEndTimes;

        // Maximum qubit id seen by this counter
        private long maxQubitId = -1;

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
            if (optimizeDepth)
            {
                qubitStartTimes = new SortedQubitPool();
                qubitEndTimes = new SortedQubitPool();
            }
            else
            {
                qubitAvailabilityTime = new QubitAvailabilityTimeTracker(
                    initialCapacity: 128, // Reasonable number to preallocate.
                    defaultAvailabilityTime: 0.0);
            }
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
            return new QubitTimeMetrics(qubitId)
            {
                StartTime = ComplexTime.MinValue,
                EndTime = ComplexTime.Zero
            };
        }

        public void OnAllocate(object[] qubitsTraceData)
        {
            if (optimizeDepth)
            {
                // When we optimize for depth we decide which underlying qubit to use
                // for a user qubit when user qubit is released. Therefore we assign
                // Underlying qubit ids on release.
                return;
            }
            foreach (QubitTimeMetrics metric in qubitsTraceData.Cast<QubitTimeMetrics>())
            {
                // When we don't optimize for depth we use ids from qubit manager.
                maxQubitId = System.Math.Max(maxQubitId, metric.QubitId);
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
                    Max(opRec.ReleasedQubitsAvailableTime, inputQubitsAvailableTime));
            OperationCallRecord caller = operationCallStack.Peek();

            caller.ReleasedQubitsAvailableTime = Max(opRec.ReleasedQubitsAvailableTime, caller.ReleasedQubitsAvailableTime);
            caller.ReturnedQubitsAvailableTime = Max(opRec.ReturnedQubitsAvailableTime, caller.ReturnedQubitsAvailableTime);

            double[] metrics =
                StatisticsRecord( 
                    Depth : operationEndTime - opRec.MaxOperationStartTime,
                    StartTimeDifference: opRec.MaxOperationStartTime - opRec.MinOperationStartTime,
                    Width: maxQubitId - opRec.MaxQubitIdAtStart );

            stats.AddSample(
                new CallGraphEdge(opRec.OperationName, caller.OperationName, opRec.FunctorSpecialization, caller.FunctorSpecialization),
                metrics);
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
            opRec.MaxQubitIdAtStart = maxQubitId;
            operationCallStack.Push(opRec);
        }

        private double MinAvailableTime(IEnumerable<QubitTimeMetrics> qubitTimeMetrics)
        {
            Debug.Assert(qubitTimeMetrics != null);
            double min = Double.MaxValue;
            foreach (QubitTimeMetrics metric in qubitTimeMetrics)
            {
                if (optimizeDepth) {
                    min = Min(min, metric.EndTime.DepthTime);
                }
                else
                {
                    min = Min(min, qubitAvailabilityTime[metric.QubitId]);
                }
            }
            return min != Double.MaxValue ? min : 0;
        }

        private double MaxAvailableTime(IEnumerable<QubitTimeMetrics> qubitTimeMetrics)
        {
            Debug.Assert(qubitTimeMetrics != null);
            double max = 0;
            foreach (QubitTimeMetrics metric in qubitTimeMetrics)
            {
                if (optimizeDepth) {
                    max = Max(max, metric.EndTime.DepthTime);
                }
                else
                {
                    max = Max(max, qubitAvailabilityTime[metric.QubitId]);
                }
            }
            return max;
        }

        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            IEnumerable<QubitTimeMetrics> qubitsMetrics = qubitsTraceData.Cast<QubitTimeMetrics>();
            if (optimizeDepth)
            {
                // When we optimize for depth we may need to adjust qubit start times in addition to qubit end times.
                if (qubitsTraceData.Length == 1)
                {
                    // Single qubit gate always advances end time by operation duration
                    // in case qubit is fixed or not fixed in time.
                    ((QubitTimeMetrics)qubitsTraceData[0]).EndTime =
                        ((QubitTimeMetrics)qubitsTraceData[0]).EndTime.AdvanceBy(primitiveOperationDuration);
                }
                else
                {
                    // Multi-qubit gate fixes all qubits in time and advances end time
                    // First, figure out what time it is. It's max over fixed and not fixed times.
                    ComplexTime maxEndTime = ComplexTime.Zero;
                    foreach (QubitTimeMetrics q in qubitsMetrics)
                    {
                        maxEndTime = ComplexTime.Max(maxEndTime, q.EndTime);
                    }
                    // Now we fix qubits that are not yet fixed by adjusting their start time.
                    // And adjust end time for all qubits involved.
                    foreach (QubitTimeMetrics q in qubitsMetrics)
                    {
                        if (q.StartTime.IsEqualTo(ComplexTime.MinValue))
                        {
                            q.StartTime = maxEndTime.Subtract(q.EndTime);
                        }
                        q.EndTime = maxEndTime.AdvanceBy(primitiveOperationDuration);
                    }
                }
            }
            else
            {
                // When we don't optimize for depth we use max availability time
                // as gate execution time and then adjust availability time of qubits involved
                double startTime = MaxAvailableTime(qubitsMetrics);
                foreach (QubitTimeMetrics q in qubitsMetrics)
                {
                    qubitAvailabilityTime[q.QubitId] = startTime + primitiveOperationDuration;
                }
            }
        }

        public void OnRelease(object[] qubitsTraceData)
        {
            OperationCallRecord opRec = operationCallStack.Peek();
            opRec.ReleasedQubitsAvailableTime = Max(
                opRec.ReleasedQubitsAvailableTime,
                MaxAvailableTime(qubitsTraceData.Cast<QubitTimeMetrics>()));

            if (optimizeDepth)
            {
                // Doing width reuse heuristics and width computation.
                foreach (QubitTimeMetrics q in qubitsTraceData.Cast<QubitTimeMetrics>())
                {
                    // If qubit wasn't used in any gate. We don't allocate it.
                    if (q.EndTime.IsEqualTo(ComplexTime.Zero))
                    {
                        continue;
                    }

                    // If qubit is not fixed in time we fix it at zero.
                    if (q.StartTime.IsEqualTo(ComplexTime.MinValue))
                    {
                        q.StartTime = ComplexTime.Zero;
                    }

                    // Then we find if we can reuse existing qubits.
                    bool reuseExistingAfterNew = qubitStartTimes.FindBound(q.EndTime, getLowerBound: false, out ComplexTime existingStart);
                    bool reuseNewAfterExising = qubitEndTimes.FindBound(q.StartTime, getLowerBound: true, out ComplexTime existingEnd);
                    if (reuseNewAfterExising && reuseExistingAfterNew)
                    {
                        // If we can do both, see which reuse creates a shorter gap and leave it for reuse.
                        if (ComplexTime.Compare(q.StartTime.Subtract(existingEnd), existingStart.Subtract(q.EndTime)) > 0)
                        {
                            reuseNewAfterExising = false;
                        }
                        else
                        {
                            reuseExistingAfterNew = false;
                        }
                    }

                    if (reuseNewAfterExising)
                    {
                        // If we place new qubit after existing - update end time of existing qubit
                        long idToReuse = qubitEndTimes.Remove(existingEnd);
                        qubitEndTimes.Add(idToReuse, q.EndTime);
                    }
                    else if (reuseExistingAfterNew)
                    {
                        // If we place new qubit before existing - update start time of existing qubit
                        long idToReuse = qubitStartTimes.Remove(existingStart);
                        qubitStartTimes.Add(idToReuse, q.StartTime);
                    }
                    else
                    {
                        // We cannot reuse existing qubits. Use new qubit.
                        long id = maxQubitId;
                        maxQubitId++;
                        qubitStartTimes.Add(id, q.StartTime);
                        qubitEndTimes.Add(id, q.EndTime);
                    }
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
