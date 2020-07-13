using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Runtime.ExceptionServices;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.GateDecomposition
{
    /// <summary>
    /// A Decomposer is an <see cref="IQuantumProcessor"/> that serves as a wrapper for another
    /// <see cref="IQuantumProcessor"/>, for the purpose of expressing some <see cref="IQuantumProcessor"/>
    /// methods in terms of others. For example, one might 'decompose' all gate operations to a smaller
    /// set of primitive gates. <see cref="DecomposerBase"/> passes through all calls to the
    /// target without modification, but the class is useful for overriding.
    /// </summary>
    /// <typeparam name="TTarget">Type of the target <see cref="IQuantumProcessor"/></typeparam>
    public abstract class DecomposerBase : IQuantumProcessor
    {
        protected IQuantumProcessor Target;

        public DecomposerBase(IQuantumProcessor targetProcessor)
        {
            Target = targetProcessor;
        }

        public virtual void X(Qubit qubit)
        {
            Target.X(qubit);
        }

        public virtual void Y(Qubit qubit)
        {
            Target.Y(qubit);
        }

        public virtual void Z(Qubit qubit)
        {
            Target.Z(qubit);
        }

        public virtual void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledX(controls, qubit);
        }

        public virtual void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledY(controls, qubit);
        }

        public virtual void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledZ(controls, qubit);
        }

        public virtual void H(Qubit qubit)
        {
            Target.H(qubit);
        }

        public virtual void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledH(controls, qubit);
        }

        public virtual void S(Qubit qubit)
        {
            Target.S(qubit);
        }

        public virtual void SAdjoint(Qubit qubit)
        {
            Target.SAdjoint(qubit);
        }

        public virtual void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledS(controls, qubit);
        }

        public virtual void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledSAdjoint(controls, qubit);
        }

        public virtual void T(Qubit qubit)
        {
            Target.T(qubit);
        }

        public virtual void TAdjoint(Qubit qubit)
        {
            Target.TAdjoint(qubit);
        }

        public virtual void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledT(controls, qubit);
        }

        public virtual void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            Target.ControlledTAdjoint(controls, qubit);
        }

        public virtual void SWAP(Qubit qubit1, Qubit qubit2)
        {
            Target.SWAP(qubit1, qubit2);
        }

        public virtual void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            Target.ControlledSWAP(controls, qubit1, qubit2);
        }

        public virtual void R(Pauli axis, double theta, Qubit qubit)
        {
            Target.R(axis, theta, qubit);
        }

        public virtual void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            Target.ControlledR(controls, axis, theta, qubit);
        }

        public virtual void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            Target.RFrac(axis, numerator, power, qubit);
        }

        public virtual void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            Target.ControlledRFrac(controls, axis, numerator, power, qubit);
        }

        public virtual void R1(double theta, Qubit qubit)
        {
            Target.R1(theta, qubit);
        }

        public virtual void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            Target.ControlledR1(controls, theta, qubit);
        }

        public virtual void R1Frac(long numerator, long power, Qubit qubit)
        {
            Target.R1Frac(numerator, power, qubit);
        }

        public virtual void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            Target.ControlledR1Frac(controls, numerator, power, qubit);
        }

        public virtual void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            Target.Exp(paulis, theta, qubits);
        }

        public virtual void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            Target.ControlledExp(controls, paulis, theta, qubits);
        }

        public virtual void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            Target.ExpFrac(paulis, numerator, power, qubits);
        }

        public virtual void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            Target.ControlledExpFrac(controls, paulis, numerator, power, qubits);
        }

        public virtual Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            return Target.Measure(bases, qubits);
        }

        public virtual Result M(Qubit qubit)
        {
            return Target.M(qubit);
        }

        public virtual void Reset(Qubit qubit)
        {
            Target.Reset(qubit);
        }

        public virtual void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            Target.OnAllocateQubits(qubits);
        }

        public virtual void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            Target.OnReleaseQubits(qubits);
        }

        public virtual void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCOunt)
        {
            Target.OnBorrowQubits(qubits, allocatedForBorrowingCOunt);
        }

        public virtual void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            Target.OnReturnQubits(qubits, releasedOnReturnCount);
        }

        public virtual void OnOperationStart(ICallable operation, IApplyData arguments)
        {
            Target.OnOperationStart(operation, arguments);
        }

        public virtual void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            Target.OnOperationEnd(operation, arguments);
        }

        public virtual void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
            Target.Assert(bases, qubits, result, msg);
        }

        public virtual void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
            Target.AssertProb(bases, qubits, probabilityOfZero, msg, tol);
        }

        public virtual void OnFail(ExceptionDispatchInfo exceptionDispatchInfo)
        {
            Target.OnFail(exceptionDispatchInfo);
        }

        public virtual void OnDumpMachine<T>(T location)
        {
            Target.OnDumpMachine(location);
        }

        public virtual void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
            Target.OnDumpRegister(location, qubits);
        }

        public virtual void OnMessage(string msg)
        {
            Target.OnMessage(msg);
        }

        public virtual long StartConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> resultsValues)
        {
            return Target.StartConditionalStatement(measurementResults, resultsValues);
        }

        public virtual long StartConditionalStatement(Result measurementResult, Result resultValue)
        {
            return Target.StartConditionalStatement(measurementResult, resultValue);
        }

        public virtual bool RunThenClause(long statement)
        {
            return Target.RunThenClause(statement);
        }

        public virtual bool RepeatThenClause(long statement)
        {
            return Target.RepeatThenClause(statement);
        }

        public virtual bool RunElseClause(long statement)
        {
            return Target.RunElseClause(statement);
        }

        public virtual bool RepeatElseClause(long statement)
        {
            return Target.RepeatElseClause(statement);
        }

        public virtual void EndConditionalStatement(long statement)
        {
            Target.EndConditionalStatement(statement);
        }
    }
}
