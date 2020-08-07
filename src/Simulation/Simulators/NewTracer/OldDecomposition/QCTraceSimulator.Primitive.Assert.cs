// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    internal partial class OldTracerInternalSim
    {
        public class TracerAssert : Microsoft.Quantum.Diagnostics.AssertMeasurement
        {
            private readonly OldTracerInternalSim core;
            public TracerAssert(OldTracerInternalSim m) : base(m)
            {
                core = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> Body
                => (arg) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target, Result result, string msg) = arg;
                    core.MeasurementManager.Assert(observable, target, result, msg);
                    return QVoid.Instance;
                };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}