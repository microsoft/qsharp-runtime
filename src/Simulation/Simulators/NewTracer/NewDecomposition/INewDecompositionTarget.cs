using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public interface INewDecompositionTarget : ITracerTarget
    {
        void Z(Qubit qubit);

        void CZ(Qubit control, Qubit qubit);

        void CCZ(Qubit control0, Qubit control1, Qubit qubit);

        void H(Qubit qubit);

        void S(Qubit qubit);

        void SAdjoint(Qubit qubit);

        void T(Qubit qubit);

        void TAdjoint(Qubit qubit);

        void Rz(double theta, Qubit qubit);

        void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits);

        void M(Qubit qubit);
    }
}