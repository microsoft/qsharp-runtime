// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Storage
{
    using System;
    using System.IO;
    using System.Threading;
    using System.Threading.Tasks;

    using global::Azure.Storage.Blobs;

    using Microsoft.Azure.Quantum.Utility;

    public abstract class JobStorageHelperBase : IJobStorageHelper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="JobStorageHelperBase"/> class.
        /// </summary>
        public JobStorageHelperBase()
        {
            this.StorageHelper = new StorageHelper();
            this.ExpiryInterval = TimeSpan.FromDays(Constants.Storage.ExpiryIntervalInDays);
        }

        /// <summary>
        /// Gets the underlying storage helper.
        /// </summary>
        public IStorageHelper StorageHelper { get; }

        /// <summary>
        /// Gets the expiry interval.
        /// </summary>
        protected TimeSpan ExpiryInterval { get; private set; }

        /// <summary>
        /// Downloads the job's execution output.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="destination">The destination stream.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Async task.</returns>
        public async Task DownloadJobOutputAsync(
            string jobId,
            Stream destination,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            BlobContainerClient containerClient = await this.GetContainerClient(containerName);
            await this.StorageHelper.DownloadBlobAsync(
                containerClient,
                "rawOutputData", // TODO: 14643
                destination,
                cancellationToken);

            return;
        }

        /// <inheritdoc/>
        public abstract Task<(string containerUri, string inputUri)> UploadJobInputAsync(
                string jobId,
                Stream input,
                string contentType,
                bool compress,
                CancellationToken cancellationToken = default);

        /// <inheritdoc/>
        public Task<(string containerUri, string inputUri)> UploadJobInputAsync(
                string jobId,
                Stream input,
                CancellationToken cancellationToken = default) =>
            this.UploadJobInputAsync(jobId, input, null, false, cancellationToken);

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri.</returns>
        public abstract Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the container client.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Container client.</returns>
        protected abstract Task<BlobContainerClient> GetContainerClient(string containerName, CancellationToken cancellationToken = default);

        protected static string GetContainerName(string jobId)
        {
            return Constants.Storage.ContainerNamePrefix + jobId.ToLowerInvariant();
        }
    }
}
