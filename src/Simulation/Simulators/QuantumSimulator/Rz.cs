// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimRz : Intrinsic.Rz
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
            private static extern void R(uint id, Pauli basis, double angle, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCR")]
            private static extern void MCR(uint id, Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }

            public QSimRz(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(double, Qubit), QVoid> Body => (args) =>
            {
                var (angle, target) = args;
                Simulator.CheckQubit(target, nameof(target));
                CheckAngle(angle);
                R(Simulator.Id, Pauli.PauliZ, angle, (uint)target.Id);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit), QVoid> AdjointBody => (_args) =>
            {
                var (angle, q1) = _args;

                return this.Body.Invoke((-angle, q1));
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (angle, target)) = args;
                Simulator.CheckQubits(ctrls, target);
                CheckAngle(angle);
                MCR(Simulator.Id, Pauli.PauliZ, angle, (uint)ctrls.Length, ctrls.GetIds(), (uint)target.Id);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> ControlledAdjointBody => (_args) =>
            {
                var (ctrls, (angle, q1)) = _args;

                return this.ControlledBody.Invoke((ctrls, (-angle, q1)));
            };
        }
    }
}
