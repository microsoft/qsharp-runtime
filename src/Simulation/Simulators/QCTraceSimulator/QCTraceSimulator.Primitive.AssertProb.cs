// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerAssertProb : Microsoft.Quantum.Diagnostics.AssertMeasurementProbability
        {
            private readonly QCTraceSimulatorCore core;
            public TracerAssertProb(QCTraceSimulatorImpl m) : base(m){
                core = m.tracingCore;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> Body
                => (args) =>
                {
                    (IQArray<Pauli> observable,
                     IQArray<Qubit> target,
                     Result result,
                     double probability,
                     string msg,
                     double tol) = args;
                    core.AssertProb(observable, target, result, probability);
                    return QVoid.Instance;
                };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}