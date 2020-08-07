using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    public interface IOldDecompositionTarget : ITracerTarget
    {
        void CX(Qubit control, Qubit qubit);

        void QubitClifford(int id, Pauli pauli, Qubit qubit);

        void R(Pauli pauli, double angle, Qubit qubit);

        void T(Qubit qubit);

        void Measure(IQArray<Pauli> observable, IQArray<Qubit> target);
    }
}
