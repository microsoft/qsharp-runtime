// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    internal partial class OldTracerInternalSim
    {
        public class TracerMeasure : Intrinsic.Measure
        {
            private readonly OldTracerInternalSim core;
            public TracerMeasure(OldTracerInternalSim m) : base(m){
                core = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result>
                Body => (args) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target) = args;
                    core.Measure(observable, target);
                    return core.MeasurementManager.Measure(observable, target);
                };
        }
    }
}