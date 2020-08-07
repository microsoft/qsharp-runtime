using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public class NewInvalidatedQubitChecker : InvalidatedQubitUseCheckerBase, INewDecompositionTarget
    {
        public NewInvalidatedQubitChecker(bool throwOnInvalidatedQubitUse) : base(throwOnInvalidatedQubitUse)
        {
        }

        public void Z(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void CZ(Qubit control, Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(control);
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void CCZ(Qubit control1, Qubit control2, Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(control1);
            this.CheckForInvalidatedQubitUse(control2);
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void H(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void S(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void SAdjoint(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }
        public void T(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void TAdjoint(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void Rz(double theta, Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void M(Qubit qubit)
        {
            this.CheckForInvalidatedQubitUse(qubit);
        }

        public void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.CheckForInvalidatedQubitUse(qubits);
        }
    }
}
