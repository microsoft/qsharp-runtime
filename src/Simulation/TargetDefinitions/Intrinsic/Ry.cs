// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_Ry : Ry
        {
            private IGate_Ry Gate { get; }

            public Shim_Ry(IGate_Ry g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
            {
                var (angle, target) = args;
                Gate.Ry_Body(angle, target);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => (args) =>
            {
                var (angle, target) = args;
                Gate.Ry_AdjointBody(angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, (angle, target)) = args;
                Gate.Ry_ControlledBody(ctls, angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, (angle, target)) = args;
                Gate.Ry_ControlledAdjointBody(ctls, angle, target);
                return QVoid.Instance;
            };
        }
    }
}
