// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    internal partial class OldTracerInternalSim
    {
        public class TracerClifford : Interface_Clifford
        {
            private readonly OldTracerInternalSim tracerCore;
            public TracerClifford(OldTracerInternalSim m) : base(m)
            {
                tracerCore = m;
            }

            public override Func<(long, Pauli, Qubit), QVoid> Body
                => (arg) =>
                {
                    (long id, Pauli pauli, Qubit target) = arg;
                    tracerCore.QubitClifford((int)id, pauli, target);
                    return QVoid.Instance;
                };
        }
    }
}