// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum
{
    using Microsoft.Azure.Quantum.Utility;

    using Models = global::Azure.Quantum.Jobs.Models;

    /// <summary>
    /// Wrapper for Azure.Quantum.Jobs.Models.ProviderStatus.
    /// </summary>
    public class TargetStatusInfo
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="TargetStatusInfo"/> class.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="status">The provider status details.</param>
        public TargetStatusInfo(Models.TargetStatus status)
        {
            Ensure.NotNull(status, nameof(status));

            Details = status;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="TargetStatusInfo"/> class.
        /// Use only for testing.
        /// </summary>
        protected TargetStatusInfo()
        {
        }

        /// <summary>
        /// Target id.
        /// </summary>
        public virtual string? TargetId => Details?.Id;

        /// <summary>
        ///    Target availability.
        /// </summary>
        public virtual Models.TargetAvailability? CurrentAvailability => Details?.CurrentAvailability;

        /// <summary>
        ///    Average queue time in seconds.
        /// </summary>
        public virtual long? AverageQueueTime => Details?.AverageQueueTime;

        /// <summary>
        ///    A page with detailed status of the provider.
        /// </summary>
        public virtual string? StatusPage => Details?.StatusPage;

        /// <summary>
        /// Gets the provider status information.
        /// </summary>
        protected Models.TargetStatus? Details { get; private set; }
    }
}
