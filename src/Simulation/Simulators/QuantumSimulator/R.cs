// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public virtual void R__Body(Pauli pauli, double angle, Qubit target)
        {
            this.CheckQubit(target);
            CheckAngle(angle);

            R(this.Id, pauli, angle, (uint)target.Id);
        }

        public virtual void R__AdjointBody(Pauli pauli, double angle, Qubit target)
        {
            R__Body(pauli, -angle, target);
        }

        public virtual void R__ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            this.CheckQubits(controls, target);
            CheckAngle(angle);

            SafeControlled(controls,
                () => R__Body(pauli, angle, target),
                (count, ids) => MCR(this.Id, pauli, angle, count, ids, (uint)target.Id));
        }


        public virtual void R__ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            R__ControlledBody(controls, pauli, -angle, target);
        }
    }
}
