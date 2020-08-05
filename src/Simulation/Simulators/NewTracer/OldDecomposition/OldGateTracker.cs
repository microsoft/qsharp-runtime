using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    public class OldGateTracker : IMetricCollector, IOldDecompositionTarget
    {
        /// <summary>
        /// Stores a count for all base gates used during program execution.
        /// </summary>
        public class PrimitiveGateCount : IStackRecord
        {
            public double CNOT { get; set; }

            public double QubitClifford { get; set; }

            public double R { get; set; }

            public double Measure { get; set; }

            public double T { get; set; }
        }

        protected PrimitiveGateCount CurrentState { get; set; }

        public OldGateTracker()
        {
            this.CurrentState = new PrimitiveGateCount();
        }

        public string CollectorName()
        {
            return "PrimitiveOperationsCounter";
        }

        public IList<string> Metrics()
        {
            return new string[]
            {
                "CNOT",
                "QubitClifford",
                "R",
                "Measure",
                "T"
            };
        }


        public double[] OutputMetricsOnOperationEnd(IStackRecord savedState, IApplyData returned)
        {
            PrimitiveGateCount prevState = (PrimitiveGateCount)savedState;
            return new double[]
            {
                    CurrentState.CNOT - prevState.CNOT,
                    CurrentState.QubitClifford - prevState.QubitClifford,
                    CurrentState.R - prevState.R,
                    CurrentState.Measure - prevState.Measure,
                    CurrentState.T - prevState.T
            };
        }

        public IStackRecord SaveRecordOnOperationStart(IApplyData _)
        {
            return new PrimitiveGateCount
            {
                R = CurrentState.R,
                CNOT = CurrentState.CNOT,
                T = CurrentState.T,
                QubitClifford = CurrentState.QubitClifford,
                Measure = CurrentState.Measure
            };
        }

        public void CX(Qubit control, Qubit qubit)
        {
            this.CurrentState.CNOT++;
        }

        public void QubitClifford(int id, Pauli pauli, Qubit qubit)
        {
            this.CurrentState.QubitClifford++;
        }

        public void R(Pauli pauli, double angle, Qubit qubit)
        {
            this.CurrentState.R++;
        }

        public void T(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void Measure(IQArray<Pauli> observable, IQArray<Qubit> target)
        {
            this.CurrentState.Measure++;
        }

        public bool SupportsTarget(ITracerTarget target)
        {
            return false;
        }
    }
}
