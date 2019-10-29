using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimMeasure : Quantum.Intrinsic.Measure
        {
            private QuantumExecutorSimulator Simulator { get; }


            public QuantumExecutorSimMeasure(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result> Body => (_args) =>
            {
                var (paulis, qubits) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size");
                }

                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
                return Simulator.QuantumExecutor.Measure( newPaulis, newQubits);
            };
        }
    }
}
