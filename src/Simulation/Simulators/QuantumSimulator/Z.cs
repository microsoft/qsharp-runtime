// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicZ.Body(Qubit target)
        {
            this.CheckQubit(target);

            Z(this.Id, (IntPtr)target.Id);
        }

        void IIntrinsicZ.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicZ)this).Body(target),
                (count, ids) => MCZ(this.Id, count, ids, (IntPtr)target.Id));
        }
    }
}
