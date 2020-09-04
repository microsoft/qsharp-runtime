// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimSWAP : Intrinsic.SWAP
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
            private static extern void MCX(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimSWAP(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit, Qubit), QVoid> Body => (args) =>
            {
                var (qubit1, qubit2) = args;
                var ctrls = new QArray<Qubit>(qubit1);
                Simulator.CheckQubits(ctrls, qubit2);

                MCX(Simulator.Id, (uint)ctrls.Length, ctrls.GetIds(), (uint)qubit2.Id);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (qubit1, qubit2)) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    this.Apply((qubit1, qubit2));
                }
                else
                {
                    var ctrls_1 = QArray<Qubit>.Add(ctrls, new QArray<Qubit>(qubit1));
                    var ctrls_2 = QArray<Qubit>.Add(ctrls, new QArray<Qubit>(qubit2));
                    Simulator.CheckQubits(ctrls_1, qubit2);
                    
                    MCX(Simulator.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)qubit2.Id);
                    MCX(Simulator.Id, (uint)ctrls_2.Length, ctrls_2.GetIds(), (uint)qubit1.Id);
                    MCX(Simulator.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)qubit2.Id);
                }

                return QVoid.Instance;
            };

        }
    }
}
