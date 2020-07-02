using NewTracer.MetricCollection;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using NewTracer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.ExceptionServices;
using static NewTracer.MetricCollectors.DepthCounter;

namespace NewTracer.MetricCollectors
{
    public class DepthCounter : IMetricCollector, IQuantumProcessor, IQubitTraceSubscriber
    {
        public class DepthState : IStackRecord
        {
            public Qubit[] InputQubits { get; set; }

            public double MinStartTime { get; set; }

            public double MaxStartTime { get; set; }

            public double ReleasedQubitsTime { get; set; }

            public double ReturnedQubitsTime { get; set; }
        }

        protected DepthState CurrentState { get; set; }

        public DepthCounter()
        {
            this.CurrentState = new DepthState();
        }

        public string CollectorName()
        {
            return "Depth Counter";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "Depth",
                "StartTimeDifference"
            };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord savedState, IApplyData returned)
        {
            DepthState endState = (DepthState) savedState;
            endState.ReleasedQubitsTime = Math.Max(CurrentState.ReleasedQubitsTime, endState.ReleasedQubitsTime);
            endState.ReturnedQubitsTime = Math.Max(CurrentState.ReturnedQubitsTime, endState.ReturnedQubitsTime);

            double invocationReturnQubitsAvailableTime = this.MaxAvailableTime(DepthCounter.ExtractQubits(returned));
            double invocationInputQubitsAvailableTime = this.MaxAvailableTime(CurrentState.InputQubits);
            double invocationEndTime = Math.Max(
                Math.Max(invocationInputQubitsAvailableTime, invocationReturnQubitsAvailableTime),
                Math.Max(CurrentState.ReleasedQubitsTime, CurrentState.ReturnedQubitsTime)
            );

            double[] output = new double[]
            {
                    invocationEndTime - CurrentState.MaxStartTime,
                    CurrentState.MaxStartTime - CurrentState.MinStartTime
            };
            this.CurrentState = endState;
            return output;
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData inputArgs)
        {
            DepthState savedState = this.CurrentState;
            IEnumerable<Qubit> inputQubits = DepthCounter.ExtractQubits(inputArgs);
            this.CurrentState =  new DepthState
            {
                InputQubits = inputQubits.ToArray(),
                MinStartTime = this.MinAvailableTime(inputQubits),
                MaxStartTime = this.MaxAvailableTime(inputQubits),
                ReleasedQubitsTime = 0,
                ReturnedQubitsTime = 0
            };
            return savedState;
        }

        public void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            double returnedTime = this.MaxAvailableTime(qubits);
            this.CurrentState.ReturnedQubitsTime = Math.Max(this.CurrentState.ReturnedQubitsTime, returnedTime);
        }

        public void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            double releasedTime = this.MaxAvailableTime(qubits);
            this.CurrentState.ReleasedQubitsTime = Math.Max(this.CurrentState.ReleasedQubitsTime, releasedTime);
        }

        public static IEnumerable<Qubit> ExtractQubits(IApplyData args)
        {
            return args?.Qubits?.Where(qubit => qubit != null) ?? new Qubit[] { };
        }

        //
        // Primite operations that the DepthCounter expects other operations to be decomposed to.
        //

        // Currently configured as a T-depth tracker. 
        //TODO: support configuring depth tracking a la old tracer

        public void Z(Qubit qubit)
        {
        }

        public void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1)
            {
            }
            else if (controls.Length == 2)
            {
            }
            else
            {
                throw new NotImplementedException();
            }
        }
        public void H(Qubit qubit)
        {
        }

        public void S(Qubit qubit)
        {
            this.T(qubit);
        }

        public void SAdjoint(Qubit qubit)
        {
            this.S(qubit);
        }
        public void T(Qubit qubit)
        {
            this.RecordQubitUse(qubit, this.GetAvailableTime(qubit), 1);
        }

        public void TAdjoint(Qubit qubit)
        {
            this.T(qubit);
        }

        public void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
        }

        public void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliZ)
            {
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            return null;
        }

        public Result M(Qubit qubit)
        {
            return null;
        }


        #region qubit time tracking

        public object NewTracingData(long id)
        {
            return 0.0d;
        }

        public double GetAvailableTime(Qubit qubit)
        {
            return (double)(qubit as TraceableQubit).ExtractData(this);
        }

        public void RecordQubitUse(Qubit qubit, double time, double duration)
        {
            double availableTime = this.GetAvailableTime(qubit);
            if (availableTime < time)
            {
                throw new QubitTimeMetricsException();
            }
            double finishedAt = time + duration;
            (qubit as TraceableQubit).SetData(this, finishedAt);
        }

        public void RecordQubitUse(IEnumerable<Qubit> qubits, double time, double duration)
        {
            foreach (Qubit qubit in qubits)
            {
                this.RecordQubitUse(qubit, time, duration);
            }
        }

        public double MaxAvailableTime(IEnumerable<Qubit> qubits)
        {
            double max = 0;
            foreach (Qubit qubit in qubits)
            {
                max = Math.Max(max, this.GetAvailableTime(qubit));
            }
            return max;
        }

        public double MinAvailableTime(IEnumerable<Qubit> qubits)
        {
            double min = Double.MaxValue;
            foreach (Qubit qubit in qubits)
            {
                min = Math.Min(min, this.GetAvailableTime(qubit));
            }
            return min != Double.MaxValue ? min : 0;
        }

        #endregion

        //
        // All other operations must be decomposed to primitives first.
        // Otherwise a NotImplemntedException will be thrown.
        //

        #region boilerplate

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
        #endregion
    }
}
