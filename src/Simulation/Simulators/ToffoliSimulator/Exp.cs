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
        public Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_Body() => (_args) =>
        {
            var (bases, angle, qubits) = _args;

            if (qubits == null) return QVoid.Instance;

            this.CheckQubits(qubits, "qubits");

            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for {GetType().Name} (paulis,qubits), must be of same size");
            }

            for (var i = 0; i < qubits.Length; i++)
            {
                var (isX, safe) = CheckRotation(bases[i], angle);
                if (isX)
                {
                    this.State[qubits[i].Id] = !this.State[qubits[i].Id];
                }
            }

            return QVoid.Instance;
        };

        /// <summary>
        /// The implementation of the adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, this operation is self-adjoint.
        /// </summary>
        public Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_AdjointBody() => Exp_Body();

        /// <summary>
        /// The implementation of the controlled specialization of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit
        /// if the rotation is effectively an X gate and all of the control qubits
        /// are in the One state.
        /// </summary>
        public Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledBody() => (_args) =>
        {
            var (ctrls, (bases, angle, qubits)) = _args;

            if (qubits == null) return QVoid.Instance;

            this.CheckControlQubits(ctrls, qubits);

            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for {GetType().Name} (paulis,qubits), must be of same size");
            }

            for (var i = 0; i < qubits.Length; i++)
            {
                var (id, safe) = CheckRotation(bases[i], angle);
                if (!safe)
                {
                    throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
                }
                // We never need to do anything since only the identity is safe to control
            }

            return QVoid.Instance;
        };

        /// <summary>
        /// The implementation of the controlled adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, the controlled specialization is self-adjoint.
        /// </summary>
        public Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledAdjointBody() => Exp_ControlledBody();
    }
}
