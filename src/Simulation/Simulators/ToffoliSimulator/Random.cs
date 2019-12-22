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
        /// Implementation of the Random operation for the Toffoli simulator.
        /// </summary>
        public class ToffSimRandom : Quantum.Intrinsic.Random
        {
            Random random = new Random();

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public ToffSimRandom(ToffoliSimulator m) : base(m)
            {
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<IQArray<double>, Int64> Body => (probs) =>
            {
                if (probs.Any(d => d < 0.0))
                {
                    throw new ArgumentOutOfRangeException("probs", "All probabilities must be greater than or equal to zero");
                }
                var sum = probs.Sum();
                if (sum <= 0.0)
                {
                    throw new ArgumentOutOfRangeException("probs", "At least one probability must be greater than zero");
                }

                var threshhold = random.NextDouble() * sum;
                for (int i = 0; i < probs.Length; i++)
                {
                    threshhold -= probs[i];
                    if (threshhold <= 0.0)
                    {
                        return i;
                    }
                }

                // This line should never be reached.
                return probs.Length - 1;
            };
        }
    }
}
