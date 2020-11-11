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
        /// For the Toffoli simulator, the implementation flips the target qubit
        /// if the rotation is effectively an X gate.
        /// </summary>
        public Func<(Pauli, double, Qubit), QVoid> R_Body() => (_args) =>
        {
            var (basis, angle, q1) = _args;

            if (q1 == null) return QVoid.Instance;

            this.CheckQubit(q1, "q1");

            var (isX, safe) = CheckRotation(basis, angle / 2.0);
            if (isX)
            {
                this.DoX(q1);
            }

            return QVoid.Instance;
        };

        /// <summary>
        /// The implementation of the adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, this operation is self-adjoint.
        /// </summary>
        public Func<(Pauli, double, Qubit), QVoid> R_AdjointBody() => R_Body();

        /// <summary>
        /// The implementation of the controlled specialization of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit
        /// if the rotation is effectively an X gate and all of the control qubits
        /// are in the One state.
        /// </summary>
        public Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledBody() => (_args) =>
        {
            var (ctrls, (basis, angle, q1)) = _args;

            if (q1 == null) return QVoid.Instance;

            this.CheckControlQubits(ctrls, q1);

            var (isX, safe) = CheckRotation(basis, angle / 2.0);
            if (!safe)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
            }
            // We never need to do anything since only the identity is safe to control

            return QVoid.Instance;
        };

        /// <summary>
        /// The implementation of the controlled adjoint specialization of the operation.
        /// For the Toffoli simulator *only*, the controlled specialization is self-adjoint.
        /// </summary>
        public Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledAdjointBody() => R_ControlledBody();
    }
}
