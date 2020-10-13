// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        internal class QSimApplyControlledZ : Intrinsic.ApplyControlledZ
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCZ")]
            private static extern void MCZ(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimApplyControlledZ(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => (args) =>
            {
                var (control, target) = args;

                Simulator.CheckQubits(new QArray<Qubit>(new Qubit[]{ control, target }));

                MCZ(Simulator.Id, 1, new uint[]{(uint)control.Id}, (uint)target.Id);

                return QVoid.Instance;
            };
        }
    }
}
