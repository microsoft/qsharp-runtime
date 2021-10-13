﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        protected abstract void X(uint qubit);
        protected abstract void MCX(uint count, uint[] ctrls, uint qubit);

        void IIntrinsicX.Body(Qubit target)
        {
            this.CheckQubit(target);

            X((uint)target.Id);
        }

        void IIntrinsicX.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            this.CheckQubits(controls, target);

            SafeControlled(controls,
                () => ((IIntrinsicX)this).Body(target),
                (count, ids) => MCX(count, ids, (uint)target.Id));
        }
    }
}
