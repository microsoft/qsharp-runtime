// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual Result Measure__Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            this.CheckQubits(targets);
            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Measure (paulis, targets), must be of same size");
            }
            if (targets.Length == 1)
            {
                // When we are operating on a single qubit we will collapse the state, so mark
                // that qubit as measured.
                targets[0].IsMeasured = true;
            }
            return Measure(this.Id, (uint)paulis.Length, paulis.ToArray(), targets.GetIds()).ToResult();
        }
    }
}
