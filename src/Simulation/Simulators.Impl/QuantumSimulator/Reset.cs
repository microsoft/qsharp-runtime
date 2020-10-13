// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimReset : Intrinsic.Reset
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "X")]
            private static extern void X(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "M")]
            private static extern uint M(uint id, uint q);

            private QuantumSimulator Simulator { get; }


            public QSimReset(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                // The native simulator doesn't have a reset operation, so simulate
                // it via an M follow by a conditional X.
                Simulator.CheckQubit(q1);
                var res = M(Simulator.Id, (uint)q1.Id);
                if (res == 1)
                {
                    X(Simulator.Id, (uint)q1.Id);
                }

                return QVoid.Instance;
            };
        }
    }
}
