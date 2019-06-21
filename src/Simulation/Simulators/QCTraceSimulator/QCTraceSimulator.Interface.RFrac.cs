// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
    using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits;
    public partial class QCTraceSimulatorImpl
    {
        public class TracerRFrac : Interface_RFrac
        {
            private readonly QCTraceSimulatorImpl tracerCore;
            public TracerRFrac(QCTraceSimulatorImpl m) : base(m){
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