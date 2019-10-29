using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimRelease : Intrinsic.Release
        {
            private readonly QuantumExecutorSimulator sim;
            public QuantumExecutorSimRelease(QuantumExecutorSimulator m) : base(m){
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                sim.QuantumExecutor.OnReleaseQubits(new QArray<Qubit>(q));
                sim.QubitManager.Release(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.QuantumExecutor.OnReleaseQubits(qubits);
                sim.QubitManager.Release(qubits);
            }
        }
    }
}