using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    public class InvalidatedQubitUseChecker : QuantumProcessorBase, IMetricCollector, IQubitTraceSubscriber
    {
        public class InvalidatedQubitUseCount : IStackRecord
        {
            public double InvalidatedQubitUses { get; set; }
        }

        private enum QubitStatus
        {
            Active,
            Invalidated
        }

        protected InvalidatedQubitUseCount CurrentState;
        protected readonly bool ThrowOnInvalidatedQubitUse;

        public InvalidatedQubitUseChecker(bool throwOnInvalidatedQubitUse)
        {
            this.ThrowOnInvalidatedQubitUse = throwOnInvalidatedQubitUse;
            this.CurrentState = new InvalidatedQubitUseCount();
        }

        public string CollectorName()
        {
            return "InvalidatedQubitUseChecker";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "InvalidatedQubitUses"
            };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord startState, IApplyData returned)
        {
            InvalidatedQubitUseCount prevState = (InvalidatedQubitUseCount)startState;
            return new double[]
            {
                    CurrentState.InvalidatedQubitUses - prevState.InvalidatedQubitUses
            };
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData _)
        {
            return new InvalidatedQubitUseCount
            {
                InvalidatedQubitUses = CurrentState.InvalidatedQubitUses
            };
        }

        //TODO: extract this to shared util
        public static IEnumerable<Qubit> ExtractQubits(IApplyData args)
        {
            return args?.Qubits?.Where(qubit => qubit != null) ?? new Qubit[] { };
        }

        public object NewTracingData(long id)
        {
            return QubitStatus.Active;
        }

        protected void OnInvalidatedQubitUse()
        {
            this.CurrentState.InvalidatedQubitUses++;
            if (this.ThrowOnInvalidatedQubitUse)
            {
                throw new InvalidatedQubitsUseCheckerException();
            }
        }

        protected void InvalidateQubits(IEnumerable<Qubit> qubits)
        {
            foreach (Qubit q in qubits)
            {
                TraceableQubit qubit = (TraceableQubit)q;
                qubit.SetData(this, QubitStatus.Invalidated);
            }
        }

        protected bool CheckForInvalidatedQubitUse(Qubit qubit)
        {
            TraceableQubit q = (TraceableQubit)qubit;
            QubitStatus status = (QubitStatus)(q.ExtractData(this));
            if (status == QubitStatus.Invalidated)
            {
                this.OnInvalidatedQubitUse();
                return true;
            }
            return false;
        }

        protected bool CheckForInvalidatedQubitUse(IEnumerable<Qubit> qubits)
        {
            foreach (Qubit qubit in qubits)
            {
                if (this.CheckForInvalidatedQubitUse(qubit))
                {
                    return true;
                }
            }
            return false;
        }

        public override void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            this.InvalidateQubits(qubits);
        }

        public override void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            this.InvalidateQubits(qubits);
        }

        public override void OnOperationStart(ICallable operation, IApplyData arguments)
        {
            this.CheckForInvalidatedQubitUse(ExtractQubits(arguments));
        }

        public override void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            this.CheckForInvalidatedQubitUse(ExtractQubits(arguments));
        }


        public override void Z(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1 || controls.Length == 2)
            {
                this.CheckForInvalidatedQubitUse(controls);
                this.CheckForInvalidatedQubitUse(qubit);
            }
            else
            {
                throw new NotImplementedException();
            }
        }
        public override void H(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public override void S(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public override void SAdjoint(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }
        public override void T(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public override void TAdjoint(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliZ)
            {
                this.CheckForInvalidatedQubitUse(qubit);
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public override Result M(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
            return null;
        }

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.CheckForInvalidatedQubitUse(qubits);
            return null;
        }
    }
}
