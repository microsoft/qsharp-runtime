// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation returns the joint parity of the 
        /// states of the measured qubits.
        /// That is, Result.One is returned if an odd number of the measured qubits are
        /// in the One state.
        /// </summary>
        Result IIntrinsicMeasure.Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            Qubit? f(Pauli p, Qubit q) =>
                p switch {
                    Pauli.PauliI => null,
                    Pauli.PauliZ => q,
                    _ => throw new InvalidOperationException($"The Toffoli simulator can only Measure in the Z basis.")
                };

            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Measure (paulis, targets), must be of same size");
            }

            var qubitsToMeasure = paulis.Zip(targets, f).WhereNotNull();

            var result = this.GetParity(qubitsToMeasure);

            return result.ToResult();
        }
    }
}
