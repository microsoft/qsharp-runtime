// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    internal partial class OldTracerInternalSim
    {
        public class TracerRandom : Intrinsic.Random
        {
            private readonly OldTracerInternalSim core;
            public TracerRandom(OldTracerInternalSim m) : base(m)
            {
                core = m;
            }

            public override Func<IQArray<double>, Int64> Body => (p) =>
            {
                //TODO: implement and accept random seed in construcor of tracer
                return -1;
                //return CommonUtils.SampleDistribution(p, core.random.NextDouble());
            };
        }
    }
}
