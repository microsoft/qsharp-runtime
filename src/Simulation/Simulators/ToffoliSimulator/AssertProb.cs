// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using static System.Math;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the AssertProb operation for the Toffoli simulator.
        /// </summary>
        public class AssertProb : Microsoft.Quantum.Diagnostics.AssertMeasurementProbability
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public AssertProb(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> Body => (_args) =>
            {

                Qubit? f(Pauli p, Qubit q) =>
                    p switch {
                        Pauli.PauliZ => q,
                        _ => null,
                    };

                var (paulis, qubits, result, expectedProb, msg, tolerance) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                if ((expectedProb + tolerance >= 1.0) && (expectedProb - tolerance <= 0.0))
                {
                    return QVoid.Instance;
                }

                // If there are any X- or Y-basis measurements, then the probability is 50%
                if (paulis.Any(p => p ==Pauli.PauliX || p ==Pauli.PauliY))
                {
                    if (Abs(0.5 - expectedProb) > tolerance)
                    {
                        throw new ExecutionFailException(msg);
                    }
                }
                else
                {
                    // Pick out just the Z measurements
                    var qubitsToMeasure = paulis.Zip(qubits, f).WhereNotNull();
                    var parity = simulator.GetParity(qubitsToMeasure);
                    var actual = parity ? 0.0 : 1.0;
                    if (result == Result.One)
                    {
                        actual = 1.0 - actual;
                    }

                    if (Abs(actual - expectedProb) > tolerance)
                    {
                        throw new ExecutionFailException(msg);
                    }
                }

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the adjoint specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            /// <summary>
            /// The implementation of the controlled adjoint specialization of the operation.
            /// The current definition is that this is a no-op.
            /// </summary>
            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}
