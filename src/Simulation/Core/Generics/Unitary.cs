// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represents an operation that has both a Controlled and an Adjoint 
    ///     operation and whose input Type is not resolved until it gets 
    ///     Applied at runtime.
    /// </summary>
    public interface IUnitary : IAdjointable, IControllable
    {
        new IUnitary Adjoint { get; }

        new IUnitary Controlled { get; }

        new IUnitary Partial(object partialTuple);
    }    
}
