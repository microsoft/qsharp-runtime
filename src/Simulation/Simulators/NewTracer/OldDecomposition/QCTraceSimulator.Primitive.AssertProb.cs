// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    internal partial class OldTracerInternalSim
    {
        public class TracerAssertProb : Microsoft.Quantum.Diagnostics.AssertMeasurementProbability
        {
            private readonly OldTracerInternalSim core;
            public TracerAssertProb(OldTracerInternalSim m) : base(m)
            {
                core = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> Body
                => (args) =>
                {
                    (IQArray<Pauli> observable, IQArray<Qubit> target, Result result,
                        double probability, string msg, double tol
                    ) = args;

                    if (result == Result.One) { probability = 1 - probability; }

                    core.MeasurementManager.AssertProb(observable, target, probability, msg, tol);
                    return QVoid.Instance;
                };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}