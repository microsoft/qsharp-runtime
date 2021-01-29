// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the ExpFrac operation for the Toffoli simulator.
        /// </summary>
        public class ExpFrac : Intrinsic.ExpFrac
        {
            private ToffoliSimulator simulator { get; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public ExpFrac(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation flips a target qubit
            /// if the respective rotation is effectively an X gate.
            /// </summary>
            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> __Body__ => (_args) =>
            {
                var (bases, num, den, qubits) = _args;

                if (qubits == null) return QVoid.Instance;

                simulator.CheckQubits(qubits, "qubits");

                if (qubits.Length != bases.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {GetType().Name} (paulis,qubits), must be of same size");
                }

                for (var i = 0; i < qubits.Length; i++)
                {
                    var (isX, safe) = CheckRotation(bases[i], num, den);
                    if (isX)
                    {
                        simulator.DoX(qubits[i]);
                    }
                }

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the adjoint specialization of the operation.
            /// For the Toffoli simulator *only*, this operation is self-adjoint.
            /// </summary>
            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> __AdjointBody__ => __Body__;

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// For the Toffoli simulator, the implementation flips the target qubit
            /// if the rotation is effectively an X gate and all of the control qubits
            /// are in the One state.
            /// </summary>
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid> __ControlledBody__ => (_args) =>
            {
                var (ctrls, (bases, num, den, qubits)) = _args;

                if (qubits == null) return QVoid.Instance;

                simulator.CheckControlQubits(ctrls, qubits);

                if (qubits.Length != bases.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {GetType().Name} (paulis,qubits), must be of same size");
                }

                for (var i = 0; i < qubits.Length; i++)
                {
                    var (isX, safe) = CheckRotation(bases[i], num, den);
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
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid> __ControlledAdjointBody__ => __ControlledBody__;
        }
    }
}
