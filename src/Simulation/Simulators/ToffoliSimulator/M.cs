// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the M operation for the Toffoli simulator.
        /// </summary>
        public class M : Quantum.Intrinsic.M
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public M(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation returns the state of the measured qubit.
            /// That is, Result.One is returned if the measured qubit is in the One state.
            /// </summary>
            public override Func<Qubit, Result> __Body__ => (q1) =>
            {
                if (q1 == null) return Result.Zero;

                this.simulator.CheckQubit(q1, "q1");

                return (this.simulator.State[q1.Id]).ToResult();
            };
        }
    }
}
