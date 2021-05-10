// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime.Submitters
{
    /// <summary>
    /// An interface for submitting quantum programs to Azure.
    /// </summary>
    public interface IAzureSubmitter
    {
        /// <summary>
        /// The ID of the quantum machine provider.
        /// </summary>
        string ProviderId { get; }

        /// <summary>
        /// The name of the target quantum machine. A provider may expose multiple targets that can be used to execute
        /// programs. Users may select which target they would like to be used for execution.
        /// </summary>
        string Target { get; }
    }
}
