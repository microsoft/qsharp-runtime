using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using System.Collections.Generic;
using static Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors.InvalidatedQubitUseCheckerBase;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    public abstract class InvalidatedQubitUseCheckerBase : IQubitTrackingTarget, IMetricCollector,
        IOperationTrackingTarget, IQubitTraceSubscriber<QubitStatus>
    {
        public class InvalidatedQubitUseCount : IStackRecord
        {
            public double InvalidatedQubitUses { get; set; }
        }

        public enum QubitStatus
        {
            Active,
            Invalidated
        }

        protected InvalidatedQubitUseCount CurrentState;
        protected readonly bool ThrowOnInvalidatedQubitUse;

        public InvalidatedQubitUseCheckerBase(bool throwOnInvalidatedQubitUse)
        {
            this.ThrowOnInvalidatedQubitUse = throwOnInvalidatedQubitUse;
            this.CurrentState = new InvalidatedQubitUseCount();
        }

        string IMetricCollector.CollectorName()
        {
            return "InvalidatedQubitUseChecker";
        }

        IList<string> IMetricCollector.Metrics()
        {
            return new string[]
            {
                "InvalidatedQubitUses"
            };
        }

        public bool CheckForInvalidatedQubitUse(Qubit qubit)
        {
            QubitStatus status = this.ExtractQubitData(qubit);
            if (status == QubitStatus.Invalidated)
            {
                this.OnInvalidatedQubitUse();
                return true;
            }
            return false;
        }

        public bool CheckForInvalidatedQubitUse(params Qubit[]? qubits)
        {
            return this.CheckForInvalidatedQubitUse(qubits);
        }

        public bool CheckForInvalidatedQubitUse(IEnumerable<Qubit>? qubits)
        {
            if (qubits == null) { return false; }

            bool result = false;
            foreach (Qubit qubit in qubits)
            {
                if (this.CheckForInvalidatedQubitUse(qubit))
                {
                    result = true;
                }
            }
            return result;
        }

        double[] IMetricCollector.OutputMetricsOnOperationEnd(IStackRecord startState, IApplyData returned)
        {
            InvalidatedQubitUseCount prevState = (InvalidatedQubitUseCount)startState;
            return new double[]
            {
                CurrentState.InvalidatedQubitUses - prevState.InvalidatedQubitUses
            };
        }

        IStackRecord IMetricCollector.SaveRecordOnOperationStart(IApplyData arguments)
        {
            return new InvalidatedQubitUseCount
            {
                InvalidatedQubitUses = CurrentState.InvalidatedQubitUses
            };
        }

        QubitStatus IQubitTraceSubscriber<QubitStatus>.NewTracingData(long id)
        {
            return QubitStatus.Active;
        }

        void IQubitTrackingTarget.OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            this.InvalidateQubits(qubits);
        }

        void IQubitTrackingTarget.OnReleaseQubits(IQArray<Qubit> qubits)
        {
            this.InvalidateQubits(qubits);
        }

        void IQubitTrackingTarget.OnAllocateQubits(IQArray<Qubit> qubits)
        {
        }

        void IQubitTrackingTarget.OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
        }

        void IOperationTrackingTarget.OnOperationStart(ICallable operation, IApplyData arguments)
        {
            this.CheckForInvalidatedQubitUse(arguments.GetQubits());
        }

        void IOperationTrackingTarget.OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            this.CheckForInvalidatedQubitUse(arguments.GetQubits());
        }

        protected void InvalidateQubits(IEnumerable<Qubit> qubits)
        {
            foreach (Qubit q in qubits)
            {
                this.SetQubitData(q, QubitStatus.Invalidated);
            }
        }

        protected void OnInvalidatedQubitUse()
        {
            this.CurrentState.InvalidatedQubitUses++;
            if (this.ThrowOnInvalidatedQubitUse)
            {
                throw new InvalidatedQubitsUseCheckerException();
            }
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
    }
}
