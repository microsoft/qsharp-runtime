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

        /// <summary>
        /// Uploads the job input.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="input">The input.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// Container uri + Input uri without SAS.
        /// </returns>
        public override async Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            CancellationToken cancellationToken = default)
        {
            string containerName = GetContainerName(jobId);

            BlobContainerClient containerClient = await this.GetContainerClient(containerName);

            await this.StorageHelper.UploadBlobAsync(
                containerClient,
                Constants.Storage.InputBlobName,
                input,
                cancellationToken);

            Uri inputUri = containerClient
                .GetBlobClient(Constants.Storage.InputBlobName)
                .Uri;

            return (GetUriPath(containerClient.Uri), GetUriPath(inputUri));
        }

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri without SAS.</returns>
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
