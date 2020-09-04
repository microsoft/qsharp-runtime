// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimApplyUncontrolledT : Intrinsic.ApplyUncontrolledT
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "T")]
            private static extern void T(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjT")]
            private static extern void AdjT(uint id, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimApplyUncontrolledT(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                Simulator.CheckQubit(q1);

                T(Simulator.Id, (uint)q1.Id);
                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (q1) =>
            {
                Simulator.CheckQubit(q1);
                
                AdjT(this.Simulator.Id, (uint)q1.Id);
                return QVoid.Instance;
            };
        }
    }
}
