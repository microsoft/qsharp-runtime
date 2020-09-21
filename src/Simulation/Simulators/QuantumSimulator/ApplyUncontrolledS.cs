// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        internal class QSimApplyUncontrolledS : Intrinsic.ApplyUncontrolledS
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "S")]
            private static extern void S(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjS")]
            private static extern void AdjS(uint id, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimApplyUncontrolledS(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                Simulator.CheckQubit(q1);

                S(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (q1) =>
            {
                Simulator.CheckQubit(q1);

                AdjS(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };
        }
    }
}
