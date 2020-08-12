// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the Random operation for the Toffoli simulator.
        /// </summary>
        public class ToffSimRandom : Microsoft.Quantum.Intrinsic.Random
        {
            private ToffoliSimulator Simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public ToffSimRandom(ToffoliSimulator m) : base(m)
            {
                Simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<IQArray<double>, Int64> Body => (probs) =>
                CommonUtils.SampleDistribution(probs, Simulator.RandomGenerator.NextDouble());
        }
    }
}
