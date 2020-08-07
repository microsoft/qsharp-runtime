using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    //TODO: document
    public class NewGateTracker : INewDecompositionTarget, IMetricCollector
    {
        /// <summary>
        /// Stores a count for all base gates used during program execution.
        /// </summary>
        public class PrimitiveGateCount : IStackRecord
        {
            public double CZ { get; set; }

            public double CCZ { get; set; }

            public double RZ { get; set; }

            public double Measure { get; set; }

            public double T { get; set; }
        }

        protected PrimitiveGateCount CurrentState { get; set; }

        //TODO: convert to generic gate tracker, tacking in array of primitive gate names
        public NewGateTracker()
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
                "CZ",
                "CCZ",
                "RZ",
                "Measure",
                "T"
            };
        }

        public double[] OutputMetricsOnOperationEnd(IStackRecord savedState, IApplyData returned)
        {
            PrimitiveGateCount prevState = (PrimitiveGateCount)savedState;
            return  new double[]
            {
                    CurrentState.CZ - prevState.CZ,
                    CurrentState.CCZ - prevState.CCZ,
                    CurrentState.RZ - prevState.RZ,
                    CurrentState.Measure - prevState.Measure,
                    CurrentState.T - prevState.T
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
                Measure = CurrentState.Measure
            };
        }

        //
        // Primite operations that the GateCounter expects other operations to be decomposed to.
        //

        public void Z(Qubit qubit)
        {
        }

        public void CZ(Qubit control, Qubit qubit)
        {
            this.CurrentState.CZ++;
        }

        public void CCZ(Qubit control1, Qubit control2, Qubit qubit)
        {
            this.CurrentState.CCZ++;
        }

        public void H(Qubit qubit)
        {
        }

        public void S(Qubit qubit)
        {
        }

        public void SAdjoint(Qubit qubit)
        {
        }

        public void T(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void TAdjoint(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public void Rz(double theta, Qubit qubit)
        {
            this.CurrentState.RZ++;
        }

        public void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.CurrentState.Measure++;
        }

        public void M(Qubit qubit)
        {
            this.CurrentState.Measure++;
        }
        
        bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
    }
}