// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using Microsoft.Azure.Quantum.Utility;

    using Models = global::Azure.Quantum.Jobs.Models;

    /// <summary>
    /// Wrapper for Azure.Quantum.Jobs.Models.ProviderStatus.
    /// </summary>
    public class ProviderStatusInfo
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ProviderStatusInfo"/> class.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="status">The provider status details.</param>
        public ProviderStatusInfo(IWorkspace workspace, Models.ProviderStatus status)
        {
            Ensure.NotNull(workspace, nameof(workspace));
            Ensure.NotNull(status, nameof(status));

            Workspace = workspace;
            Status = status;
        }

        /// <summary>
        /// Gets the workspace.
        /// </summary>
        public virtual IWorkspace Workspace { get; private set; }

        /// <summary>
        /// Gets the provider status information.
        /// </summary>
        public virtual Models.ProviderStatus Status { get; private set; }
    }
}
