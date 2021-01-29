// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic
{
    public abstract class Allocate : AbstractCallable
    {
        public Allocate(IOperationFactory m) : base(m) { }

        public abstract Qubit Apply();

        public abstract IQArray<Qubit> Apply(long count);

        public override void __Init__() { }
    }
}
