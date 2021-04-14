// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// A machine that can execute quantum programs on Azure.
    /// </summary>
    public interface IAzureMachine
    {
        /// <summary>
        /// Gets the ID of the quantum machine provider.
        /// </summary>
        string ProviderId { get; }

        /// <summary>
        /// Gets the name of the target quantum machine.
        /// A provider may expose multiple targets that can be used to execute programs.
        /// Users may select which target they would like to be used for execution.
        /// </summary>
        string Target { get; }
    }
}
