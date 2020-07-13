using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    //TODO: document
    public class GateTracker : QuantumProcessorBase, IMetricCollector, IQuantumProcessor
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

        public GateTracker()
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

        public override void Z(Qubit qubit)
        {
            //no-op
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
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
        public override void H(Qubit qubit)
        {
            //no-op
        }

        public override void S(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public override void SAdjoint(Qubit qubit)
        {
            this.CurrentState.T++;
        }
        public override void T(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public override void TAdjoint(Qubit qubit)
        {
            this.CurrentState.T++;
        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //no-op
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
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

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            this.CurrentState.Measure++;
            return null;
        }

        public override Result M(Qubit qubit)
        {
            this.CurrentState.Measure++;
            return null;
        }
    }
}