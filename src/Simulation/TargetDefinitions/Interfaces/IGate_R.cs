// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IGate_R : IOperationFactory
    {
        void R__Body(Pauli pauli, double angle, Qubit target);

        void R__AdjointBody(Pauli pauli, double angle, Qubit target);

        void R__ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);

        void R__ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target);
    }
}