// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Storage
{
    /// <summary>
    /// Job storage helper.
    /// </summary>
    public interface IJobStorageHelper
    {
        /// <summary>
        /// Gets the underlying storage helper.
        /// </summary>
        IStorageHelper StorageHelper { get; }

        /// <summary>
        /// Uploads the job input.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="input">The input.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Input uri.</returns>
        Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Uploads the job input.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="input">The input.</param>
        /// <param name="contentType">The MIME type indicating the content of the payload.</param>
        /// <param name="compress">A flag to indicate if the payload should be uploaded compressed to storage.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Input uri.</returns>
        Task<(string containerUri, string inputUri)> UploadJobInputAsync(
            string jobId,
            Stream input,
            string contentType,
            bool compress,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Uploads the job program output mapping.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="mapping">The job program output mapping.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Mapping uri.</returns>
        Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Downloads the job's execution output.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="destination">The destination stream.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        Task DownloadJobOutputAsync(
            string jobId,
            Stream destination,
            CancellationToken cancellationToken = default);
    }
}
