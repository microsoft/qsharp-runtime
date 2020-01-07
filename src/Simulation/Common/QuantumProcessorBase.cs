// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// A class that implements IQuantumProcessor that does not do any logic, but is convenient to inherit from.
    /// It throws <see cref="NotImplementedException"/> for most APIs.
    /// </summary>
    public class QuantumProcessorBase : IQuantumProcessor 
    {
        public virtual void X(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Y(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Z(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void SWAP(Qubit qubit1, Qubit qubit2)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            throw new NotImplementedException();
        }

        public virtual void H(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void S(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void SAdjoint(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void T(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void TAdjoint(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void R(Pauli axis, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void R1(double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void R1Frac(long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public virtual void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
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

        public virtual void Reset(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public virtual long StartConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> resultsValues)
        {
            Debug.Assert(measurementResults.Count == resultsValues.Count);

            int equal = 1;

            for (int i = 0; i < measurementResults.Count; i++)
            {
                if (measurementResults[i] != resultsValues[i])
                {
                    equal = 0;
                }
            }

            return equal;
        }

        public virtual long StartConditionalStatement(Result measurementResult, Result resultValue)
        {

            if (measurementResult == resultValue)
            {
                return 1;
            } 
            else
            {
                return 0;
            }
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
