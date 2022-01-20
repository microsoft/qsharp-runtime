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

    public class LinkedStorageJobHelper : JobStorageHelperBase
    {
        private readonly IWorkspace workspace;

        /// <summary>
        /// Initializes a new instance of the <see cref="LinkedStorageJobHelper"/> class.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        public LinkedStorageJobHelper(IWorkspace workspace)
        {
            this.workspace = workspace;
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

            BlobContainerClient containerClient = await this.GetContainerClient(containerName);

            if (compress)
            {
                var compressedInput = new MemoryStream();
                await Compression.Compress(input, compressedInput);
                data = compressedInput;
                encoding = "gzip";
            }

            await this.StorageHelper.UploadBlobAsync(
                containerClient: containerClient,
                blobName: Constants.Storage.InputBlobName,
                input: data,
                contentType: contentType,
                contentEncoding: encoding,
                cancellationToken);

            Uri inputUri = containerClient
                .GetBlobClient(Constants.Storage.InputBlobName)
                .Uri;

            return (GetUriPath(containerClient.Uri), GetUriPath(inputUri));
        }

        /// <inheritdoc/>
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

            Uri mappingUri = containerClient
                .GetBlobClient(Constants.Storage.MappingBlobName)
                .Uri;

            return (GetUriPath(containerClient.Uri), GetUriPath(mappingUri));
        }

        protected override async Task<BlobContainerClient> GetContainerClient(string containerName, CancellationToken cancellationToken = default)
        {
            // Calls the service to get a container SAS Uri
            var containerUri = await this.workspace.GetSasUriAsync(
                containerName: containerName, 
                cancellationToken: cancellationToken);

            return new BlobContainerClient(new Uri(containerUri));
        }

        private string GetUriPath(Uri uri)
        {
            return uri.GetLeftPart(UriPartial.Path);
        }
    }
}
