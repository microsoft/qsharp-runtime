// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    internal partial class OldTracerInternalSim
    {
        public class TracerCX : Interface_CX
        {
            private readonly OldTracerInternalSim tracerCore;
            public TracerCX(OldTracerInternalSim m) : base(m){
                tracerCore = m;
            }

            public override Func<(Qubit, Qubit), QVoid> Body
                => (arg) =>
                {
                    (Qubit control, Qubit target) = arg;
                    tracerCore.CX(target, control);
                    return QVoid.Instance;
                };
        }
    }
}