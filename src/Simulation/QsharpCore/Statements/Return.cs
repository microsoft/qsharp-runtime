// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic
{
    public abstract class Return : AbstractCallable
    {
        public Return(IOperationFactory m) : base(m) { }

        public abstract void Apply(Qubit q);

        public abstract void Apply(IQArray<Qubit> qubits);

        public override void __Init__() { }
    }
}
