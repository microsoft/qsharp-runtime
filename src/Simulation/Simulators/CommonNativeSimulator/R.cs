// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        void IIntrinsicR.Body(Pauli pauli, double angle, Qubit target)
        {
            this.CheckQubit(target);
            CheckAngle(angle);

            R(pauli, angle, (uint)target.Id);
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
                (count, ids) => MCR(pauli, angle, count, ids, (uint)target.Id));
        }


        void IIntrinsicR.ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            ((IIntrinsicR)this).ControlledBody(controls, pauli, -angle, target);
        }
    }
}
