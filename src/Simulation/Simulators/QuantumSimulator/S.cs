// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        void IIntrinsicS.Body(Qubit target)
        {
            this.CheckQubit(target);

            S(this.Id, (IntPtr)target.Id);
        }

        void IIntrinsicS.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicS)this).Body(target),
                (count, ids) => MCS(this.Id, count, ids, (IntPtr)target.Id));
        }

        void IIntrinsicS.AdjointBody(Qubit target)
        {
            this.CheckQubit(target);

            AdjS(this.Id, (IntPtr)target.Id);
        }

        void IIntrinsicS.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicS)this).AdjointBody(target),
                (count, ids) => MCAdjS(this.Id, count, ids, (IntPtr)target.Id));
        }
    }
}
