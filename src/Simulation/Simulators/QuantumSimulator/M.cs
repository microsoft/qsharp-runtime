// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimM : Quantum.Intrinsic.M
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "M")]
            private static extern uint M(uint id, uint q);

            private QuantumSimulator Simulator { get; }


            public QSimM(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, Result> __Body__ => (q) =>
            {
                Simulator.CheckQubit(q);
                //setting qubit as measured to allow for release
                q.IsMeasured = true;
                return M(Simulator.Id, (uint)q.Id).ToResult();
            };
        }
    }
}
