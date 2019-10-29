using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    /// <summary>
    /// An example of IQuantumExecutor that throws <see cref="NotImplementedException"/> for every call.
    /// </summary>
    class EmptyQuantumExecutor : IQuantumExecutor
    {
        public virtual void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
        }

        public virtual void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
        }

        public virtual void ClassicallyControlled(Result measurementResult, Action onZero, Action onOne)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledSAdj(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledTAdj(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void H(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual Result M(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void OnAllocateQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void OnBorrowQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void OnDumpMachine<T>(T location)
        {
        }

        public virtual void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
        }

        public virtual void OnMessage(string msg)
        {
        }

        public virtual void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
        }

        public virtual void OnOperationStart(ICallable operation, IApplyData arguments)
        {
        }

        public virtual void OnFail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionDispatchInfo)
        {
        }

        public virtual void OnReleaseQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void OnReturnQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void R(Pauli axis, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void R1(double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void R1Frac(long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Reset(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void S(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void SAdj(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void SWAP(Qubit qubit1, Qubit qubit2)
        {
            throw new NotImplementedException();
        }

        public virtual void T(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void TAdj(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void X(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Y(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Z(Qubit qubit)
        {
            throw new NotImplementedException();
        }
    }
}
