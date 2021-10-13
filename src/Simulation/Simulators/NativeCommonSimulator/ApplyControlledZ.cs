// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        void IIntrinsicApplyControlledZ.Body(Qubit control, Qubit target)
        {
            this.CheckQubits(new QArray<Qubit>(new Qubit[]{ control, target }));

            MCZ(1, new uint[]{(uint)control.Id}, (uint)target.Id);
        }
    }
}
