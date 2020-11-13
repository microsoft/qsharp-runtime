// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation throws a run-time error.
        /// </summary>
        public Func<Qubit, QVoid> S_Body() => (q1) =>
            throw new NotImplementedException();

        public Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledBody() => (_args) =>
            throw new NotImplementedException();

        public Func<Qubit, QVoid> S_AdjointBody() => (q1) =>
            throw new NotImplementedException();

        public Func<(IQArray<Qubit>, Qubit), QVoid> S_ControlledAdjointBody() => (_args) =>
            throw new NotImplementedException();
    }
}
