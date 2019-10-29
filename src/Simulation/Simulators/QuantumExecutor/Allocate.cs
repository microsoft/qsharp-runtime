using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimAllocate : Intrinsic.Allocate
        {
            private readonly QuantumExecutorSimulator sim;
            public QuantumExecutorSimAllocate(QuantumExecutorSimulator m) : base(m){
                sim = m;
            }

            public override Qubit Apply()
            {
                IQArray<Qubit> qubits = sim.QubitManager.Allocate(1);
                sim.QuantumExecutor.OnAllocateQubits(qubits);
                return qubits[0];
            }

            public override IQArray<Qubit> Apply( long count )
            {
                IQArray<Qubit> qubits = sim.QubitManager.Allocate(count);
                sim.QuantumExecutor.OnAllocateQubits(qubits);
                return qubits;
            }
        }
    }
}