// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{

    public partial class QuantumProcessorDispatcher
    {
        public Func<(Pauli, double, Qubit), QVoid> R_Body() => (_args) =>
        {
            (Pauli basis, double angle, Qubit q1) = _args;
            if (basis != Pauli.PauliI)
            {
                this.QuantumProcessor.R(basis, angle,q1);
            }
            return QVoid.Instance;
        };

        public Func<(Pauli, double, Qubit), QVoid> R_AdjointBody() => (_args) =>
        {
            (Pauli basis, double angle, Qubit q1) = _args;
            return R_Body().Invoke((basis, -angle, q1));
        };

        public Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, (Pauli basis, double angle, Qubit q1)) = _args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.R(basis, angle, q1);
            }
            else
            {
                this.QuantumProcessor.ControlledR(ctrls, basis, angle, q1);
            }

            return QVoid.Instance;
        };


        public Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> R_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, (Pauli basis, double angle, Qubit q1)) = _args;
            return R_ControlledBody().Invoke((ctrls, (basis, -angle, q1)));
        };
    }
}
