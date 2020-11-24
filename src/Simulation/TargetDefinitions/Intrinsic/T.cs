// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_T : T
        {
            private IGate_T Gate { get; }

            public Shim_T(IGate_T g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => (target) =>
            {
                Gate.T_Body(target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, target) = args;
                Gate.T_ControlledBody(ctls, target);
                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
            {
                Gate.T_AdjointBody(target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, target) = args;
                Gate.T_ControlledAdjointBody(ctls, target);
                return QVoid.Instance;
            };
        }
    }
}
