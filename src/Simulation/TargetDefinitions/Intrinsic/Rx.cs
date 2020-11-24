// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{

    public partial class TargetIntrinsics
    {
        public class Shim_Rx : Rx
        {
            private IGate_Rx Gate { get; }

            public Shim_Rx(IGate_Rx g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
            {
                var (angle, target) = args;
                Gate.Rx_Body(angle, target);
                return QVoid.Instance;
            };

            public override Func<(double, Qubit), QVoid> __AdjointBody__ => (args) =>
            {
                var (angle, target) = args;
                Gate.Rx_AdjointBody(angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, (angle, target)) = args;
                Gate.Rx_ControlledBody(ctls, angle, target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit)), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, (angle, target)) = args;
                Gate.Rx_ControlledAdjointBody(ctls, angle, target);
                return QVoid.Instance;
            };
        }
    }
}
