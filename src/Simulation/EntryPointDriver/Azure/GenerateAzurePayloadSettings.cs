// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.EntryPointDriver
{

    /// <summary>
    /// Settings for a submission to Azure Quantum.
    /// </summary>
    public sealed class GenerateAzurePayloadSettings
    {
        /// <summary>
        /// The target device ID.
        /// </summary>
        public string? Target { get; set; }
    }
}
