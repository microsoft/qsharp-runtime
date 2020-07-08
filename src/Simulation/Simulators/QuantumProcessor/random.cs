// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public static long SampleDistribution(IQArray<double> unnormalizedDistribution, double uniformZeroOneSample)
        {
            if (unnormalizedDistribution.Any(prob => prob < 0.0))
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles.");
            }

            var total = unnormalizedDistribution.Sum();
            if (total == 0)
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles with positive sum.");
            }

            var sample = uniformZeroOneSample * total;

            return unnormalizedDistribution
                // Get the unnormalized CDF of the distribution.
                .SelectAggregates((double acc, double x) => acc + x)
                // Look for the first index at which the CDF is bigger
                // than the random sample of 𝑈(0, 1) that we were given
                // as a parameter.
                .Select((cumulativeProb, idx) => (cumulativeProb, idx))
                .Where(item => item.cumulativeProb >= sample)
                // Cast that index to long, and default to returning
                // the last item.
                .Select(
                    item => (long)item.idx
                )
                .DefaultIfEmpty(
                    unnormalizedDistribution.Length - 1
                )
                .First();
        }

        public class QuantumProcessorDispatcherRandom : Quantum.Intrinsic.Random
        {
            private QuantumProcessorDispatcher Simulator { get; }
            public QuantumProcessorDispatcherRandom(QuantumProcessorDispatcher m) : base(m)
            {
                Simulator = m;
            }

            public override Func<IQArray<double>, Int64> Body => (p) =>
            {
                return SampleDistribution(p, Simulator.random.NextDouble());
            };            
        }
    }
}
