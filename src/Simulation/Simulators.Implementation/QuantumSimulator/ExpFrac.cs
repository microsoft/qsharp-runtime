// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimExpFrac : Intrinsic.ExpFrac
        {
            public QSimExpFrac(QuantumSimulator m) : base(m)
            {
            }

            public static double Angle(long numerator, long power) =>
                (System.Math.PI * numerator) / (1 << (int)power);

            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> Body => (args) =>
            {
                var (paulis, numerator, power, qubits) = args;
                var angle = Angle(numerator, power);
                return Exp.Apply((paulis, angle, qubits));
            };

            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> AdjointBody => (args) =>
            {
                var (paulis, numerator, power, qubits) = args;
                var angle = Angle(numerator, power);
                return Exp.Adjoint.Apply((paulis, angle, qubits));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (paulis, numerator, power, qubits)) = args;
                var angle = Angle(numerator, power);
                return Exp.Controlled.Apply((ctrls, (paulis, angle, qubits)));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid> ControlledAdjointBody => (args) =>
            {
                var (ctrls, (paulis, numerator, power, qubits)) = args;
                var angle = Angle(numerator, power);
                return Exp.Adjoint.Controlled.Apply((ctrls, (paulis, angle, qubits)));
            };
        }
    }
}
