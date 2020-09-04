// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimApplyControlledX : Intrinsic.ApplyControlledX
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
            private static extern void MCX(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimApplyControlledX(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit, Qubit), QVoid> __Body__ => (args) =>
            {
                var (control, target) = args;

                Simulator.CheckQubits(new QArray<Qubit>(new Qubit[]{ control, target }));

                MCX(Simulator.Id, 1, new uint[]{(uint)control.Id}, (uint)target.Id);

                return QVoid.Instance;
            };
        }
    }
}
