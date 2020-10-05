// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerR : Interface_R
        {
            private readonly QCTraceSimulatorImpl tracerCore;
            public TracerR(QCTraceSimulatorImpl m) : base(m){
                tracerCore = m;
            }

            public override Func<(Pauli, double, Qubit), QVoid>
                __Body__ => (arg) =>
                {
                    (Pauli axis, double angle, Qubit target) = arg;
                    tracerCore.R(axis, angle, target);
                    return QVoid.Instance;
                };
        }
    }
}
