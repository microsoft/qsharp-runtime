// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        void IIntrinsicApplyUncontrolledRzz.Body(double angle, Qubit target1, Qubit target2)
        {
            var paulis = new Pauli[]{ Pauli.PauliZ, Pauli.PauliZ };
            var targets = new QArray<Qubit>(new Qubit[]{ target1, target2 });
            CheckAngle(angle);
            this.CheckQubits(targets);

            Exp((uint)targets.Length, paulis, angle / -2.0, targets.GetIds());
        }

        void IIntrinsicApplyUncontrolledRzz.AdjointBody(double angle, Qubit target1, Qubit target2)
        {
            ((IIntrinsicApplyUncontrolledRzz)this).Body(-angle, target1, target2);
        }

        void IIntrinsicApplyUncontrolledRzz.ControlledBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2)
        {
            if (controls == null || controls.Length == 0)
            {
                ((IIntrinsicApplyUncontrolledRzz)this).Body(angle, target1, target2);
            }
            else
            {
                var targets = new QArray<Qubit>(new Qubit[]{ target1, target2 });
                var paulis = new Pauli[]{ Pauli.PauliZ, Pauli.PauliZ };
                CheckAngle(angle);
                this.CheckQubits(QArray<Qubit>.Add(controls, targets));

                MCExp((uint)targets.Length, paulis, angle / -2.0, (uint)controls.Length, controls.GetIds(), targets.GetIds());
            }
        }

        void IIntrinsicApplyUncontrolledRzz.ControlledAdjointBody(IQArray<Qubit> controls, double angle, Qubit target1, Qubit target2)
        {
            ((IIntrinsicApplyUncontrolledRzz)this).ControlledBody(controls, -angle, target1, target2);
        }
    }
}
