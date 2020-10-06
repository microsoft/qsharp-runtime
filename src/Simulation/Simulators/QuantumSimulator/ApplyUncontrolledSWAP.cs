// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimApplyUncontrolledSWAP : Intrinsic.ApplyUncontrolledSWAP
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
            private static extern void MCX(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimApplyUncontrolledSWAP(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => (args) =>
            {
                var (qubit1, qubit2) = args;
                var ctrls1 = new QArray<Qubit>(qubit1);
                var ctrls2 = new QArray<Qubit>(qubit2);
                Simulator.CheckQubits(ctrls1, qubit2);

                MCX(Simulator.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)qubit2.Id);
                MCX(Simulator.Id, (uint)ctrls2.Length, ctrls2.GetIds(), (uint)qubit1.Id);
                MCX(Simulator.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)qubit2.Id);

                return QVoid.Instance;
            };

        }
    }
}
