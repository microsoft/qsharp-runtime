// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    internal partial class OldTracerInternalSim
    {
        public class TracerRFrac : Interface_RFrac
        {
            private readonly OldTracerInternalSim tracerCore;
            public TracerRFrac(OldTracerInternalSim m) : base(m){
                tracerCore = m;
            }

            public override Func<(Pauli, long, long, Qubit), QVoid> Body
                => (arg) =>
                {
                    (Pauli axis, long numerator, long denomPower, Qubit target) = arg;
                    tracerCore.RFrac(axis, numerator, denomPower, target);
                    return QVoid.Instance;
                };
        }
    }
}