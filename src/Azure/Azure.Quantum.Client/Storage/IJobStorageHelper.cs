// <copyright file="IJobStorageHelper.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Bond;

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
        /// <param name="protocol">Serialization protocol of the input to upload.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Container uri + Input uri.</returns>
        Task<(string containerUri, string inputUri)> UploadJobInputAsync(
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
        Task<(string containerUri, string mappingUri)> UploadJobMappingAsync(
            string jobId,
            Stream mapping,
            ProtocolType protocol = ProtocolType.COMPACT_PROTOCOL,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Downloads the job's execution output.
        /// </summary>
        /// <param name="jobId">The job id.</param>
        /// <param name="destination">The destination stream.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Serialization protocol of the downloaded execution output.</returns>
        Task<ProtocolType> DownloadJobOutputAsync(
            string jobId,
            Stream destination,
            CancellationToken cancellationToken = default);
    }
}
