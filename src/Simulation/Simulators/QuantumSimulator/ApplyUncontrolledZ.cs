// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimApplyUncontrolledZ : Intrinsic.ApplyUncontrolledZ
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Z")]
            private static extern void Z(uint id, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimApplyUncontrolledZ(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                Simulator.CheckQubit(q1); ;

                Z(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };
        }
    }
}
