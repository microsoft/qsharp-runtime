// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Bond;
using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace Microsoft.Azure.Quantum.Storage
{
    internal class StorageHelper : IStorageHelper
    {
        private readonly string connectionString;
        private readonly CloudStorageAccount storageAccount;

        /// <summary>
        /// Initializes a new instance of the <see cref="StorageHelper"/> class.
        /// </summary>
        /// <param name="connectionString">The connection string.</param>
        public StorageHelper(string connectionString)
        {
            this.connectionString = connectionString;

            try
            {
                this.storageAccount = CloudStorageAccount.Parse(connectionString);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "An error related to the cloud storage account occurred",
                    connectionString,
                    string.Empty,
                    string.Empty,
                    ex);
            }
        }

        /// <summary>
        /// Downloads the BLOB.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="destination">The destination.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Serialization protocol of the downloaded BLOB.</returns>
        public async Task<ProtocolType> DownloadBlobAsync(
            string containerName,
            string blobName,
            Stream destination,
            CancellationToken cancellationToken = default)
        {
            try
            {
                BlobClient blob = await this.GetBlobClient(containerName, blobName, false, cancellationToken);
                await blob.DownloadToAsync(destination, cancellationToken);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "Could not download BLOB",
                    connectionString,
                    containerName,
                    blobName,
                    ex);
            }

            return ProtocolType.COMPACT_PROTOCOL;
        }

        /// <summary>
        /// Uploads the BLOB.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="input">The input.</param>
        /// <param name="protocol">Serialization protocol of the BLOB to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Async task.</returns>
        public async Task UploadBlobAsync(
            string containerName,
            string blobName,
            Stream input,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default)
        {
            try
            {
                BlobClient blob = await this.GetBlobClient(containerName, blobName, true, cancellationToken);
                await blob.UploadAsync(input, overwrite: true, cancellationToken);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "Could not upload BLOB",
                    connectionString,
                    containerName,
                    blobName,
                    ex);
            }
        }

        /// <summary>
        /// Gets the BLOB sas URI.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Blob uri.</returns>
        public string GetBlobSasUri(
            string containerName,
            string blobName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions)
        {
            try
            {
                SharedAccessBlobPolicy adHocSAS = CreateSharedAccessBlobPolicy(expiryInterval, permissions);

                CloudBlob blob = this.storageAccount
                    .CreateCloudBlobClient()
                    .GetContainerReference(containerName)
                    .GetBlobReference(blobName);

                return blob.Uri + blob.GetSharedAccessSignature(adHocSAS);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "Could not get BLOB shared access signature URI",
                    connectionString,
                    containerName,
                    blobName,
                    ex);
            }

        }

        /// <summary>
        /// Gets the BLOB container sas URI.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Container uri.</returns>
        public string GetBlobContainerSasUri(
            string containerName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions)
        {
            try
            {
                SharedAccessBlobPolicy adHocPolicy = CreateSharedAccessBlobPolicy(expiryInterval, permissions);

                // Generate the shared access signature on the container, setting the constraints directly on the signature.
                CloudBlobContainer container = this.storageAccount.CreateCloudBlobClient().GetContainerReference(containerName);
                return container.Uri + container.GetSharedAccessSignature(adHocPolicy, null);
            }
            catch (Exception ex)
            {
                throw new StorageClientException(
                    "Could not get BLOB container sas URI",
                    connectionString,
                    containerName,
                    string.Empty,
                    ex);
            }
        }

        private async Task<BlobClient> GetBlobClient(
            string containerName,
            string blobName,
            bool createContainer,
            CancellationToken cancellationToken)
        {
            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
            BlobContainerClient blobContainerClient = blobServiceClient.GetBlobContainerClient(containerName);

            if (createContainer)
            {
                await blobContainerClient.CreateIfNotExistsAsync(PublicAccessType.Blob, cancellationToken: cancellationToken);
            }

            return blobContainerClient.GetBlobClient(blobName);
        }

        private static SharedAccessBlobPolicy CreateSharedAccessBlobPolicy(
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions)
        {
            return new SharedAccessBlobPolicy()
            {
                // When the start time for the SAS is omitted, the start time is assumed to be the time when the storage service receives the request.
                // Omitting the start time for a SAS that is effective immediately helps to avoid clock skew.
                SharedAccessExpiryTime = DateTime.UtcNow.Add(expiryInterval),
                Permissions = permissions,
            };
        }
    }
}
