// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation flips a target qubit
        /// if the respective rotation is effectively an X gate.
        /// </summary>
        public void Exp__Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            if (targets == null) return;

            this.CheckQubits(targets, "targets");

            if (targets.Length != paulis.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis,targets), must be of same size");
            }

            for (var i = 0; i < targets.Length; i++)
            {
                var (isX, safe) = CheckRotation(paulis[i], angle);
                if (isX)
                {
                    this.State[targets[i].Id] = !this.State[targets[i].Id];
                }
            }
        }

        /// <summary>
        /// The implementation of the adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, this operation is self-adjoint.
        /// </summary>
        public void Exp__AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets) => Exp__Body(paulis, angle, targets);

        /// <summary>
        /// The implementation of the controlled specialization of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit
        /// if the rotation is effectively an X gate and all of the control qubits
        /// are in the One state.
        /// </summary>
        public void Exp__ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            if (targets == null) return;

            this.CheckControlQubits(controls, targets);

            if (targets.Length != paulis.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis,qubits), must be of same size");
            }

            for (var i = 0; i < targets.Length; i++)
            {
                var (id, safe) = CheckRotation(paulis[i], angle);
                if (!safe)
                {
                    throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
                }
                // We never need to do anything since only the identity is safe to control
            }
        }

        /// <summary>
        /// The implementation of the controlled adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, the controlled specialization is self-adjoint.
        /// </summary>
        public void Exp__ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets) => Exp__ControlledBody(controls, paulis, angle, targets);
    }
}
