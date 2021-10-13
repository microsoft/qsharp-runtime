// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected abstract void S(uint qubit);
        protected abstract void AdjS(uint qubit);
        protected abstract void MCS(uint count, uint[] ctrls, uint qubit);
        protected abstract void MCAdjS(uint count, uint[] ctrls, uint qubit);

        void IIntrinsicS.Body(Qubit target)
        {
            this.CheckQubit(target);

            S((uint)target.Id);
        }

        void IIntrinsicS.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicS)this).Body(target),
                (count, ids) => MCS(count, ids, (uint)target.Id));
        }

        void IIntrinsicS.AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjS((uint)target.Id);
        }

        void IIntrinsicS.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicS)this).AdjointBody(target),
                (count, ids) => MCAdjS(count, ids, (uint)target.Id));
        }
    }
}
