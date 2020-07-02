using NewTracer.MetricCollection;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.ExceptionServices;
using static NewTracer.MetricCollectors.WidthTracker;

namespace NewTracer.MetricCollectors
{
    public class WidthTracker : IMetricCollector, IQuantumProcessor
    {
        public class WidthState : IStackRecord
        {
            // Global state metrics

            public double AllocatedQubits { get; set; }

            // Per-invocation metrics

            public double InputWidth { get; set; }

            public double AllocatedAtStart { get; set; }

            public double MaxAllocated { get; set; }

            public double BorrowedQubits { get; set; }

            public double MaxBorrowed { get; set; }
        }

        protected WidthState CurrentState { get; set; }

        public WidthTracker()
        {
            CurrentState = new WidthState();
        }

        public string CollectorName()
        {
            return "Width Tracker";
        }

        public IList<string> Metrics()
        {
           return   new string[]
           {
                "Input Width",
                "Extra Width",
                "Return Width",
                "Borrowed Width"
           };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord savedParentState, IApplyData returned)
        {
            WidthState endState = (WidthState) savedParentState;
            endState.AllocatedQubits = CurrentState.AllocatedQubits;
            // Updating parent state
            endState.MaxAllocated = Math.Max(CurrentState.MaxAllocated, endState.MaxAllocated);
            //TODO: why isn't maxBorrowed maxed?

            double[] values = new[]
            {
                    CurrentState.InputWidth,
                    CurrentState.MaxAllocated - CurrentState.AllocatedAtStart,
                    this.CountQubits(returned),
                    CurrentState.MaxBorrowed
            };
            this.CurrentState = endState;
            return values;
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData inputArgs)
        {
            WidthState savedState = this.CurrentState;
            this.CurrentState = new WidthState
            {
                InputWidth = this.CountQubits(inputArgs),
                AllocatedAtStart = savedState.AllocatedQubits,
                MaxAllocated = savedState.AllocatedQubits,
                BorrowedQubits = 0,
                MaxBorrowed = 0
            };
            return savedState;
        }


        private int CountQubits(IApplyData args)
        {
            return args?.Qubits?.Where(qubit => qubit != null).Count() ?? 0;
        }

        public void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            CurrentState.AllocatedQubits += qubits.Count;
            CurrentState.MaxAllocated = Math.Max(CurrentState.AllocatedQubits, CurrentState.MaxAllocated);
        }

        public void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            CurrentState.AllocatedQubits -= qubits.Count;
        }

        public void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
            CurrentState.AllocatedQubits += allocatedForBorrowingCount;
            CurrentState.MaxAllocated = Math.Max(CurrentState.AllocatedQubits, CurrentState.MaxAllocated);

            CurrentState.BorrowedQubits += (qubits.Length - allocatedForBorrowingCount);
            CurrentState.MaxBorrowed = Math.Max(CurrentState.BorrowedQubits, CurrentState.MaxBorrowed);
        }

        public void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            CurrentState.AllocatedQubits -= releasedOnReturnCount;
            CurrentState.BorrowedQubits -= (qubits.Length - releasedOnReturnCount);
        }

        #region boilerplate

        public void X(Qubit qubit)
        {
            
        }

        public void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void Y(Qubit qubit)
        {
            
        }

        public void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void Z(Qubit qubit)
        {
            
        }

        public void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void SWAP(Qubit qubit1, Qubit qubit2)
        {
            
        }

        public void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            
        }

        public void H(Qubit qubit)
        {
            
        }

        public void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void S(Qubit qubit)
        {
            
        }

        public void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void SAdjoint(Qubit qubit)
        {
            
        }

        public void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void T(Qubit qubit)
        {
            
        }

        public void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void TAdjoint(Qubit qubit)
        {
            
        }

        public void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            
        }

        public void R(Pauli axis, double theta, Qubit qubit)
        {
            
        }

        public void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            
        }

        public void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            
        }

        public void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            
        }

        public void R1(double theta, Qubit qubit)
        {
            
        }

        public void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            
        }

        public void R1Frac(long numerator, long power, Qubit qubit)
        {
            
        }

        public void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            
        }

        public void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            
        }

        public void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            
        }

        public void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            
        }

        public void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            
        }

        public Result M(Qubit qubit)
        {
            return null;   
        }

        public Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            return null;
        }

        public void Reset(Qubit qubit)
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

        public void OnDumpMachine<T>(T location)
        {
            
        }

        public void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
            
        }

        public void OnMessage(string msg)
        {
            
        }

#endregion
    }
}
