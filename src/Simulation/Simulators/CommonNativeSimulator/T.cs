// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected abstract void T(uint qubit);
        protected abstract void AdjT(uint qubit);
        protected abstract void MCT(uint count, uint[] ctrls, uint qubit);
        protected abstract void MCAdjT(uint count, uint[] ctrls, uint qubit);

        void IIntrinsicT.Body(Qubit target)
        {
            this.CheckQubit(target);

            T((uint)target.Id);
        }

        void IIntrinsicT.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicT)this).Body(target),
                (count, ids) => MCT(count, ids, (uint)target.Id));
        }

        void IIntrinsicT.AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjT((uint)target.Id);
        }

        void IIntrinsicT.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicT)this).AdjointBody(target),
                (count, ids) => MCAdjT(count, ids, (uint)target.Id));
        }
    }
}
