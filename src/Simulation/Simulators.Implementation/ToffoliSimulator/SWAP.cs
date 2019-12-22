// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the SWAP operation for the Toffoli simulator.
        /// </summary>
        public class SWAP : Intrinsic.SWAP
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public SWAP(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation swaps the states of the two qubits.
            /// </summary>
            public override Func<(Qubit, Qubit), QVoid> Body => (args) =>
            {
                var (q1, q2) = args;

                if ((q1 == null) || (q2 == null)) return QVoid.Instance;

                simulator.CheckQubit(q1, "q1");
                simulator.CheckQubit(q2, "q2");

                if (q1.Id == q2.Id)
                {
                    throw new NotDistinctQubits(q2);
                }

                simulator.DoSwap(q1, q2);

                return QVoid.Instance;
            };

            /// <summary>
            /// The implementation of the controlled specialization of the operation.
            /// For the Toffoli simulator, the implementation swaps the states of the
            /// target qubits if all of the control qubits are 1.
            /// </summary>
            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (q1, q2)) = args;

                if ((q1 == null) || (q2 == null)) return QVoid.Instance;

                var targets = new QArray<Qubit>(q1, q2);
                simulator.CheckControlQubits(ctrls, targets);

                if (simulator.VerifyControlCondition(ctrls))
                {
                    simulator.DoSwap(q1, q2);
                }

                return QVoid.Instance;
            };
        }
    }
}
