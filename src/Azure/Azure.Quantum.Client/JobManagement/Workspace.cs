﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Runtime.CompilerServices;
    using System.Threading;
    using System.Threading.Tasks;
    using global::Azure.Core;
    using global::Azure.Identity;
    using global::Azure.Quantum;
    using global::Azure.Quantum.Jobs;
    using global::Azure.Quantum.Jobs.Models;

    using Microsoft.Azure.Quantum.Authentication;
    using Microsoft.Azure.Quantum.Exceptions;
    using Microsoft.Azure.Quantum.Utility;

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
        /// <param name="location">Azure region where the workspace was created.</param>
        /// <param name="credential">The credentials to connect to Azure. If not provided it defaults to an interactive DefaultAzureCredentials.</param>
        /// <param name="options">Options for the client library when communication with Azure Service..</param>
        public Workspace(
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            string location,
            TokenCredential credential = null,
            QuantumJobClientOptions options = default)
        {
            // Required parameters:
            Ensure.NotNullOrWhiteSpace(subscriptionId, nameof(subscriptionId));
            Ensure.NotNullOrWhiteSpace(resourceGroupName, nameof(resourceGroupName));
            Ensure.NotNullOrWhiteSpace(workspaceName, nameof(workspaceName));
            Ensure.NotNullOrWhiteSpace(location, nameof(location));

            // Optional parameters:
            credential ??= CredentialFactory.CreateCredential(CredentialType.Default, subscriptionId);
            options ??= new QuantumJobClientOptions();

            this.ResourceGroupName = resourceGroupName;
            this.WorkspaceName = workspaceName;
            this.SubscriptionId = subscriptionId;
            this.Location = location;

            this.Client = new QuantumJobClient(
                    subscriptionId,
                    resourceGroupName,
                    workspaceName,
                    location,
                    credential,
                    options);
        }

        public string ResourceGroupName { get; }

        public string SubscriptionId { get; }

        public string WorkspaceName { get; }

        public string Location { get; }

        /// <summary>
        /// The client used to communicate with the service.
        /// </summary>
        public QuantumJobClient Client { get; }

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
            Ensure.NotNullOrWhiteSpace(jobDefinition.Id, nameof(jobDefinition.Id));

            try
            {
                JobDetails jobDetails = await this.Client.CreateJobAsync(
                    jobId: jobDefinition.Id,
                    job: jobDefinition.Details,
                    cancellationToken: cancellationToken);

                return new CloudJob(this, jobDetails);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not submit job", jobDefinition.Id);
            }
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

            try
            {
                await this.Client.CancelJobAsync(
                    jobId: jobId,
                    cancellationToken: cancellationToken);

                JobDetails jobDetails = this.Client.GetJob(jobId);

                return new CloudJob(this, jobDetails);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not cancel job", jobId);
            }
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

            try
            {
                JobDetails jobDetails = await this.Client.GetJobAsync(
                    jobId: jobId,
                    cancellationToken: cancellationToken);

                return new CloudJob(this, jobDetails);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not get job", jobId);
            }
        }

        /// <summary>
        /// Lists the jobs.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// List of jobs.
        /// </returns>
        public async IAsyncEnumerable<CloudJob> ListJobsAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var jobs = this.Client.GetJobsAsync().WithCancellation(cancellationToken);

            await foreach (var j in jobs)
            {
                yield return new CloudJob(this, j);
            }
        }

        /// <summary>
        /// Lists the quotas.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// List of quotas.
        /// </returns>
        public async IAsyncEnumerable<QuotaInfo> ListQuotasAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var quotas = this.Client.GetQuotasAsync(cancellationToken);

            await foreach (var q in quotas)
            {
                yield return new QuotaInfo(this, q);
            }
        }

        /// <summary>
        /// Lists the quotas.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// List of quotas.
        /// </returns>
        public async IAsyncEnumerable<ProviderStatusInfo> ListProvidersStatusAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var status = this.Client.GetProviderStatusAsync(cancellationToken);

            await foreach (var s in status)
            {
                yield return new ProviderStatusInfo(this, s);
            }
        }

        /// <summary>
        /// Gets as SAS Uri for the linked storage account.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// Sas Uri.
        /// </returns>
        public async Task<string> GetSasUriAsync(string containerName, string blobName = null, CancellationToken cancellationToken = default)
        {
            BlobDetails details = new BlobDetails(containerName)
            {
                BlobName = blobName,
            };

            var response = await this.Client.GetStorageSasUriAsync(details, cancellationToken);
            return response.Value.SasUri;
        }

        private WorkspaceClientException CreateException(
            Exception inner,
            string message,
            string jobId = "")
        {
            return new WorkspaceClientException(
                message,
                this.SubscriptionId,
                this.ResourceGroupName,
                this.WorkspaceName,
                this.Location,
                jobId,
                inner);
        }
    }
}
