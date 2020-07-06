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
    public class DepthCounter : QuantumProcessorBase, IMetricCollector, IQuantumProcessor, IQubitTraceSubscriber
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
            return "DepthCounter";
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

        // Currently configured as a T+CZ depth tracker. 
        //TODO: support configuring depth tracking a la old tracer

        public override void Z(Qubit qubit)
        {
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 1 || controls.Length == 2)
            {
                this.RecordQubitUse(controls.Append(qubit), 1);
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
            this.T(qubit);
        }

        public override void SAdjoint(Qubit qubit)
        {
            this.S(qubit);
        }
        public override void T(Qubit qubit)
        {
            this.RecordQubitUse(qubit, this.GetAvailableTime(qubit), 1);
        }

        public override void TAdjoint(Qubit qubit)
        {
            this.T(qubit);
        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
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


        #region qubit time tracking

        public object NewTracingData(long id)
        {
            return 0.0d;
        }

        public double GetAvailableTime(Qubit qubit)
        {
            TraceableQubit q = qubit as TraceableQubit;
            return (double)(q?.ExtractData(this) ?? 0.0); //TODO: hack for ancilla qubits - what should be done instead?
        }

        public void RecordQubitUse(Qubit qubit, double duration)
        {
            double availableTime = this.GetAvailableTime(qubit);
            double finishedAt = availableTime + duration;
            (qubit as TraceableQubit).SetData(this, finishedAt);
        }

        public void RecordQubitUse(Qubit qubit, double time, double duration)
        {
            double availableTime = this.GetAvailableTime(qubit);
            if (time < availableTime)
            {
                throw new QubitTimeMetricsException();
            }
            double finishedAt = time + duration;
            (qubit as TraceableQubit).SetData(this, finishedAt);
        }

        public void RecordQubitUse(IEnumerable<Qubit> qubits, double duration)
        {
            double startTime = MaxAvailableTime(qubits);
            RecordQubitUse(qubits, startTime, duration);
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
    }
}
