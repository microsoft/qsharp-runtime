// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation throws a run-time error.
        /// </summary>
        void IIntrinsicS.Body(Qubit target) => throw new NotImplementedException();

        void IIntrinsicS.ControlledBody(IQArray<Qubit> controls, Qubit target) => throw new NotImplementedException();

        void IIntrinsicS.AdjointBody(Qubit target) => throw new NotImplementedException();

        void IIntrinsicS.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target) => throw new NotImplementedException();
    }
}
