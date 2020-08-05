using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    public abstract class DepthCounterBase : IQubitTrackingTarget, IMetricCollector, IQubitTraceSubscriber<double>
    {
        public class DepthState : IStackRecord
        {
            public Qubit[] InputQubits { get; set; }

            public double MinStartTime { get; set; }

            public double MaxStartTime { get; set; }

            public double ReleasedQubitsTime { get; set; }

            public double ReturnedQubitsTime { get; set; }
        }

        protected DepthState CurrentState;

        public DepthCounterBase()
        {
            this.CurrentState = new DepthState();
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
                "StartTimeDifference"
            };
        }

        public void RecordQubitUse(double duration, Qubit qubit)
        {
            double availableTime = this.GetAvailableTime(qubit);
            this.RecordQubitUse(availableTime, duration, qubit);
        }

        public void RecordQubitUse(double duration, params Qubit[] qubits)
        {
            this.RecordQubitUse(duration, qubits);
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
                    CurrentState.MaxStartTime - CurrentState.MinStartTime
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

        //TODO: implement time storing as dictionary id->time an clear entries on release

        void IQubitTrackingTarget.OnAllocateQubits(IQArray<Qubit> qubits)
        {
        }

        void IQubitTrackingTarget.OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
        }

        double IQubitTraceSubscriber<double>.NewTracingData(long id)
        {
            return 0.0d;
        }

        protected void RecordQubitUse(double startTime, double duration, Qubit qubit)
        {
            double finishedAt = startTime + duration;
            this.SetQubitData(qubit, finishedAt);
        }

        public double GetAvailableTime(Qubit qubit)
        {
            return this.ExtractQubitData(qubit);
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
