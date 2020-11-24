// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class TargetIntrinsics
    {
        public class Shim_X : X
        {
            private IGate_X Gate { get; }

            public Shim_X(IGate_X g) : base(g)
            {
                this.Gate = g;
            }

            public override Func<Qubit, QVoid> __Body__ => (target) =>
            {
                Gate.X_Body(target);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> __ControlledBody__ => (args) =>
            {
                var (ctls, target) = args;
                Gate.X_ControlledBody(ctls, target);
                return QVoid.Instance;
            };
        }
    }
}
