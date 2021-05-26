// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;

namespace Microsoft.Azure.Quantum
{
    /// <summary>
    /// IWorkspace interface.
    /// </summary>
    public interface IWorkspace
    {
        /// <summary>
        /// The Workspace's Azure Subscription.
        /// </summary>
        string SubscriptionId { get; }

        /// <summary>
        /// The Workspace's resource group in Azure.
        /// </summary>
        string ResourceGroupName { get; }

        /// <summary>
        /// The Workspace's location (region) in Azure.
        /// </summary>
        string Location { get; }

        /// <summary>
        /// The Workspace's name.
        /// </summary>
        string WorkspaceName { get; }

        /// <summary>
        /// Submits the job.
        /// </summary>
        /// <param name="jobDefinition">The job definition.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job response.</returns>
        Task<CloudJob> SubmitJobAsync(
            CloudJob jobDefinition,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job response.</returns>
        Task<CloudJob> CancelJobAsync(
            string jobId,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job object.</returns>
        Task<CloudJob> GetJobAsync(
            string jobId,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Lists the jobs.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>List of jobs</returns>
        IAsyncEnumerable<CloudJob> ListJobsAsync(
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Returns the list of quotas for a workspace.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>List of jobs</returns>
        IAsyncEnumerable<QuotaInfo> ListQuotasAsync(
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets as SAS Uri for the storage account associated with the workspace.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Sas Uri.</returns>
        Task<string> GetSasUriAsync(
            string containerName,
            string blobName = null,
            CancellationToken cancellationToken = default);
    }
}
