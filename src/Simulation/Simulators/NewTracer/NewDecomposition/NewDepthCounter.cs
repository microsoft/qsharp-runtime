using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    //TODO: naming?
    public class NewDepthCounter : DepthCounterBase, INewDecompositionTarget
    {
        protected NewTraceGateTimes TraceGateTimes;

        public NewDepthCounter(NewTraceGateTimes gateTimes)
        {
            this.TraceGateTimes = gateTimes.Clone();
        }

        public void Z(Qubit qubit)
        {
        }

        public void CZ(Qubit control, Qubit qubit)
        {
            this.RecordQubitUse(TraceGateTimes.CZ, control, qubit);
        }

        public void CCZ(Qubit control1, Qubit control2, Qubit qubit)
        {
            this.RecordQubitUse(TraceGateTimes.CCZ, control1, control2, qubit);
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
            this.RecordQubitUse(TraceGateTimes.T, qubit);
        }

        public void TAdjoint(Qubit qubit)
        {
            this.RecordQubitUse(TraceGateTimes.T, qubit);
        }

        public void Rz(double theta, Qubit qubit)
        {
            this.RecordQubitUse(TraceGateTimes.Rz, qubit);
        }

        public void Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            foreach (Qubit qubit in qubits)
            {
                this.M(qubit); //TODO: verify
            }
        }

        public void M(Qubit qubit)
        {
            this.RecordQubitUse(TraceGateTimes.M, qubit);
        }
    }
}
