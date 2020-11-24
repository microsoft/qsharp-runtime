// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_IsingZZ : IsingZZ
        {
            private IGate_IsingZZ Gate { get; }

            public Shim_IsingZZ(IGate_IsingZZ g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit, Qubit), QVoid> __Body__ => (args) =>
            {
                var (angle, target1, target2) = args;
                Gate.IsingZZ_Body(angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit, Qubit), QVoid> __AdjointBody__ => (args) =>
            {
                var (angle, target1, target2) = args;
                Gate.IsingZZ_AdjointBody(angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, (angle, target1, target2)) = args;
                Gate.IsingZZ_ControlledBody(ctls, angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, (angle, target1, target2)) = args;
                Gate.IsingZZ_ControlledAdjointBody(ctls, angle, target1, target2);
                return QVoid.Instance;
            };
        }
    }
}
