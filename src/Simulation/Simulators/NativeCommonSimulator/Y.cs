// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        protected abstract void Y(uint qubit);
        protected abstract void MCY(uint count, uint[] ctrls, uint qubit);
        
        void IIntrinsicY.Body(Qubit target)
        {
            this.CheckQubit(target);

            Y((uint)target.Id);
        }

        void IIntrinsicY.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicY)this).Body(target),
                (count, ids) => MCY(count, ids, (uint)target.Id));
        }
    }
}
