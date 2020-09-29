// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Arrays
{
    public partial class EmptyArray<__TElement__>
    {
        public class Native : EmptyArray<__TElement__>
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QVoid, IQArray<__TElement__>> __Body__ => _ =>
                new QArray<__TElement__>();
        }
    }

}
