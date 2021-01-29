// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// A class that implements IQuantumProcessor that does not do any logic, but is convenient to inherit from.
    /// It throws <see cref="UnsupportedOperationException"/> for most APIs.
    /// </summary>
    public class QuantumProcessorBase : IQuantumProcessor 
    {
        public virtual void X(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void Y(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void Z(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void SWAP(Qubit qubit1, Qubit qubit2)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void H(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void S(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void SAdjoint(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void T(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void TAdjoint(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void R(Pauli axis, double theta, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void R1(double theta, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void R1Frac(long numerator, long power, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new UnsupportedOperationException();
        }

        public virtual Result M(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            throw new UnsupportedOperationException();
        }

        public virtual void Reset(Qubit qubit)
        {
            throw new UnsupportedOperationException();
        }

        public virtual long StartConditionalStatement(IQArray<Result> results1, IQArray<Result> results2)
        {
            if (results1 == null) { return results2 == null ? 1 : 0; };
            if (results1.Count != results2?.Count) { return 0; };
            return results1.Zip(results2, (r1, r2) => (r1, r2)).Any(pair => pair.r1 != pair.r2) ? 0 : 1;
        }

        public virtual long StartConditionalStatement(Result result1, Result result2)
        {
            return result1 == result2 ? 1 : 0;
        }

        public virtual bool RunThenClause(long statement)
        {
            return (statement != 0);
        }

        public virtual bool RepeatThenClause(long statement)
        {
            return false;
        }

        public virtual bool RunElseClause(long statement)
        {
            return (statement == 0);
        }

        public virtual bool RepeatElseClause(long statement)
        {
            return false;
        }

        public virtual void EndConditionalStatement(long id)
        {
        }

        public virtual void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
        }

        public virtual void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
        }

        public virtual void OnOperationStart(ICallable operation, IApplyData arguments)
        {
        }

        public virtual void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
        }

        public virtual void OnFail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionDispatchInfo)
        {
        }

        public virtual void OnAllocateQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void OnReleaseQubits(IQArray<Qubit> qubits)
        {
        }

        public virtual void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
        }

        public virtual void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
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

    }
}
