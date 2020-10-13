// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerForceMeasure : ForceMeasure
        {
            private readonly QCTraceSimulatorImpl tracerCore;
            public TracerForceMeasure(QCTraceSimulatorImpl m) : base(m){
                tracerCore = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result), QVoid> __Body__
                => (arg) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target, Result result) = arg;
                    tracerCore.tracingCore.ForceMeasure(observable, target, result);
                    return QVoid.Instance;
                };
        }
    }
}
