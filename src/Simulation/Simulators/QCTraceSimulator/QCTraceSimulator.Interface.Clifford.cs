// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerClifford : Interface_Clifford
        {
            private readonly QCTraceSimulatorImpl tracerCore;
            public TracerClifford(QCTraceSimulatorImpl m) : base(m){
                tracerCore = m;
            }

            public override Func<(long, Pauli, Qubit), QVoid> __Body__
                => (arg) =>
                {
                    (long id , Pauli pauli, Qubit target) = arg;
                    tracerCore.Clifford(id,pauli, target);
                    return QVoid.Instance;
                };
        }
    }
}
