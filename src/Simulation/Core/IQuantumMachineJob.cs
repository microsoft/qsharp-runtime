// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface to track a job submitted to a quantum machine.
    /// </summary>
    public interface IQuantumMachineJob
    {
        /// <summary>
        /// Gets the ID of submitted job.
        /// </summary>
        string Id { get; }

        /// <summary>
        /// Gets whether job execution is in progress.
        /// </summary>
        bool InProgress { get; }

        /// <summary>
        /// Gets the status of the submitted job.
        /// </summary>
        string Status { get; }

        /// <summary>
        /// Gets whether the job execution completed successfully.
        /// </summary>
        bool Succeeded { get;  }

        /// <summary>
        /// Gets an URI to access the job.
        /// </summary>
        Uri Uri { get; }

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        Task CancelAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Refreshes the state of the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        Task RefreshAsync(CancellationToken cancellationToken = default);

    }
}
