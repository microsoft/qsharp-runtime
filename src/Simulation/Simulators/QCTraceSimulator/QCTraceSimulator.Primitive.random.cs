﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        public class TracerRandom : Intrinsic.Random
        {
            private readonly QCTraceSimulatorImpl core;
            public TracerRandom(QCTraceSimulatorImpl m) : base(m)
            {
                core = m;
            }

            public override Func<IQArray<double>, Int64> Body => (p) =>
            {
                return SimulatorsUtils.SampleDistribution(p, core.random.NextDouble());
            };
        }
    }
}
