// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicR.Body(Pauli pauli, double angle, Qubit target)
        {
            this.CheckQubit(target);
            CheckAngle(angle);

            R(this.Id, pauli, angle, (IntPtr)target.Id);
        }

        void IIntrinsicR.AdjointBody(Pauli pauli, double angle, Qubit target)
        {
            ((IIntrinsicR)this).Body(pauli, -angle, target);
        }

        void IIntrinsicR.ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);

            SafeControlled(controls,
                () => ((IIntrinsicR)this).Body(pauli, angle, target),
                (count, ids) => MCR(this.Id, pauli, angle, count, ids, (IntPtr)target.Id));
        }


        void IIntrinsicR.ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            ((IIntrinsicR)this).ControlledBody(controls, pauli, -angle, target);
        }
    }
}
