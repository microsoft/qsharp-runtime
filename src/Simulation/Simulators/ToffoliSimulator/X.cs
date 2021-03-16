﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit.
        /// </summary>
        void IIntrinsicX.Body(Qubit target)
        {
            if (target == null) return;

            this.CheckQubit(target, "target");

            this.DoX(target);
        }

        /// <summary>
        /// The implementation of the controlled specialization of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit 
        /// if all of the control qubits are 1.
        /// </summary>
        void IIntrinsicX.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            if (target == null) return;

            this.CheckControlQubits(controls, target);

            if (this.VerifyControlCondition(controls))
            {
                this.DoX(target);
            }
        }
    }
}
