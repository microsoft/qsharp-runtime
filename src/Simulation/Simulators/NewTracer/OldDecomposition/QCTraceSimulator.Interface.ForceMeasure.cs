// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    internal partial class OldTracerInternalSim
    {
        public class TracerForceMeasure : ForceMeasure
        {
            private readonly OldTracerInternalSim tracerCore;
            public TracerForceMeasure(OldTracerInternalSim m) : base(m){
                tracerCore = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result), QVoid> Body
                => (arg) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target, Result result) = arg;
                    throw new NotImplementedException(); //TODO ?
                    //tracerCore.ForceMeasure(observable, target, result);
                    return QVoid.Instance;
                };
        }
    }
}