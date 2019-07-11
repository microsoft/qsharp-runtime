// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerCX : Interface_CX
        {
            private readonly QCTraceSimulatorImpl tracerCore;
            public TracerCX(QCTraceSimulatorImpl m) : base(m){
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