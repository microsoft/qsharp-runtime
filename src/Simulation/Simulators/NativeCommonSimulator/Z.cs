// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        protected abstract void Z(uint qubit);
        protected abstract void MCZ(uint count, uint[] ctrls, uint qubit);

        void IIntrinsicZ.Body(Qubit target)
        {
            this.CheckQubit(target);

            Z((uint)target.Id);
        }

        void IIntrinsicZ.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicZ)this).Body(target),
                (count, ids) => MCZ(count, ids, (uint)target.Id));
        }
    }
}
