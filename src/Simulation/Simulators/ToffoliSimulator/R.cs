// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the R operation for the Toffoli simulator.
        /// </summary>
        public class R : Intrinsic.R
        {
            private ToffoliSimulator simulator { get; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public R(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation flips the target qubit
            /// if the rotation is effectively an X gate.
            /// </summary>
            public override Func<(Pauli, double, Qubit), QVoid> Body => (_args) =>
            {
                var (basis, angle, q1) = _args;

                if (q1 == null) return QVoid.Instance;

                simulator.CheckQubit(q1, "q1");

                var (isX, safe) = CheckRotation(basis, angle / 2.0);
                if (isX)
                {
                    simulator.DoX(q1);
                }

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the adjoint specialization of the operation.
            /// For the Toffoli simulator *only*, this operation is self-adjoint.
            /// </summary>
            public override Func<(Pauli, double, Qubit), QVoid> AdjointBody => Body;

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// For the Toffoli simulator, the implementation flips the target qubit
            /// if the rotation is effectively an X gate and all of the control qubits
            /// are in the One state.
            /// </summary>
            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledBody => (_args) =>
            {
                var (ctrls, (basis, angle, q1)) = _args;

                if (q1 == null) return QVoid.Instance;

                simulator.CheckControlQubits(ctrls, q1);

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
            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledAdjointBody => ControlledBody;
        }
    }
}
