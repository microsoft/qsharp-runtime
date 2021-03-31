// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicX.Body(Qubit target)
        {
            this.CheckQubit(target);

            X(this.Id, (uint)target.Id);
        }

        void IIntrinsicX.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicX)this).Body(target),
                (count, ids) => MCX(this.Id, count, ids, (uint)target.Id));
        }
    }
}
