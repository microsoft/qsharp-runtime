// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerAssert : Microsoft.Quantum.Diagnostics.AssertMeasurement
        {
            private readonly QCTraceSimulatorCore core;
            public TracerAssert(QCTraceSimulatorImpl m) : base(m)
            {
                core = m.tracingCore;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> Body
                => (arg) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target, Result result, string msg) = arg;
                    core.Assert(observable, target, result);
                    return QVoid.Instance;
                };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}