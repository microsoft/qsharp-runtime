// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimIsingXX : Intrinsic.IsingXX
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Exp")]
            private static extern void Exp(uint id, uint n, Pauli[] paulis, double angle, uint[] ids);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCExp")]
            private static extern void MCExp(uint id, uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);

            private QuantumSimulator Simulator { get; }

            public QSimIsingXX(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(double, Qubit, Qubit), QVoid> Body => (args) =>
            {
                var (angle, qubit1, qubit2) = args;
                var paulis = new Pauli[]{ Pauli.PauliX, Pauli.PauliX };
                var targets = new QArray<Qubit>(new Qubit[]{ qubit1, qubit2 });
                CheckAngle(angle);
                Simulator.CheckQubits(targets);

                Exp(Simulator.Id, (uint)targets.Length, paulis, angle, targets.GetIds());

                return QVoid.Instance;
            };

            public override Func<(double, Qubit, Qubit), QVoid> AdjointBody => (args) =>
            {
                var (angle, qubit1, qubit2) = args;

                return this.Body.Invoke((-angle, qubit1, qubit2));
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (angle, qubit1, qubit2)) = args;

                if (ctrls == null || ctrls.Length == 0)
                {
                    this.Body.Invoke((angle, qubit1, qubit2));
                }
                else
                {
                    var targets = new QArray<Qubit>(new Qubit[]{ qubit1, qubit2 });
                    var paulis = new Pauli[]{ Pauli.PauliX, Pauli.PauliX };
                    CheckAngle(angle);
                    Simulator.CheckQubits(QArray<Qubit>.Add(ctrls, targets));

                    MCExp(Simulator.Id, (uint)targets.Length, paulis, angle, (uint)ctrls.Length, ctrls.GetIds(), targets.GetIds());
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> ControlledAdjointBody => (args) =>
            {
                var (ctrls, (angle, qubit1, qubit2)) = args;

                return this.ControlledBody.Invoke((ctrls, (-angle, qubit1, qubit2)));
            };
        }
    }
}
