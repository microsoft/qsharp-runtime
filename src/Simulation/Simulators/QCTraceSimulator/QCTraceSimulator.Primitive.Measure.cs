// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerMeasure : Intrinsic.Measure
        {
            private readonly QCTraceSimulatorImpl core;
            public TracerMeasure(QCTraceSimulatorImpl m) : base(m){
                core = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result>
                __Body__ => (args) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target) = args;
                    return core.Measure(observable, target);
                };
        }


    }
}
