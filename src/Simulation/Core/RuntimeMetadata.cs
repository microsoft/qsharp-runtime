// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Core
{
    public class RuntimeMetadata
    {
        /// <summary>
        /// Label of gate.
        /// </summary>
        public string Label { get; set; } = "";

        /// <summary>
        /// Non-qubit arguments provided to gate.
        /// </summary>
        public string? Args { get; set; }

        /// <summary>
        /// True if operation is an adjoint operation.
        /// </summary>
        public bool IsAdjoint { get; set; }

        /// <summary>
        /// True if operation is a controlled operation.
        /// </summary>
        public bool IsControlled { get; set; }

        /// <summary>
        /// True if operation is a measurement operation.
        /// </summary>
        public bool IsMeasurement { get; set; }

        /// <summary>
        /// True if operation is composed of multiple operations.
        /// </summary>
        /// </summary>
        /// <remarks>
        /// Currently not used as this is intended for compositeoperations,
        /// such as <c>ApplyToEach</c>.
        /// </remarks>
        public bool IsComposite { get; set; }

        /// <summary>
        /// Group of operations for each classical branch.
        /// </summary>
        /// <remarks>
        /// Currently not used as this is intended for classically-controlled operations.
        /// </remarks>
        public IEnumerable<IEnumerable<RuntimeMetadata>>? Children { get; set; }

        /// <summary>
        /// List of control registers.
        /// </summary>
        public IEnumerable<Qubit> Controls { get; set; } = new List<Qubit>();

        /// <summary>
        /// List of target registers.
        /// </summary>
        public IEnumerable<Qubit> Targets { get; set; } = new List<Qubit>();
    }
}
