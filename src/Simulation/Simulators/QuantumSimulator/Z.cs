// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimZ : Intrinsic.Z
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Z")]
            private static extern void Z(uint id, uint qubit);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCZ")]
            private static extern void MCZ(uint id, uint count, uint[] ctrls, uint qubit);

            private QuantumSimulator Simulator { get; }


            public QSimZ(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> __Body__ => (q1) =>
            {
                Simulator.CheckQubit(q1); ;

                Z(Simulator.Id, (uint)q1.Id);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                Simulator.CheckQubits(ctrls, q1);

                SafeControlled(ctrls,
                    () => this.Apply(q1),
                    (count, ids) => MCZ(Simulator.Id, count, ids, (uint)q1.Id));

                return QVoid.Instance;
            };
        }
    }
}
