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
        public class QuantumProcessorDispatcherRandom : Quantum.Intrinsic.Random
        {
            private QuantumProcessorDispatcher Simulator { get; }
            public QuantumProcessorDispatcherRandom(QuantumProcessorDispatcher m) : base(m)
            {
                Simulator = m;
            }

            public override Func<IQArray<double>, Int64> Body => (p) =>
            {
                return CommonUtils.SampleDistribution(p, Simulator.RandomGenerator.NextDouble());
            };            
        }
    }
}
