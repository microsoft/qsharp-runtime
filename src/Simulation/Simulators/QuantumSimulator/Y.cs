// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicY.Body(Qubit target)
        {
            this.CheckQubit(target);

            Y(this.Id, (IntPtr)target.Id);
        }

        void IIntrinsicY.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicY)this).Body(target),
                (count, ids) => MCY(this.Id, count, ids, (IntPtr)target.Id));
        }
    }
}
