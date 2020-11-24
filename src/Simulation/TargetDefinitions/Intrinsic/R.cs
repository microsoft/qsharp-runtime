// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_R : R
        {
            private IGate_R Gate { get; }

            public Shim_R(IGate_R g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(Pauli, double, Qubit), QVoid> __Body__ => (args) =>
            {
                var (pauli, angle, target) = args;
                Gate.R_Body(pauli, angle, target);
                return QVoid.Instance;
            };

            public override Func<(Pauli, double, Qubit), QVoid> __AdjointBody__ => (args) =>
            {
                var (pauli, angle, target) = args;
                Gate.R_AdjointBody(pauli, angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, (pauli, angle, target)) = args;
                Gate.R_ControlledBody(ctls, pauli, angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, (pauli, angle, target)) = args;
                Gate.R_ControlledAdjointBody(ctls, pauli, angle, target);
                return QVoid.Instance;
            };
        }
    }
}
