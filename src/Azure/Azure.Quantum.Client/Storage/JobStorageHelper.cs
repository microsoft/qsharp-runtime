// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Storage
{
    using System;
    using System.IO;
    using System.Threading;
    using System.Threading.Tasks;
    using global::Azure.Storage.Blobs;
    using Microsoft.Azure.Quantum.Exceptions;
    using Microsoft.Azure.Quantum.Utility;
    using Microsoft.WindowsAzure.Storage;
    using Microsoft.WindowsAzure.Storage.Blob;

    public class JobStorageHelper : JobStorageHelperBase
    {
        private readonly string connectionString;

        /// <summary>
        /// Initializes a new instance of the <see cref="JobStorageHelper"/> class.
        /// </summary>
        /// <param name="connectionString">The connection string.</param>
        public JobStorageHelper(string connectionString)
        {
            this.connectionString = connectionString;

            try
            {
                _ = CloudStorageAccount.Parse(connectionString);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "An error related to the cloud storage account occurred",
                    ex);
            }
        }

        /// <inheritdoc/>
        public override async Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            string contentType,
            bool compress,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            string encoding = null;
            Stream data = input;

            if (compress)
            {
                var compressedInput = new MemoryStream();
                await Compression.Compress(input, compressedInput);
                data = compressedInput;
                encoding = "gzip";
            }

            BlobContainerClient containerClient = await this.GetContainerClient(containerName);

            await this.StorageHelper.UploadBlobAsync(
                containerClient,
                Constants.Storage.InputBlobName,
                input: data,
                contentType: contentType,
                contentEncoding: encoding,
                cancellationToken);

            string containerUri = this.StorageHelper.GetBlobContainerSasUri(
                this.connectionString,
                containerName,
                this.ExpiryInterval,
                SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write | SharedAccessBlobPermissions.Read);

            string inputUri = this.StorageHelper.GetBlobSasUri(
                this.connectionString,
                containerName,
                Constants.Storage.InputBlobName,
                this.ExpiryInterval,
                SharedAccessBlobPermissions.Read);

            return (containerUri, inputUri);
        }

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri.</returns>
        public override async Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);
            BlobContainerClient containerClient = await this.GetContainerClient(containerName);

            await this.StorageHelper.UploadBlobAsync(
                containerClient,
                Constants.Storage.MappingBlobName,
                mapping,
                cancellationToken);

            string containerUri = this.StorageHelper.GetBlobContainerSasUri(
                this.connectionString,
                containerName,
                this.ExpiryInterval,
                SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write | SharedAccessBlobPermissions.Read);

            string mappingUri = this.StorageHelper.GetBlobSasUri(
                this.connectionString,
                containerName,
                Constants.Storage.MappingBlobName,
                this.ExpiryInterval,
                SharedAccessBlobPermissions.Read);

            return (containerUri, mappingUri);
        }

        protected override Task<BlobContainerClient> GetContainerClient(string containerName, CancellationToken cancellationToken = default)
        {
            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
            return Task.FromResult(blobServiceClient.GetBlobContainerClient(containerName));
        }
    }
}
