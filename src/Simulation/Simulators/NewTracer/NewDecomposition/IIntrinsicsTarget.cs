using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public interface IIntrinsicsTarget : ITracerTarget
    {
        void X(Qubit qubit);

        void ControlledX(IQArray<Qubit> controls, Qubit qubit);

        void Y(Qubit qubit);

        void ControlledY(IQArray<Qubit> controls, Qubit qubit);

        void Z(Qubit qubit);

        void ControlledZ(IQArray<Qubit> controls, Qubit qubit);

        void SWAP(Qubit qubit1, Qubit qubit2);

        void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2);

        void H(Qubit qubit);

        void ControlledH(IQArray<Qubit> controls, Qubit qubit);

        void S(Qubit qubit);

        void ControlledS(IQArray<Qubit> controls, Qubit qubit);

        void SAdjoint(Qubit qubit);

        void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit);

        void T(Qubit qubit);

        void ControlledT(IQArray<Qubit> controls, Qubit qubit);

        void TAdjoint(Qubit qubit);

        void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit);

        void R(Pauli axis, double theta, Qubit qubit);

        void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit);

        void RFrac(Pauli axis, long numerator, long power, Qubit qubit);

        void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit);

        void R1(double theta, Qubit qubit);

        void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit);

        void R1Frac(long numerator, long power, Qubit qubit);

        void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit);

        void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits);

        void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits);

        void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits);

        void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits);

        void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits);
        void M(Qubit qubit);
    }
}
