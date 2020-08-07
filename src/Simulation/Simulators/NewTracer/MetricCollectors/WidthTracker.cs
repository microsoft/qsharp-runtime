using Microsoft.Quantum.Simulation.Core;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    public class WidthTracker : IQubitTrackingTarget, IMetricCollector
    {
        public class WidthState : IStackRecord
        {
            public double InputWidth { get; set; }

            public double AllocatedAtStart { get; set; }

            public double MaxAllocated { get; set; }

            public double BorrowedQubits { get; set; }

            public double MaxBorrowed { get; set; }
        }

        protected WidthState CurrentState;
        protected double AllocatedQubits;

        public WidthTracker()
        {
            CurrentState = new WidthState();
            AllocatedQubits = 0;
        }

        string IMetricCollector.CollectorName()
        {
            return "WidthCounter";
        }

        IList<string> IMetricCollector.Metrics()
        {
            return new string[]
            {
                "InputWidth",
                "ExtraWidth",
                "ReturnWidth",
                "BorrowedWidth"
            };
        }

        double[] IMetricCollector.OutputMetricsOnOperationEnd(IStackRecord savedParentState, IApplyData returned)
        {
            WidthState endState = (WidthState)savedParentState;
            // Updating parent state
            endState.MaxAllocated = System.Math.Max(CurrentState.MaxAllocated, endState.MaxAllocated);
            //TODO: why isn't maxBorrowed maxed?

            double[] values = new[]
            {
                    CurrentState.InputWidth,
                    CurrentState.MaxAllocated - CurrentState.AllocatedAtStart,
                    this.CountQubits(returned),
                    CurrentState.MaxBorrowed
            };
            this.CurrentState = endState;
            return values;
        }

        IStackRecord IMetricCollector.SaveRecordOnOperationStart(IApplyData inputArgs)
        {
            WidthState savedState = this.CurrentState;
            this.CurrentState = new WidthState
            {
                InputWidth = this.CountQubits(inputArgs),
                AllocatedAtStart = this.AllocatedQubits,
                MaxAllocated = this.AllocatedQubits,
                BorrowedQubits = 0,
                MaxBorrowed = 0
            };
            return savedState;
        }

        void IQubitTrackingTarget.OnAllocateQubits(IQArray<Qubit> qubits)
        {
            this.AllocatedQubits += qubits.Count;
            CurrentState.MaxAllocated = System.Math.Max(this.AllocatedQubits, CurrentState.MaxAllocated);
        }

        void IQubitTrackingTarget.OnReleaseQubits(IQArray<Qubit> qubits)
        {
            this.AllocatedQubits -= qubits.Count;
        }

        void IQubitTrackingTarget.OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
            this.AllocatedQubits += allocatedForBorrowingCount;
            CurrentState.MaxAllocated = System.Math.Max(this.AllocatedQubits, CurrentState.MaxAllocated);

            CurrentState.BorrowedQubits += (qubits.Length - allocatedForBorrowingCount);
            CurrentState.MaxBorrowed = System.Math.Max(CurrentState.BorrowedQubits, CurrentState.MaxBorrowed);
        }

        void IQubitTrackingTarget.OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            this.AllocatedQubits -= releasedOnReturnCount;
            CurrentState.BorrowedQubits -= (qubits.Length - releasedOnReturnCount);
        }

        private int CountQubits(IApplyData args)
        {
            return args?.Qubits?.Where(qubit => qubit != null).Count() ?? 0;
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
    }
}
