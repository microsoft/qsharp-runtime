// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimExp : Quantum.Intrinsic.Exp
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Exp")]
            private static extern void Exp(uint id, uint n, Pauli[] paulis, double angle, uint[] ids);

            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCExp")]
            private static extern void MCExp(uint id, uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);

            private QuantumSimulator Simulator { get; }


            public QSimExp(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Body => (_args) =>
            {
                var (paulis, theta, qubits) = _args;

                Simulator.CheckQubits(qubits);
                CheckAngle(theta);

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                Exp(Simulator.Id, (uint)paulis.Length, paulis.ToArray(), theta, qubits.GetIds());

                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> AdjointBody => (_args) =>
            {
                var (paulis, angle, qubits) = _args;

                return this.Body.Invoke((paulis, -angle, qubits));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledBody => (_args) =>
            {
                var (ctrls, (paulis, angle, qubits)) = _args;

                Simulator.CheckQubits(ctrls, qubits);
                CheckAngle(angle);

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                SafeControlled(ctrls,
                    () => this.Body.Invoke((paulis, angle, qubits)),
                    (count, ids) => MCExp(Simulator.Id, (uint)paulis.Length, paulis.ToArray(), angle, count, ids, qubits.GetIds()));

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledAdjointBody => (_args) =>
            {
                var (ctrls, (paulis, angle, qubits)) = _args;

                return this.ControlledBody.Invoke((ctrls, (paulis, -angle, qubits)));
            };
        }
    }
}
