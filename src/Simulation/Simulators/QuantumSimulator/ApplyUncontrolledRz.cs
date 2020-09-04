// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimApplyUncontrolledRz : Intrinsic.ApplyUncontrolledRz
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
            private static extern void R(uint id, Pauli basis, double angle, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimApplyUncontrolledRz(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
            {
                var (angle, target) = args;
                Simulator.CheckQubit(target, nameof(target));
                CheckAngle(angle);
                R(Simulator.Id, Pauli.PauliZ, angle, (uint)target.Id);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => (_args) =>
            {
                var (angle, q1) = _args;

                return this.__Body__.Invoke((-angle, q1));
            };
        }
    }
}
