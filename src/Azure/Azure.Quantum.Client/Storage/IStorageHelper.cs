﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Storage
{
    using System;
    using System.IO;
    using System.Threading;
    using System.Threading.Tasks;
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
        /// <returns>Async task.</returns>
        Task DownloadBlobAsync(
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
        /// <param name="contentType">The MIME type indicating the content of the payload.</param>
        /// <param name="contentEncoding">The blob encoding.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>async task.</returns>
        Task UploadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream input,
            string? contentType,
            string? contentEncoding,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Uploads the BLOB.
        /// </summary>
        /// <param name="containerClient">Container client.</param>
        /// <param name="blobName">Name of the BLOB.</param>
        /// <param name="input">The input.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>async task.</returns>
        Task UploadBlobAsync(
            BlobContainerClient containerClient,
            string blobName,
            Stream input,
            CancellationToken cancellationToken = default) => this.UploadBlobAsync(containerClient, blobName, input, null, null, cancellationToken);

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
