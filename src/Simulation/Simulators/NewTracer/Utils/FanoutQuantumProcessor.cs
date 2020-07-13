using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.ExceptionServices;
using Microsoft.Quantum.Simulation.QuantumProcessor;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.Utils
{
    /// <summary>
    /// Allows multiple <see cref="IQuantumProcessor"/>'s to recieve notifications from a 
    /// <see cref="QuantumProcessorDispatcher"/>.
    /// </summary>
    public class FanoutQuantumProcessor : IQuantumProcessor
    {
        /// <summary>
        /// <see cref="IQuantumProcessor"/> this <see cref="FanoutQuantumProcessor"/> wraps.
        /// </summary>
        protected IQuantumProcessor Core;

        /// <summary>
        /// Children that recieve <see cref="IQuantumProcessor"/> method dispatches but whose return values are ignored.
        /// </summary>
        protected List<IQuantumProcessor> Sinks;

        /// <summary>
        /// Takes a single <paramref name="core"/> <see cref="IQuantumProcessor"/> whose measurement reults 
        /// are used, and a number of <paramref name="sinks"/> who also receieve <see cref="IQuantumProcessor"/> 
        /// method dispatches.
        /// </summary>
        public FanoutQuantumProcessor(IQuantumProcessor core = null, IEnumerable<IQuantumProcessor> sinks = null)
        {
            this.Core = core ?? new QuantumProcessorBase();
            this.Sinks = sinks?.ToList() ?? new List<IQuantumProcessor>();
        }

        /// <summary>
        /// Registers sinks for receiving <see cref="IQuantumProcessor"/> method calls. Duplicates are ignored.
        /// </summary>
        /// <param name="sinks"></param>
        public virtual void RegisterSinks(IEnumerable<IQuantumProcessor> sinks)
        {
            if (sinks == null) { throw new ArgumentNullException(nameof(sinks)); }
            foreach (IQuantumProcessor sink in sinks)
            {
                if (sink != this.Core && !this.Sinks.Contains(sink))
                {
                    this.Sinks.Add(sink);
                }
            }
        }

        public IEnumerable<IQuantumProcessor> AllChildProcessors()
        {
            yield return this.Core;
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                yield return sink;
            }
        }

        public virtual void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.Assert(bases, qubits, result, msg);
            }
        }

        public virtual void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.AssertProb(bases, qubits, probabilityOfZero, msg, tol);
            }
        }

        public virtual void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledExp(controls, paulis, theta, qubits);
            }
        }

        public virtual void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledExpFrac(controls, paulis, numerator, power, qubits);
            }
        }

        public virtual void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledH(controls, qubit);
            }
        }

        public virtual void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledR(controls, axis, theta, qubit);
            }
        }

        public virtual void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledR1(controls, theta, qubit);
            }
        }

        public virtual void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledR1Frac(controls, numerator, power, qubit);
            }
        }

        public virtual void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledRFrac(controls, axis, numerator, power, qubit);
            }
        }

        public virtual void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledS(controls, qubit);
            }
        }

        public virtual void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledSAdjoint(controls, qubit);
            }
        }

        public virtual void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledSWAP(controls, qubit1, qubit2);
            }
        }

        public virtual void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledT(controls, qubit);
            }
        }

        public virtual void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledTAdjoint(controls, qubit);
            }
        }

        public virtual void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledX(controls, qubit);
            }
        }

        public virtual void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledY(controls, qubit);
            }
        }

        public virtual void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ControlledZ(controls, qubit);
            }
        }

        public virtual void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.Exp(paulis, theta, qubits);
            }
        }

        public virtual void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.ExpFrac(paulis, numerator, power, qubits);
            }
        }

        public virtual void H(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.H(qubit);
            }
        }

        public virtual void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnAllocateQubits(qubits);
            }
        }

        public virtual void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnBorrowQubits(qubits, allocatedForBorrowingCount);
            }
        }

        public virtual void OnMessage(string msg)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnMessage(msg);
            }
        }

        public virtual void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnOperationEnd(operation, arguments);
            }
        }

        public virtual void OnOperationStart(ICallable operation, IApplyData arguments)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnOperationStart(operation, arguments);
            }
        }

        public virtual void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnReleaseQubits(qubits);
            }
        }

        public virtual void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnReturnQubits(qubits, releasedOnReturnCount);
            }
        }

        public virtual void R(Pauli axis, double theta, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.R(axis, theta, qubit);
            }
        }

        public virtual void R1(double theta, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.R1(theta, qubit);
            }
        }

        public virtual void R1Frac(long numerator, long power, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.R1Frac(numerator, power, qubit);
            }
        }

        public virtual void Reset(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.Reset(qubit);
            }
        }

        public virtual void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.RFrac(axis, numerator, power, qubit);
            }
        }

        public virtual void S(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.S(qubit);
            }
        }

        public virtual void SAdjoint(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.SAdjoint(qubit);
            }
        }

        public virtual void SWAP(Qubit qubit1, Qubit qubit2)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.SWAP(qubit1, qubit2);
            }
        }

        public virtual void T(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.T(qubit);
            }
        }

        public virtual void TAdjoint(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.TAdjoint(qubit);
            }
        }

        public virtual void X(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.X(qubit);
            }
        }

        public virtual void Y(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.Y(qubit);
            }
        }

        public virtual void Z(Qubit qubit)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.Z(qubit);
            }
        }

        public Result M(Qubit qubit)
        {
            Result result = Core.M(qubit);
            foreach(IQuantumProcessor sink in this.Sinks)
            {
               sink.M(qubit);
            }
            return result;
        }

        public Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            Result result = Core.Measure(bases, qubits);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.Measure(bases, qubits);
            }
            return result;
        }

        public virtual void OnFail(ExceptionDispatchInfo exceptionDispatchInfo)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnFail(exceptionDispatchInfo);
            }
        }

        public virtual void OnDumpMachine<T>(T location)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnDumpMachine(location);
            }
        }

        public virtual void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.OnDumpRegister(location, qubits);
            }
        }

        public long StartConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> resultsValues)
        {
            long result = Core.StartConditionalStatement(measurementResults, resultsValues);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.StartConditionalStatement(measurementResults, resultsValues);
            }
            return result;
        }

        public long StartConditionalStatement(Result measurementResult, Result resultValue)
        {
            long result = Core.StartConditionalStatement(measurementResult, resultValue);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.StartConditionalStatement(measurementResult, resultValue);
            }
            return result;
        }

        public bool RunThenClause(long statement)
        {
            bool result = Core.RunThenClause(statement);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.RunThenClause(statement);
            }
            return result;
        }

        public bool RepeatThenClause(long statement)
        {
            bool result = Core.RepeatThenClause(statement);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.RepeatThenClause(statement);
            }
            return result;
        }

        public bool RunElseClause(long statement)
        {
            bool result = Core.RunElseClause(statement);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.RunElseClause(statement);
            }
            return result;
        }

        public bool RepeatElseClause(long statement)
        {
            bool result = Core.RepeatElseClause(statement);
            foreach (IQuantumProcessor sink in this.Sinks)
            {
                sink.RepeatElseClause(statement);
            }
            return result;
        }

        public virtual void EndConditionalStatement(long statement)
        {
            foreach (IQuantumProcessor child in this.AllChildProcessors())
            {
                child.EndConditionalStatement(statement);
            }
        }
    }
}