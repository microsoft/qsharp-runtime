// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_S : S
        {
            private IGate_S Gate { get; }

            public Shim_S(IGate_S g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => (target) =>
            {
                Gate.S_Body(target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, target) = args;
                Gate.S_ControlledBody(ctls, target);
                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
            {
                Gate.S_AdjointBody(target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledAdjointBody__ => (args) =>
            {
                var (ctls, target) = args;
                Gate.S_ControlledAdjointBody(ctls, target);
                return QVoid.Instance;
            };
        }
    }
}
