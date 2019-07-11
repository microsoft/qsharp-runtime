// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimR : Intrinsic.R
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
            private static extern void R(uint id, Pauli basis, double angle, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCR")]
            private static extern void MCR(uint id, Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimR(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Pauli, double, Qubit), QVoid> Body => (_args) =>
            {
                var (basis, angle, q1) = _args;

                Simulator.CheckQubit(q1);
                CheckAngle(angle);

                R(Simulator.Id, basis, angle, (uint)q1.Id);

                return QVoid.Instance;
            };

            public override Func<(Pauli, double, Qubit), QVoid> AdjointBody => (_args) =>
            {
                var (basis, angle, q1) = _args;

                return this.Body.Invoke((basis, -angle, q1));
            };

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledBody => (_args) =>
            {
                var (ctrls, (basis, angle, q1)) = _args;

                Simulator.CheckQubits(ctrls, q1);
                CheckAngle(angle);

                SafeControlled(ctrls,
                    () => this.Body.Invoke((basis, angle, q1)),
                    (count, ids) => MCR(Simulator.Id, basis, angle, count, ids, (uint)q1.Id));

                return QVoid.Instance;
            };


            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledAdjointBody => (_args) =>
            {
                var (ctrls, (basis, angle, q1)) = _args;

                return this.ControlledBody.Invoke((ctrls, (basis, -angle, q1)));
            };
        }
    }
}
