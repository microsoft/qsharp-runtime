// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    /// <summary>
    /// Extension methods for Workspace.
    /// </summary>
    public static class WorkspaceExtensions
    {
        /// <summary>
        /// Submits the job.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="jobDefinition">The job definition.</param>
        /// <returns>The job response.</returns>
        public static CloudJob SubmitJob(
            this IWorkspace workspace,
            CloudJob jobDefinition)
        {
            return workspace.SubmitJobAsync(jobDefinition).GetAwaiter().GetResult();
        }

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="jobId">The job identifier.</param>
        /// <returns>The job response.</returns>
        public static CloudJob CancelJob(this IWorkspace workspace,  string jobId)
        {
            return workspace.CancelJobAsync(jobId).GetAwaiter().GetResult();
        }

        /// <summary>
        /// Gets the job.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="jobId">The job identifier.</param>
        /// <returns>The job response.</returns>
        public static CloudJob GetJob(this IWorkspace workspace, string jobId)
        {
            return workspace.GetJobAsync(jobId).GetAwaiter().GetResult();
        }
    }
}
