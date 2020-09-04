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
        /// Implementation of the Assert operation for the Toffoli simulator.
        /// </summary>
        public class Assert : Microsoft.Quantum.Diagnostics.AssertMeasurement
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public Assert(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __Body__ => (_args) =>
            {
                Qubit? f(Pauli p, Qubit q) =>
                    p switch {
                        Pauli.PauliI => null,
                        Pauli.PauliZ => q,
                        _ => throw new InvalidOperationException($"The Toffoli simulator can only Assert in the Z basis.")
                    };

                var (paulis, qubits, expected, msg) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                var qubitsToMeasure = paulis.Zip(qubits, f).WhereNotNull();

                var actual = simulator.GetParity(qubitsToMeasure);

                if (actual.ToResult() != expected)
                {
                    throw new ExecutionFailException(msg);
                }

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the adjoint specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __AdjointBody__ => (_args) => { return QVoid.Instance; };

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledBody__ => (_args) => { return QVoid.Instance; };

            /// <summary>
            /// The implementation of the controlled adjoint specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledAdjointBody__ => (_args) => { return QVoid.Instance; };
        }
    }
}
