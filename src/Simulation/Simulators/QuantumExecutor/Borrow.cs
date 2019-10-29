using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{ 
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimBorrow : Intrinsic.Borrow
        {
            private readonly QuantumExecutorSimulator sim;
            public QuantumExecutorSimBorrow(QuantumExecutorSimulator m) : base(m){
                sim = m;
            }

            public override Qubit Apply()
            {
                IQArray<Qubit> qubits = sim.QubitManager.Borrow(1);
                sim.QuantumExecutor.OnBorrowQubits(qubits);
                return qubits[0];
            }

            public override IQArray<Qubit> Apply( long count )
            {
                IQArray<Qubit> qubits = sim.QubitManager.Borrow(1);
                sim.QuantumExecutor.OnBorrowQubits(qubits);
                return qubits;
            }
        }
    }
}