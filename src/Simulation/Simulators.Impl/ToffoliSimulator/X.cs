// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the X operation for the Toffoli simulator.
        /// </summary>
        public class X : Intrinsic.X
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public X(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation flips the target qubit.
            /// </summary>
            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                if (q1 == null) return QVoid.Instance;

                simulator.CheckQubit(q1, "q1");

                simulator.DoX(q1);

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// For the Toffoli simulator, the implementation flips the target qubit 
            /// if all of the control qubits are 1.
            /// </summary>
            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctrls, q) = args;
                if (q == null) return QVoid.Instance;

                simulator.CheckControlQubits(ctrls, q);

                if (simulator.VerifyControlCondition(ctrls))
                {
                    simulator.DoX(q);
                }

                return QVoid.Instance;
            };
        }
    }
}
