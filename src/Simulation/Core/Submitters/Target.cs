// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime.Submitters
{
    /// <summary>
    /// Options for a job submitted to Azure Quantum.
    /// </summary>
    public class Target
    {
        /// <summary>
        /// TODO.
        /// </summary>
        public string ProviderId { get; }

        /// <summary>
        /// TODO.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// TODO.
        /// </summary>
        public Target(string providerId, string name)
        {
            ProviderId = providerId;
            Name = name;
        }
    }
}
