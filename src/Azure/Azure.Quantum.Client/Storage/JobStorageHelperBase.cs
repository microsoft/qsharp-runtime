// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Storage
{
    using System;
    using System.IO;
    using System.Threading;
    using System.Threading.Tasks;
    using Bond;
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
        /// <returns>Serialization protocol of the downloaded execution output.</returns>
        public async Task<ProtocolType> DownloadJobOutputAsync(
            string jobId,
            Stream destination,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            BlobContainerClient containerClient = await this.GetContainerClient(containerName);

            return await this.StorageHelper.DownloadBlobAsync(
                containerClient,
                "rawOutputData", // TODO: 14643
                destination,
                cancellationToken);
        }

        /// <summary>
        /// Uploads the job input.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="input">The input.</param>
        /// <param name="protocol">Serialization protocol of the input to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Input uri.</returns>
        public abstract Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="protocol">Serialization protocol of the mapping to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri.</returns>
        public abstract Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the container client.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <returns>Container client.</returns>
        protected abstract Task<BlobContainerClient> GetContainerClient(string containerName);

        protected static string GetContainerName(string jobId)
        {
            return Constants.Storage.ContainerNamePrefix + jobId.ToLowerInvariant();
        }
    }
}
