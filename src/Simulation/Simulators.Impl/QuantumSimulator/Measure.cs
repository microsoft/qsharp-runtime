// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public Func<(IQArray<Pauli>, IQArray<Qubit>), Result> Measure_Body() => (_args) =>
        {
            var (paulis, qubits) = _args;

            this.CheckQubits(qubits);
            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size");
            }
            if (qubits.Length == 1)
            {
                // When we are operating on a single qubit we will collapse the state, so mark
                // that qubit as measured.
                qubits[0].IsMeasured = true;
            }
            return Measure(this.Id, (uint)paulis.Length, paulis.ToArray(), qubits.GetIds()).ToResult();
        };
    }
}
