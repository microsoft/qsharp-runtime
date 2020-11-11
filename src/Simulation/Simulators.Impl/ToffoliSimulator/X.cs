// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// The implementation of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit.
        /// </summary>
        public Func<Qubit, QVoid> X_Body() => (q1) =>
        {
            if (q1 == null) return QVoid.Instance;

            this.CheckQubit(q1, "q1");

            this.DoX(q1);

            return QVoid.Instance;
        };

        /// <summary>
        /// The implementation of the controlled specialization of the operation.
        /// For the Toffoli simulator, the implementation flips the target qubit 
        /// if all of the control qubits are 1.
        /// </summary>
        public Func<(IQArray<Qubit>, Qubit), QVoid> X_ControlledBody() => (args) =>
        {
            var (ctrls, q) = args;
            if (q == null) return QVoid.Instance;

            this.CheckControlQubits(ctrls, q);

            if (this.VerifyControlCondition(ctrls))
            {
                this.DoX(q);
            }

            return QVoid.Instance;
        };
    }
}
