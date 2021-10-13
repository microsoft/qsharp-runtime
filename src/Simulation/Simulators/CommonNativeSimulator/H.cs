// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected abstract void H(uint qubit);
        protected abstract void MCH(uint count, uint[] ctrls, uint qubit);
        
        void IIntrinsicH.Body(Qubit target)
        {
            this.CheckQubit(target);

            H((uint)target.Id);
        }

        void IIntrinsicH.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicH)this).Body(target),
                (count, ids) => MCH(count, ids, (uint)target.Id));
        }
    }
}
