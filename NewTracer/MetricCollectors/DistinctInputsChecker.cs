using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using NewTracer.MetricCollection;
using System;
using System.Collections.Generic;
using System.Linq;

namespace NewTracer.MetricCollectors
{
    public class DistinctInputsChecker : QuantumProcessorBase, IMetricCollector
    {
        public class NonDistinctInputsEventCount : IStackRecord
        {
            public double NonDistinctCount { get; set; }
        }

        protected NonDistinctInputsEventCount CurrentState;
        protected readonly bool ThrowOnNonDistinctQubits;

        public DistinctInputsChecker(bool throwOnNonDistinctQubits)
        {
            this.ThrowOnNonDistinctQubits = throwOnNonDistinctQubits;
            this.CurrentState = new NonDistinctInputsEventCount();
        }

        public string CollectorName()
        {
            return "DistinctInputsChecker";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "NonDistinctCount"
            };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord startState, IApplyData returned)
        {
            NonDistinctInputsEventCount prevState = (NonDistinctInputsEventCount)startState;
            return new double[]
            {
                    CurrentState.NonDistinctCount - prevState.NonDistinctCount
            };
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData _)
        {
            return new NonDistinctInputsEventCount
            {
                NonDistinctCount = CurrentState.NonDistinctCount
            };
        }

        public static IEnumerable<Qubit> ExtractQubits(IApplyData args)
        {
            return args?.Qubits?.Where(qubit => qubit != null) ?? new Qubit[] { };
        }


        protected void DistinctQubitUseCheck(IEnumerable<Qubit> qubits)
        {
            int numQubits = qubits.Count();
            int numUniqueQubits = qubits.Select(qubit => qubit.Id).Distinct().Count();
            int numNonDistinct = numQubits - numUniqueQubits;

            this.CurrentState.NonDistinctCount += numNonDistinct;
            if (numNonDistinct > 0 && this.ThrowOnNonDistinctQubits)
            {
                throw new DistinctInputsCheckerException();
            }
        }


        public override void OnOperationStart(ICallable operation, IApplyData arguments)
        {
            this.DistinctQubitUseCheck(ExtractQubits(arguments));
        }

        public override void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            this.DistinctQubitUseCheck(ExtractQubits(arguments));
        }


        public override void Z(Qubit qubit)
        {
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1 || controls.Length == 2)
            {
                this.DistinctQubitUseCheck(controls.Append(qubit));
            }
            else
            {
                throw new NotImplementedException();
            }
        }
        public override void H(Qubit qubit)
        {

        }

        public override void S(Qubit qubit)
        {

        }

        public override void SAdjoint(Qubit qubit)
        {

        }
        public override void T(Qubit qubit)
        {

        }

        public override void TAdjoint(Qubit qubit)
        {

        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliZ)
            {

            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public override Result M(Qubit qubit)
        {
            return null;
        }

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.DistinctQubitUseCheck(qubits);
            return null;
        }
    }
}
