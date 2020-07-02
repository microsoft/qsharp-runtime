using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
namespace NewTracer.Utils
{
    public class EmptyProcessor : QuantumProcessorBase
    {
        public override void X(Qubit qubit)
        {
        }

        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void Y(Qubit qubit)
        {
        }

        public override void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void Z(Qubit qubit)
        {
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
        }

        public override void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
        }

        public override void H(Qubit qubit)
        {
        }

        public override void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void S(Qubit qubit)
        {
        }

        public override void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void SAdjoint(Qubit qubit)
        {
        }

        public override void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void T(Qubit qubit)
        {
        }

        public override void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void TAdjoint(Qubit qubit)
        {
        }

        public override void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
        }

        public override void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
        }

        public override void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
        }

        public override void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
        }

        public override void R1(double theta, Qubit qubit)
        {
        }

        public override void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
        }

        public override void R1Frac(long numerator, long power, Qubit qubit)
        {
        }

        public override void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
        }

        public override void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
        }

        public override void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
        }

        public override void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
        }

        public override void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
        }

        public override Result M(Qubit qubit)
        {
            return Result.Zero;
        }

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            return Result.Zero;
        }

        public override void Reset(Qubit qubit)
        {
        }
    }
}
