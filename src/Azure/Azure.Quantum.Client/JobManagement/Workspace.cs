﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using global::Azure.Core;
    using Microsoft.Azure.Quantum.Authentication;
    using Microsoft.Azure.Quantum.Client;
    using Microsoft.Azure.Quantum.Client.Models;
    using Microsoft.Azure.Quantum.Exceptions;
    using Microsoft.Azure.Quantum.Utility;

    /// <summary>
    /// Workspace class.
    /// </summary>
    /// <seealso cref="Microsoft.Azure.Quantum.Client.IWorkspace" />
    public class Workspace : IWorkspace
    {
        private readonly Uri baseUri;
        private readonly string resourceGroupName;
        private readonly string subscriptionId;
        private readonly string workspaceName;

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
            this.baseUri = baseUri ?? new Uri(Constants.DefaultBaseUri);
            Ensure.NotNullOrWhiteSpace(subscriptionId, nameof(subscriptionId));
            this.subscriptionId = subscriptionId;
            Ensure.NotNullOrWhiteSpace(resourceGroupName, nameof(resourceGroupName));
            this.resourceGroupName = resourceGroupName;
            Ensure.NotNullOrWhiteSpace(workspaceName, nameof(workspaceName));
            this.workspaceName = workspaceName;

            try
            {
                accessTokenProvider = accessTokenProvider ?? new CustomAccessTokenProvider(subscriptionId);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not create an access token provider");
            }

            Ensure.NotNull(accessTokenProvider, nameof(accessTokenProvider));

            try
            {
                this.QuantumClient = new QuantumClient(new AuthorizationClientHandler(accessTokenProvider))
                {
                    BaseUri = this.baseUri,
                    SubscriptionId = subscriptionId,
                    ResourceGroupName = resourceGroupName,
                    WorkspaceName = workspaceName,
                };
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not create an Azure quantum service client");
            }
        }

        /// <summary>
        /// Gets or sets the jobs client.
        /// Internal only.
        /// </summary>
        /// <value>
        /// The jobs client.
        /// </value>
        internal IQuantumClient QuantumClient { get; set; }

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

            try
            {
                JobDetails jobDetails = await this.QuantumClient.Jobs.PutAsync(
                    jobId: jobDefinition.Details.Id,
                    jobDefinition: jobDefinition.Details,
                    cancellationToken: cancellationToken);

                return new CloudJob(this, jobDetails);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not submit job", jobDefinition.Details.Id);
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
                JobDetails jobDetails = await this.QuantumClient.Jobs.DeleteAsync(
                    jobId: jobId,
                    cancellationToken: cancellationToken);

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
                JobDetails jobDetails = await this.QuantumClient.Jobs.GetAsync(
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
        public async Task<IEnumerable<CloudJob>> ListJobsAsync(CancellationToken cancellationToken = default)
        {
            try
            {
                var jobs = await this.QuantumClient.Jobs.ListAsync(
                    cancellationToken: cancellationToken);

                return jobs
                    .Select(details => new CloudJob(this, details));
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not list jobs");
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
            BlobDetails details = new BlobDetails
            {
                ContainerName = containerName,
                BlobName = blobName,
            };

            var response = await this.QuantumClient.Storage.SasUriAsync(details, cancellationToken);
            return response.SasUri;
        }

        private WorkspaceClientException CreateException(
            Exception inner,
            string message,
            string jobId = "")
        {
            return new WorkspaceClientException(
                message,
                subscriptionId,
                resourceGroupName,
                workspaceName,
                baseUri,
                jobId,
                inner);
        }
    }
}
