// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimS : Intrinsic.S
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "S")]
            private static extern void S(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjS")]
            private static extern void AdjS(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCS")]
            private static extern void MCS(uint id, uint count, uint[] ctrls, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjS")]
            private static extern void MCAdjS(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimS(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {
                Simulator.CheckQubit(q1);

                S(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                Simulator.CheckQubits(ctrls, q1);

                SafeControlled(ctrls,
                    () => this.Apply(q1),
                    (count, ids) => MCS(Simulator.Id, count, ids, (uint)q1.Id));

                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> AdjointBody => (q1) =>
            {
                Simulator.CheckQubit(q1);

                AdjS(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledAdjointBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                Simulator.CheckQubits(ctrls, q1);

                SafeControlled(ctrls,
                    () => this.AdjointBody(q1),
                    (count, ids) => MCAdjS(Simulator.Id, count, ids, (uint)q1.Id));

                return QVoid.Instance;
            };
        }
    }
}
