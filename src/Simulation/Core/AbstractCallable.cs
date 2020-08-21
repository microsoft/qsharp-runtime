// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represent a Quantum Operation, a list of instructions to be executed
    ///     in a Quantum Machine.
    ///     Each Operation receives in its constructor an OperationFactory, with
    ///     the instance of the Factory that created the operation instance and
    ///     that can be used to get instances of other operations as needed.
    /// </summary>
    public abstract class AbstractCallable : IApplyData
    {
        // Used by Partial application to determine missing parameters.
        public static readonly MissingParameter _ = MissingParameter._;

        public AbstractCallable(IOperationFactory m)
        {
            this.Factory = m;
        }

        public IOperationFactory Factory { get; private set; }

        /// <summary>
        /// This method is called once, to let the Operation initialize and verify its dependencies.
        /// </summary>
        public abstract void Init();

        /// <summary>
        /// Retrieves the runtime metadata of the Operation. If the Operation has no associated
        /// runtime metadata, returns <c>null</c>.
        /// </summary>
        public virtual RuntimeMetadata? GetRuntimeMetadata(IApplyData args) => null;

        object IApplyData.Value => null;

        IEnumerable<Qubit> IApplyData.Qubits => null;
    }
}
