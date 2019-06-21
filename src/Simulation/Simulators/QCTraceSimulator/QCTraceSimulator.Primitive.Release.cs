// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        public class TracerRelease : Intrinsic.Release
        {
            private readonly QCTraceSimulatorCore core;
            public TracerRelease(QCTraceSimulatorImpl m) : base(m){
                core = m.tracingCore;
            }

            public override void Apply(Qubit q)
            {
                core.Release(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                core.Release(qubits);
            }
        }
    }
}