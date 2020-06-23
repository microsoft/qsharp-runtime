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
    using global::Azure.Storage.Blobs.Models;
    using Microsoft.Azure.Quantum.Exceptions;
    using Microsoft.WindowsAzure.Storage;
    using Microsoft.WindowsAzure.Storage.Blob;

    internal class StorageHelper : IStorageHelper
    {
        /// <summary>
        /// Downloads the BLOB.
        /// </summary>
        /// <param name="containerClient">Container client.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="destination">The destination.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Serialization protocol of the downloaded BLOB.</returns>
        public async Task<ProtocolType> DownloadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream destination,
            CancellationToken cancellationToken = default)
        {
            try
            {
                BlobClient blob = containerClient.GetBlobClient(blobName);
                await blob.DownloadToAsync(destination, cancellationToken);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not download BLOB", containerClient.Name, blobName);
            }

            return ProtocolType.COMPACT_PROTOCOL;
        }

        /// <summary>
        /// Uploads the BLOB.
        /// </summary>
        /// <param name="containerClient">Container client.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="input">The input.</param>
        /// <param name="protocol">Serialization protocol of the BLOB to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Async task.</returns>
        public async Task UploadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream input,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // Ensure container is created
                await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob, cancellationToken: cancellationToken);

                // Upload blob
                BlobClient blob = containerClient.GetBlobClient(blobName);
                await blob.UploadAsync(input, overwrite: true, cancellationToken);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not upload BLOB", containerClient.Name, blobName);
            }
        }

        /// <summary>
        /// Gets the BLOB sas URI.
        /// </summary>
        /// <param name="connectionString">Storage account connection string.</param>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Blob uri.</returns>
        public string GetBlobSasUri(
            string connectionString,
            string containerName,
            string blobName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions)
        {
            try
            {
                SharedAccessBlobPolicy adHocSAS = CreateSharedAccessBlobPolicy(expiryInterval, permissions);

                CloudBlob blob = CloudStorageAccount
                    .Parse(connectionString)
                    .CreateCloudBlobClient()
                    .GetContainerReference(containerName)
                    .GetBlobReference(blobName);

                return blob.Uri + blob.GetSharedAccessSignature(adHocSAS);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not get BLOB shared access signature URI", containerName, blobName);
            }
        }

        /// <summary>
        /// Gets the BLOB container sas URI.
        /// </summary>
        /// <param name="connectionString">Storage account connection string.</param>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Container uri.</returns>
        public string GetBlobContainerSasUri(
            string connectionString,
            string containerName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions)
        {
            try
            {
                SharedAccessBlobPolicy adHocPolicy = CreateSharedAccessBlobPolicy(expiryInterval, permissions);

                // Generate the shared access signature on the container, setting the constraints directly on the signature.
                CloudBlobContainer container = CloudStorageAccount
                    .Parse(connectionString)
                    .CreateCloudBlobClient().GetContainerReference(containerName);

                return container.Uri + container.GetSharedAccessSignature(adHocPolicy, null);
            }
            catch (Exception ex)
            {
                throw CreateException(ex, "Could not get BLOB container shared access signature URI", containerName);
            }
        }

        private StorageClientException CreateException (
            Exception inner,
            string message,
            string containerName = "",
            string blobName = "")
        {
            return new StorageClientException(
                message,
                containerName,
                blobName,
                inner);
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
