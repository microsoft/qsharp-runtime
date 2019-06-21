// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Variant or a functor of the operation appearing in the operation call graph
    /// </summary>
    public enum OperationFunctor
    {
        /// <summary>
        /// Operation body, defined by Q# keyword <code>body</code>
        /// </summary>
        Body,
        /// <summary>
        /// Adjoint variant of the operation, defined by Q# keyword <code>adjoint</code>
        /// </summary>
        Adjoint,
        /// <summary>
        /// Controlled variant of the operation, defined by Q# keyword <code>controlled</code>
        /// </summary>
        Controlled,
        /// <summary>
        /// Controlled Adjoint variant of the operation, defined by
        /// Q# keyword <code>controlled adjoint</code>
        /// </summary>
        ControlledAdjoint
    }
}
