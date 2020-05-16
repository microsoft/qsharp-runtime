// <copyright file="IWorkspace.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;

namespace Microsoft.Azure.Quantum
{
    /// <summary>
    /// IWorkspace interface.
    /// </summary>
    public interface IWorkspace
    {
        /// <summary>
        /// Submits the job.
        /// </summary>
        /// <param name="jobDefinition">The job definition.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job response.</returns>
        Task<CloudJob> SubmitJobAsync(
            CloudJob jobDefinition,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job response.</returns>
        Task<CloudJob> CancelJobAsync(
            string jobId,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the job.
        /// </summary>
        /// <param name="jobId">The job identifier.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>The job object.</returns>
        Task<CloudJob> GetJobAsync(
            string jobId,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Lists the jobs.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>List of jobs</returns>
        Task<IEnumerable<CloudJob>> ListJobsAsync(
            CancellationToken cancellationToken = default);
    }
}
