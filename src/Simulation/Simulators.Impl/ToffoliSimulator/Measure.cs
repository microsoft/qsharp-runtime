// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the Measure operation for the Toffoli simulator.
        /// </summary>
        public class Measure : Intrinsic.Measure
        {
            private ToffoliSimulator simulator { get; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public Measure(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation returns the joint parity of the 
            /// states of the measured qubits.
            /// That is, Result.One is returned if an odd number of the measured qubits are
            /// in the One state.
            /// </summary>
            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result> __Body__ => (_args) =>
            {
                Qubit? f(Pauli p, Qubit q) =>
                    p switch {
                        Pauli.PauliI => null,
                        Pauli.PauliZ => q,
                        _ => throw new InvalidOperationException($"The Toffoli simulator can only Measure in the Z basis.")
                    };

                var (paulis, qubits) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size");
                }

                var qubitsToMeasure = paulis.Zip(qubits, f).WhereNotNull();

                var result = simulator.GetParity(qubitsToMeasure);

                return result.ToResult();
            };
        }
    }
}
