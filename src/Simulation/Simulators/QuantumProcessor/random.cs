// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public static long SampleDistribution(IQArray<double> unnormalizedDistribution, double uniformZeroOneSample)
        {
            double total = 0.0;
            foreach (double prob in unnormalizedDistribution)
            {
                if (prob < 0)
                {
                    throw new ExecutionFailException("Random expects array of non-negative doubles.");
                }
                total += prob;
            }

            if (total == 0)
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles with positive sum.");
            }

            double sample = uniformZeroOneSample * total;
            double sum = unnormalizedDistribution[0];
            for (int i = 0; i < unnormalizedDistribution.Length - 1; ++i)
            {
                if (sum >= sample)
                {
                    return i;
                }
                sum += unnormalizedDistribution[i];
            }
            return unnormalizedDistribution.Length;
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
