// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public Func<(Qubit, Qubit), QVoid> SWAP_Body() => (args) =>
        {
            var (qubit1, qubit2) = args;
            var ctrls1 = new QArray<Qubit>(qubit1);
            var ctrls2 = new QArray<Qubit>(qubit2);
            this.CheckQubits(ctrls1, qubit2);

            MCX(this.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)qubit2.Id);
            MCX(this.Id, (uint)ctrls2.Length, ctrls2.GetIds(), (uint)qubit1.Id);
            MCX(this.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)qubit2.Id);

            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> SWAP_ControlledBody() => (args) =>
        {
            var (ctrls, (qubit1, qubit2)) = args;

            if ((ctrls == null) || (ctrls.Count == 0))
            {
                SWAP_Body().Invoke((qubit1, qubit2));
            }
            else
            {
                var ctrls_1 = QArray<Qubit>.Add(ctrls, new QArray<Qubit>(qubit1));
                var ctrls_2 = QArray<Qubit>.Add(ctrls, new QArray<Qubit>(qubit2));
                this.CheckQubits(ctrls_1, qubit2);
                
                MCX(this.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)qubit2.Id);
                MCX(this.Id, (uint)ctrls_2.Length, ctrls_2.GetIds(), (uint)qubit1.Id);
                MCX(this.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)qubit2.Id);
            }

            return QVoid.Instance;
        };
    }
}
