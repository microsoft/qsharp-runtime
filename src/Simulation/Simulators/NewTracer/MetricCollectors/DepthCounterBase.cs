using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    public abstract class DepthCounterBase : IQubitTrackingTarget, IMetricCollector, IQubitTraceSubscriber
    {
        public class DepthState : IStackRecord
        {
            public Qubit[] InputQubits { get; set; }

            public int MaxQubitIdAtStart { get; set; }

            public double MinStartTime { get; set; }

            public double MaxStartTime { get; set; }

            public double ReleasedQubitsTime { get; set; }

            public double ReturnedQubitsTime { get; set; }
        }

        private class AutoArrayOfDouble : List<double> {
            private double DefaultValue;
            public AutoArrayOfDouble(double defaultValue, int initialCapacity) : base(initialCapacity) {
                DefaultValue = defaultValue;
            }

            public new double this[int index] {
                get {
                    if (index < Count) {
                        return base[index];
                    }
                    return DefaultValue;
                }
                set {
                    if (index == Count) {
                        this.Add(value);
                        return;
                    } else if (index > Count) {
                        this.AddRange(Enumerable.Repeat(DefaultValue, index - Count + 1));
                    }
                    base[index] = value;
                }
            }
        }

        protected DepthState CurrentState;
        private int MaxQubitId = -1;
        private AutoArrayOfDouble AvailableTimeById = new AutoArrayOfDouble(
            defaultValue: 0,
            initialCapacity: 128);

        public DepthCounterBase()
        {
            this.CurrentState = new DepthState() { MaxQubitIdAtStart = MaxQubitId };
        }

        string IMetricCollector.CollectorName()
        {
            return "DepthCounter";
        }

        IList<string> IMetricCollector.Metrics()
        {
            return new string[]
            {
                "Depth",
                "StartTimeDifference",
                "Width"
            };
        }

        public void RecordQubitUse(double duration, Qubit qubit)
        {
            double availableTime = this.GetAvailableTime(qubit);
            this.RecordQubitUse(availableTime, duration, qubit);
        }

        public void RecordQubitUse(double duration, params Qubit[] qubits)
        {
            this.RecordQubitUse(duration, (IEnumerable<Qubit>) qubits);
        }

        public void RecordQubitUse(double duration, IEnumerable<Qubit> qubits)
        {
            double startTime = this.MaxAvailableTime(qubits);
            foreach (Qubit qubit in qubits)
            {
                this.RecordQubitUse(startTime, duration, qubit);
            }
        }

        double[] IMetricCollector.OutputMetricsOnOperationEnd(IStackRecord savedState, IApplyData returned)
        {
            DepthState endState = (DepthState)savedState;
            endState.ReleasedQubitsTime = System.Math.Max(CurrentState.ReleasedQubitsTime, endState.ReleasedQubitsTime);
            endState.ReturnedQubitsTime = System.Math.Max(CurrentState.ReturnedQubitsTime, endState.ReturnedQubitsTime);

            double invocationReturnQubitsAvailableTime = this.MaxAvailableTime(returned.GetQubits() ?? new Qubit[] { });
            double invocationInputQubitsAvailableTime = this.MaxAvailableTime(CurrentState.InputQubits);
            double invocationEndTime = System.Math.Max(
                System.Math.Max(invocationInputQubitsAvailableTime, invocationReturnQubitsAvailableTime),
                System.Math.Max(CurrentState.ReleasedQubitsTime, CurrentState.ReturnedQubitsTime)
            );

            double[] output = new double[]
            {
                    invocationEndTime - CurrentState.MaxStartTime,
                    CurrentState.MaxStartTime - CurrentState.MinStartTime,
                    this.MaxQubitId - endState.MaxQubitIdAtStart
            };
            this.CurrentState = endState;
            return output;
        }

        IStackRecord IMetricCollector.SaveRecordOnOperationStart(IApplyData inputArgs)
        {
            DepthState savedState = this.CurrentState;
            Qubit[] inputQubits = inputArgs.GetQubits()?.ToArray() ?? new Qubit[] { };
            this.CurrentState = new DepthState
            {
                InputQubits = inputQubits,
                MaxQubitIdAtStart = this.MaxQubitId,
                MinStartTime = this.MinAvailableTime(inputQubits),
                MaxStartTime = this.MaxAvailableTime(inputQubits),
                ReleasedQubitsTime = 0,
                ReturnedQubitsTime = 0
            };
            return savedState;
        }

        void IQubitTrackingTarget.OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            double returnedTime = this.MaxAvailableTime(qubits);
            this.CurrentState.ReturnedQubitsTime = System.Math.Max(this.CurrentState.ReturnedQubitsTime, returnedTime);
        }

        void IQubitTrackingTarget.OnReleaseQubits(IQArray<Qubit> qubits)
        {
            double releasedTime = this.MaxAvailableTime(qubits);
            this.CurrentState.ReleasedQubitsTime = System.Math.Max(this.CurrentState.ReleasedQubitsTime, releasedTime);
        }

        void IQubitTrackingTarget.OnAllocateQubits(IQArray<Qubit> qubits)
        {
            foreach (Qubit qubit in qubits)
            {
                this.MaxQubitId = System.Math.Max(this.MaxQubitId, qubit.Id);
            }
        }

        void IQubitTrackingTarget.OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
        }

        object? IQubitTraceSubscriber.NewTracingData(long id)
        {
            // TODO: This function is not needed - this class doesn't need to store any data in qubits.
            // However, infrastructure requires this function
            return null;
        }

        protected void RecordQubitUse(double startTime, double duration, Qubit qubit)
        {
            double finishedAt = startTime + duration;
            AvailableTimeById[qubit.Id] = finishedAt;
            this.MaxQubitId = System.Math.Max(this.MaxQubitId, qubit.Id);
        }

        public double GetAvailableTime(Qubit qubit)
        {
            return AvailableTimeById[qubit.Id];
        }

        public double MinAvailableTime(IEnumerable<Qubit> qubits)
        {
            double min = Double.MaxValue;
            foreach (Qubit qubit in qubits)
            {
                min = System.Math.Min(min, this.GetAvailableTime(qubit));
            }
            return min != Double.MaxValue ? min : 0;
        }

        public double MaxAvailableTime(IEnumerable<Qubit> qubits)
        {
            double max = 0;
            foreach (Qubit qubit in qubits)
            {
                max = System.Math.Max(max, this.GetAvailableTime(qubit));
            }
            return max;
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
    }
}
