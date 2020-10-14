// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the Y operation for the Toffoli simulator.
        /// </summary>
        public class Y : Quantum.Intrinsic.Y
        {
            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public Y(ToffoliSimulator m) : base(m)
            {
            }

            /// <summary>
            /// The implementation of the operation.
            /// For the Toffoli simulator, the implementation throws a run-time error.
            /// </summary>
            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                throw new NotImplementedException();
            };
        }
    }
}
