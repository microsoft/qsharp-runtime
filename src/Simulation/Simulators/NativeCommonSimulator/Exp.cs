// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        protected abstract void Exp(uint n, Pauli[] paulis, double angle, uint[] ids);
        protected abstract void MCExp(uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);

        void IIntrinsicExp.Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            this.CheckQubits(targets);
            CheckAngle(angle);

            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, targets), must be of same size.");
            }

            Exp((uint)paulis.Length, paulis.ToArray(), angle, targets.GetIds());
        }

        void IIntrinsicExp.AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            ((IIntrinsicExp)this).Body(paulis, -angle, targets);
        }

        void IIntrinsicExp.ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            this.CheckQubits(controls, targets);
            CheckAngle(angle);

            if (paulis.Length != targets.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (paulis, qubits), must be of same size.");
            }

            SafeControlled(controls,
                () => ((IIntrinsicExp)this).Body(paulis, angle, targets),
                (count, ids) => MCExp((uint)paulis.Length, paulis.ToArray(), angle, count, ids, targets.GetIds()));
        }

        void IIntrinsicExp.ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            ((IIntrinsicExp)this).ControlledBody(controls, paulis, -angle, targets);
        }
    }
}
