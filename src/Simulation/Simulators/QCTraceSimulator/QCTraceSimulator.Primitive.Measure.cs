// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;

    public partial class QCTraceSimulatorImpl
    {
        public Func<(IQArray<Pauli>, IQArray<Qubit>), Result> Measure_Body() => (args) =>
        {
            (IQArray<Pauli> observable, IQArray<Qubit> target) = args;
            return this.Measure(observable, target);
        };
    }
}
