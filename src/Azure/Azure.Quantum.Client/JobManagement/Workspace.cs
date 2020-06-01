// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Azure.Core;
using Microsoft.Azure.Quantum.Authentication;
using Microsoft.Azure.Quantum.Client;
using Microsoft.Azure.Quantum.Client.Models;
using Microsoft.Azure.Quantum.Storage;
using Microsoft.Azure.Quantum.Utility;
using Microsoft.Quantum.Runtime;

namespace Microsoft.Azure.Quantum
{
    /// <summary>
    /// Workspace class.
    /// </summary>
    /// <seealso cref="Microsoft.Azure.Quantum.Client.IWorkspace" />
    public class Workspace : IWorkspace
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Workspace"/> class.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <param name="workspaceName">Name of the workspace.</param>
        /// <param name="tokenCredential">The token credential.</param>
        /// <param name="baseUri">The base URI.</param>
        public Workspace(
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            TokenCredential tokenCredential = null,
            Uri baseUri = null)
            : this(
                subscriptionId,
                resourceGroupName,
                workspaceName,
                tokenCredential == null ? null : new TokenCredentialProvider(tokenCredential),
                baseUri)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="Workspace"/> class.
        /// </summary>
        /// <param name="subscriptionId">The subscription identifier.</param>
        /// <param name="resourceGroupName">Name of the resource group.</param>
        /// <param name="workspaceName">Name of the workspace.</param>
        /// <param name="accessToken">The access token.</param>
        /// <param name="baseUri">The base URI.</param>
        public Workspace(
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            string accessToken,
            Uri baseUri = null)
            : this(
                  subscriptionId,
                  resourceGroupName,
                  workspaceName,
                  new StaticAccessTokenProvider(accessToken),
                  baseUri)
        {
        }

        private Workspace(
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            IAccessTokenProvider accessTokenProvider,
            Uri baseUri = null)
        {
            Ensure.NotNullOrWhiteSpace(subscriptionId, nameof(subscriptionId));
            Ensure.NotNullOrWhiteSpace(resourceGroupName, nameof(resourceGroupName));
            Ensure.NotNullOrWhiteSpace(workspaceName, nameof(workspaceName));

            accessTokenProvider = accessTokenProvider ?? new CustomAccessTokenProvider(subscriptionId);

            Ensure.NotNull(accessTokenProvider, nameof(accessTokenProvider));

            this.JobsClient = new QuantumClient(new AuthorizationClientHandler(accessTokenProvider))
            {
                BaseUri = baseUri ?? new Uri(Constants.DefaultBaseUri),
                SubscriptionId = subscriptionId,
                ResourceGroupName = resourceGroupName,
                WorkspaceName = workspaceName,
            }.Jobs;
        }

        /// <summary>
        /// Gets or sets the jobs client.
        /// Internal only.
        /// </summary>
        /// <value>
        /// The jobs client.
        /// </value>
        internal IJobsOperations JobsClient { get; set; }

        /// <summary>
        /// Submits the job.
        /// </summary>
        /// <param name="jobDefinition">The job definition.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// The job response.
        /// </returns>
        public async Task<CloudJob> SubmitJobAsync(
            CloudJob jobDefinition,
            CancellationToken cancellationToken = default)
        {
            Ensure.NotNull(jobDefinition, nameof(jobDefinition));
            Ensure.NotNullOrWhiteSpace(jobDefinition.Details.Id, nameof(jobDefinition.Details.Id));

            JobDetails jobDetails = await this.JobsClient.PutAsync(
                jobId: jobDefinition.Details.Id,
                jobDefinition: jobDefinition.Details,
                cancellationToken: cancellationToken);

            return new CloudJob(this, jobDetails);
        }

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Cloud job.</returns>
        public async Task<CloudJob> CancelJobAsync(string jobId, CancellationToken cancellationToken = default)
        {
            Ensure.NotNullOrWhiteSpace(jobId, nameof(jobId));

            JobDetails jobDetails = await this.JobsClient.DeleteAsync(
                jobId: jobId,
                cancellationToken: cancellationToken);

            return new CloudJob(this, jobDetails);
        }

        /// <summary>
        /// Gets the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// The job response.
        /// </returns>
        public async Task<CloudJob> GetJobAsync(string jobId, CancellationToken cancellationToken = default)
        {
            Ensure.NotNullOrWhiteSpace(jobId, nameof(jobId));

            JobDetails jobDetails = await this.JobsClient.GetAsync(
                jobId: jobId,
                cancellationToken: cancellationToken);

            return new CloudJob(this, jobDetails);
        }

        /// <summary>
        /// Lists the jobs.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// List of jobs.
        /// </returns>
        public async Task<IEnumerable<CloudJob>> ListJobsAsync(CancellationToken cancellationToken = default)
        {
            var jobs = await this.JobsClient.ListAsync(
                cancellationToken: cancellationToken);

            return jobs
                .Select(details => new CloudJob(this, details));
        }
    }
}
