// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    public partial class AssertEqual<__T__>
    {
        public class Native : AssertEqual<__T__>
        {
            public Native(IOperationFactory m) : base(m) { }

            public override Func<(__T__, __T__), QVoid> Body => (_args) =>
            {
                var (expected, actual) = _args;
                Assert.Equal(expected, actual);
                return QVoid.Instance;
            };
        }
    }
}
