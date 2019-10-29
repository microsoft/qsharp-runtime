namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    using Microsoft.Quantum.Simulation.Core;

    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimReturn : Intrinsic.Return
        {
            private readonly QuantumExecutorSimulator sim;
            public QuantumExecutorSimReturn(QuantumExecutorSimulator m) : base(m){
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                sim.QuantumExecutor.OnReturnQubits(new QArray<Qubit>(q));
                sim.QubitManager.Return(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.QuantumExecutor.OnReturnQubits(qubits);
                sim.QubitManager.Return(qubits);
            }
        }
    }
}