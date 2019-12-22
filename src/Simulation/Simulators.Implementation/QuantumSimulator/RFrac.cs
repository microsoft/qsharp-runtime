// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public class QSimRFrac : Intrinsic.RFrac
        {
            public QSimRFrac(QuantumSimulator m) : base(m)
            {
            }

            public static double Angle(long numerator, long power) =>
                (-2.0 * System.Math.PI * numerator) / (1 << (int)power);

            public override Func<(Pauli, long, long, Qubit), QVoid> Body => (args) =>
            {
                var (pauli, numerator, power, qubit) = args;
                var angle = Angle(numerator, power);
                return R.Apply((pauli, angle, qubit));
            };

            public override Func<(Pauli, long, long, Qubit), QVoid> AdjointBody => (args) =>
            {
                var (pauli, numerator, power, qubit) = args;
                var angle = Angle(numerator, power);
                return R.Adjoint.Apply((pauli, angle, qubit));
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledBody => (args) =>
            {
                var (ctrls, (pauli, numerator, power, qubit)) = args;
                var angle = Angle(numerator, power);
                return R.Controlled.Apply((ctrls, (pauli, angle, qubit)));
            };

            public override Func<(IQArray<Qubit>, (Pauli, long, long, Qubit)), QVoid> ControlledAdjointBody => (args) =>
            {
                var (ctrls, (pauli, numerator, power, qubit)) = args;
                var angle = Angle(numerator, power);
                return R.Adjoint.Controlled.Apply((ctrls, (pauli, angle, qubit)));
            };
        }
    }
}
