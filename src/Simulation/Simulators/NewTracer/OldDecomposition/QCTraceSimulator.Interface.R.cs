// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    internal partial class OldTracerInternalSim
    {
        public class TracerR : Interface_R
        {
            private readonly OldTracerInternalSim tracerCore;
            public TracerR(OldTracerInternalSim m) : base(m){
                tracerCore = m;
            }

            public override Func<(Pauli, double, Qubit), QVoid>
                Body => (arg) =>
                {
                    (Pauli axis, double angle, Qubit target) = arg;
                    tracerCore.R(axis, angle, target);
                    return QVoid.Instance;
                };
        }
    }
}