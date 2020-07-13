using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System.Runtime.ExceptionServices;

namespace Microsoft.Quantum.Simulators.NewTracer.GateDecomposition
{
    public interface ITracerDecompositions
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

        Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits);

        Result M(Qubit qubit);
    }

    public interface IQubitTracking
    {

    }
}
