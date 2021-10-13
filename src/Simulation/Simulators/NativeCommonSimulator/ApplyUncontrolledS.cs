﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        void IIntrinsicApplyUncontrolledS.Body(Qubit target)
        {
            this.CheckQubit(target);

            S((uint)target.Id);
        }
    }
}
