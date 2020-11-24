// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        internal class Shim_IsingXX : IsingXX
        {
            private IGate_IsingXX Gate { get; }

            public Shim_IsingXX(IGate_IsingXX g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit, Qubit), QVoid> __Body__ => (args) =>
            {
                var (angle, target1, target2) = args;
                Gate.IsingXX_Body(angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit, Qubit), QVoid> __AdjointBody__ => (args) =>
            {
                var (angle, target1, target2) = args;
                Gate.IsingXX_AdjointBody(angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, (angle, target1, target2)) = args;
                Gate.IsingXX_ControlledBody(ctls, angle, target1, target2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, (angle, target1, target2)) = args;
                Gate.IsingXX_ControlledAdjointBody(ctls, angle, target1, target2);
                return QVoid.Instance;
            };
        }
    }
}
