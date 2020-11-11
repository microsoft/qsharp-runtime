// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<(IQArray<Pauli>, IQArray<Qubit>), Result> Measure_Body() => (_args) =>
        {
            (IQArray<Pauli> paulis, IQArray<Qubit> qubits) = _args;

            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException(
                    $"Both input arrays for Measure (paulis,qubits), must be of same size");
            }

            CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);

            return this.QuantumProcessor.Measure( newPaulis, newQubits);
        };
    }
}
