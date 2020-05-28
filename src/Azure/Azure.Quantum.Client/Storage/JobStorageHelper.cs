// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.Quantum.Utility;
using Microsoft.WindowsAzure.Storage.Blob;

namespace Microsoft.Azure.Quantum.Storage
{
    public class JobStorageHelper : IJobStorageHelper
    {
        private readonly TimeSpan expiryInterval;

        /// <summary>
        /// Initializes a new instance of the <see cref="JobStorageHelper"/> class.
        /// </summary>
        /// <param name="connectionString">The connection string.</param>
        public JobStorageHelper(string connectionString)
        {
            this.StorageHelper = new StorageHelper(connectionString);
            this.expiryInterval = TimeSpan.FromDays(Constants.Storage.ExpiryIntervalInDays);
        }

        /// <summary>
        /// Gets the underlying storage helper.
        /// </summary>
        public IStorageHelper StorageHelper { get; }

        /// <summary>
        /// Uploads the job input.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="input">The input.</param>
        /// <param name="protocol">Serialization protocol of the input to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// Container uri + Input uri.
        /// </returns>
        public async Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            await this.StorageHelper.UploadBlobAsync(
                containerName,
                Constants.Storage.InputBlobName,
                input,
                cancellationToken);

            string containerUri = this.StorageHelper.GetBlobContainerSasUri(
                containerName,
                this.expiryInterval,
                SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write | SharedAccessBlobPermissions.Read);

            string inputUri = this.StorageHelper.GetBlobSasUri(
                containerName,
                Constants.Storage.InputBlobName,
                this.expiryInterval,
                SharedAccessBlobPermissions.Read);

            return (containerUri, inputUri);
        }

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="protocol">Serialization protocol of the mapping to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri.</returns>
        public async Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            await this.StorageHelper.UploadBlobAsync(
                containerName,
                Constants.Storage.MappingBlobName,
                mapping,
                cancellationToken);

            string containerUri = this.StorageHelper.GetBlobContainerSasUri(
                containerName,
                this.expiryInterval,
                SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write | SharedAccessBlobPermissions.Read);

            string mappingUri = this.StorageHelper.GetBlobSasUri(
                containerName,
                Constants.Storage.MappingBlobName,
                this.expiryInterval,
                SharedAccessBlobPermissions.Read);

            return (containerUri, mappingUri);
        }

        /// <summary>
        /// Downloads the job's execution output.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="destination">The destination stream.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Serialization protocol of the downloaded execution output.</returns>
        public Task DownloadJobOutputAsync(
            string jobId,
            Stream destination,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            return this.StorageHelper.DownloadBlobAsync(
                containerName,
                "rawOutputData", // TODO: 14643
                destination,
                cancellationToken);
        }

        private static string GetContainerName(string jobId)
        {
            return Constants.Storage.ContainerNamePrefix + jobId.ToLowerInvariant();
        }
    }
}
