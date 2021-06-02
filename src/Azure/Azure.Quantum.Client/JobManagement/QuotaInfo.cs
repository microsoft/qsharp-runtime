// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using global::Azure.Quantum.Jobs.Models;

    using Microsoft.Azure.Quantum.Utility;

    /// <summary>
    /// Wrapper for Azure.Quantum.Jobs.Models.QuantumJobQuota.
    /// </summary>
    public class QuotaInfo
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="QuotaInfo"/> class.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="quota">The job details.</param>
        public QuotaInfo(IWorkspace workspace, QuantumJobQuota quota)
        {
            Ensure.NotNull(workspace, nameof(workspace));
            Ensure.NotNull(quota, nameof(quota));

            Workspace = workspace;
            Details = quota;
        }

        /// <summary>
        /// Gets the workspace.
        /// </summary>
        public virtual IWorkspace Workspace { get; private set; }

        /// <summary>
        ///     The name of the dimension associated with the quota.
        /// </summary>
        public virtual string Dimension => Details.Dimension;

        /// <summary>
        ///    The scope at which the quota is applied.
        /// </summary>
        public virtual DimensionScope? Scope => Details.Scope;

        /// <summary>
        ///    The unique identifier for the provider.
        /// </summary>
        public virtual string ProviderId => Details.ProviderId;

        /// <summary>
        ///    The amount of the usage that has been applied for the current period.
        /// </summary>
        public virtual float? Utilization => Details.Utilization;

        /// <summary>
        ///    The amount of the usage that has been reserved but not applied for the current
        ///     period.
        /// </summary>
        public virtual float? Holds => Details.Holds;

        /// <summary>
        ///    The maximum amount of usage allowed for the current period.
        /// </summary>
        public virtual float? Limit => Details.Limit;

        /// <summary>
        ///    The time period in which the quota's underlying meter is accumulated. Based on
        ///     calendar year. 'None' is used for concurrent quotas.
        /// </summary>
        public virtual MeterPeriod? Period => Details.Period;

        /// <summary>
        /// Gets the quota information.
        /// </summary>
        protected QuantumJobQuota Details { get; private set; }
    }
}
