using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.ExceptionServices;
using NewTracer.MetricCollection;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using static NewTracer.MetricCollectors.GateTracker;

namespace NewTracer.MetricCollectors
{
    //TODO: document
    public class GateTracker : IMetricCollector, IQuantumProcessor
    {
        /// <summary>
        /// Stores a count for all base gates (see <see cref="BaseGates"/>) used during program execution.
        /// </summary>
        public class PrimitiveGateCount : IStackRecord
        {
            public double RZ { get; set; }

            public double CCZ { get; set; }

            public double T { get; set; }

            public double CZ { get; set; }

            public double M { get; set; }
        }

        protected PrimitiveGateCount CurrentState { get; set; }

        public GateTracker()
        {
            this.CurrentState = new PrimitiveGateCount();
        }   

        public string CollectorName()
        {
            return "Gate Tracker";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "RZ",
                "CCZ",
                "T",
                "CZ",
                "M"
            };
        }


        public double[] OutputMetricsOnOperationEnd(IStackRecord savedState, IApplyData returned)
        {
            PrimitiveGateCount prevState = (PrimitiveGateCount)savedState;
            return  new double[]
            {
                    CurrentState.RZ - prevState.RZ,
                    CurrentState.CCZ - prevState.CCZ,
                    CurrentState.T - prevState.T,
                    CurrentState.CZ - prevState.CZ,
                    CurrentState.M - prevState.M
            };
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData _)
        {
            return new PrimitiveGateCount
            {
                RZ = CurrentState.RZ,
                CCZ = CurrentState.CCZ,
                T = CurrentState.T,
                CZ = CurrentState.CZ,
                M = CurrentState.M
            };
        }


        //
        // Primite operations that the GateCounter expects other operations to be decomposed to.
        //

        public void Z(Qubit qubit)
        {
            //no-op
        }

        public void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1)
            {
                this.CurrentState.CZ++;
            }
            else if (controls.Length == 2)
            {
                this.CurrentState.CCZ++;
            }
            else
            {
                throw new NotImplementedException();
            }
        }
        public void H(Qubit qubit)
        {
            //no-op
        }

        public void S(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void SAdjoint(Qubit qubit)
        {
            this.CurrentState.T++;
        }
        public void T(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void TAdjoint(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
        }

        public void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliZ)
            {
                this.CurrentState.RZ++;
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            //TODO: how does this translate?
            this.CurrentState.M++;
            return null;
        }

        public Result M(Qubit qubit)
        {
            this.CurrentState.M++;
            return null;
        }

        #region boilerplate

        //
        // All other operations must be decomposed to primitives first.
        // Otherwise a NotImplemntedException will be thrown.
        //


        public void X(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void Y(Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            throw new NotImplementedException();
        }

        public void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void R1(double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void R1Frac(long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            throw new NotImplementedException();
        }

        public void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        public void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            throw new NotImplementedException();
        }

        //
        // As this is a listener, all non-gate IQuantumProcessor calls are no-ops
        //

        public void Reset(Qubit qubit)
        {

        }

        public void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {

        }

        public void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {

        }

        public void OnOperationStart(ICallable operation, IApplyData arguments)
        {

        }

        public void OnOperationEnd(ICallable operation, IApplyData arguments)
        {

        }

        public void OnFail(ExceptionDispatchInfo exceptionDispatchInfo)
        {

        }

        public void OnAllocateQubits(IQArray<Qubit> qubits)
        {

        }

        public void OnReleaseQubits(IQArray<Qubit> qubits)
        {

        }

        public void OnDumpMachine<T>(T location)
        {

        }

        public void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {

        }

        public void OnMessage(string msg)
        {

        }

        public long StartConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> resultsValues)
        {
            return -1;
        }

        public long StartConditionalStatement(Result measurementResult, Result resultValue)
        {
            return -1;
        }

        public bool RunThenClause(long statement)
        {
            return false;
        }

        public bool RepeatThenClause(long statement)
        {
            return false;
        }

        public bool RunElseClause(long statement)
        {
            return false;
        }

        public bool RepeatElseClause(long statement)
        {
            return false;
        }

        public void EndConditionalStatement(long statement)
        {

        }

        public void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {

        }

        public void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {

        }

        #endregion
    }
}