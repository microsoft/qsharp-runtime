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
    using Microsoft.WindowsAzure.Storage.Blob;

    public interface IStorageHelper
    {
        /// <summary>
        /// Downloads the BLOB.
        /// </summary>
        /// <param name="containerClient">Container client.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="destination">The destination.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Serialization protocol of the downloaded BLOB.</returns>
        Task<ProtocolType> DownloadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream destination,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Uploads the BLOB.
        /// </summary>
        /// <param name="containerClient">Container client.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="input">The input.</param>
        /// <param name="protocol">Serialization protocol of the BLOB to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>async task.</returns>
        Task UploadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream input,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the BLOB sas URI.
        /// </summary>
        /// <param name="connectionString">Storage account connection string.</param>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Blob uri.</returns>
        string GetBlobSasUri(
            string connectionString,
            string containerName,
            string blobName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions);

        /// <summary>
        /// Gets the BLOB container sas URI.
        /// </summary>
        /// <param name="connectionString">Storage account connection string.</param>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="expiryInterval">The expiry interval.</param>
        /// <param name="permissions">The permissions.</param>
        /// <returns>Container uri.</returns>
        string GetBlobContainerSasUri(
            string connectionString,
            string containerName,
            TimeSpan expiryInterval,
            SharedAccessBlobPermissions permissions);
    }
}
