// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using System.Collections.Generic;

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
            Details = status;
        }

        /// <summary>
        /// Gets the workspace.
        /// </summary>
        public virtual IWorkspace Workspace { get; }

        /// <summary>
        ///     Provider id.
        /// </summary>
        public virtual string ProviderId => this.Details.Id;

        /// <summary>
        ///     Provider availability.
        /// </summary>
        public virtual Models.ProviderAvailability? CurrentAvailability => this.Details.CurrentAvailability;

        /// <summary>
        ///     List of all available targets for this provider.
        /// </summary>
        public virtual IEnumerable<TargetStatusInfo> Targets
        {
            get
            {
                foreach (var ps in this.Details.Targets)
                {
                    yield return new TargetStatusInfo(ps);
                }
            }
        }

        /// <summary>
        /// Gets the provider status information.
        /// </summary>
        protected Models.ProviderStatus Details { get; private set; }
    }
}
