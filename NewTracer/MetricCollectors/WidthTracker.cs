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
    public class WidthTracker : QuantumProcessorBase, IMetricCollector, IQuantumProcessor
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
            return "WidthCounter";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "InputWidth",
                "ExtraWidth",
                "ReturnWidth",
                "BorrowedWidth"
            };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord savedParentState, IApplyData returned)
        {
            WidthState endState = (WidthState)savedParentState;
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

        public override void Z(Qubit qubit)
        {

        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1 || controls.Length == 2)
            {

            }
            else
            {
                throw new NotImplementedException();
            }
        }
        public override void H(Qubit qubit)
        {
        }

        public override void S(Qubit qubit)
        {

        }

        public override void SAdjoint(Qubit qubit)
        {

        }
        public override void T(Qubit qubit)
        {

        }

        public override void TAdjoint(Qubit qubit)
        {

        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {

        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliZ)
            {

            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            return null;
        }

        public override Result M(Qubit qubit)
        {
            return null;
        }

        #endregion
    }
}
