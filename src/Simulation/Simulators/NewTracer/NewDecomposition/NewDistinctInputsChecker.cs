using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public class NewDistinctInputsChecker : DistinctInputsCheckerBase, INewDecompositionTarget
    {
        public NewDistinctInputsChecker(bool throwOnNonDistinctQubits) : base(throwOnNonDistinctQubits)
        {
        }

        public void Z(Qubit qubit)
        {
        }

        public void CZ(Qubit control, Qubit qubit)
        {
            this.DistinctQubitUseCheck(control, qubit);
        }

        public void CCZ(Qubit control1, Qubit control2, Qubit qubit)
        {
            this.DistinctQubitUseCheck(control1, control2, qubit);
        }

        public void H(Qubit qubit)
        {
        }

        public void S(Qubit qubit)
        {
        }

        public void SAdjoint(Qubit qubit)
        {
        }

        public void T(Qubit qubit)
        {
        }

        public void TAdjoint(Qubit qubit)
        {
        }

        public void Rz(double theta, Qubit qubit)
        {
        }

        public void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.DistinctQubitUseCheck(qubits);
        }

        public void M(Qubit qubit)
        {
        }
    }
}
