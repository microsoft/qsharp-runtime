// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using System;
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Intrinsic.Interfaces;

    public partial class QCTraceSimulatorImpl
    {
        Result IIntrinsicMeasure.Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            return this.Measure(paulis, targets);
        }
    }
}
