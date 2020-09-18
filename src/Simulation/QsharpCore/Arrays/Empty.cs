// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Arrays
{
    public partial class EmptyArray<TElement>
    {
        public class Native : EmptyArray<TElement>
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QVoid, IQArray<TElement>> __Body__ => (arg) =>
                new QArray<TElement>();
        }
    }

}
