// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;

    using global::Azure.Quantum.Jobs.Models;

    using Microsoft.Azure.Quantum.Utility;
    using Microsoft.Quantum.Runtime;

    /// <summary>
    /// Cloud job class.
    /// </summary>
    public class CloudJob : IQuantumMachineJob
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CloudJob"/> class.
        /// </summary>
        /// <param name="workspace">The workspace.</param>
        /// <param name="jobDetails">The job Details?.</param>
        public CloudJob(IWorkspace workspace, JobDetails jobDetails)
        {
            Ensure.NotNull(workspace, nameof(workspace));
            Ensure.NotNull(jobDetails, nameof(jobDetails));

            Workspace = workspace;
            Details = jobDetails;
        }

        /// <summary>
        /// Gets whether job execution failed.
        /// </summary>
        public bool Failed => !InProgress &&
                              !Succeeded;

        /// <summary>
        /// Gets the job id.
        /// </summary>
        public virtual string Id => Details?.Id;

        /// <summary>
        /// Gets the job id.
        /// </summary>
        public virtual string Name => Details?.Name;

        /// <summary>
        /// Gets whether the job execution has completed.
        /// </summary>
        public virtual bool InProgress => Status != "Cancelled" &&
                                  Status != "Failed" &&
                                  Status != "Succeeded";

        /// <summary>
        /// Gets the status of the submitted job.
        /// </summary>
        public virtual string Status => Details?.Status?.ToString();

        /// <summary>
        /// Gets whether the job execution completed successfully.
        /// </summary>
        public virtual bool Succeeded => Status == "Succeeded";

        /// <summary>
        /// Gets an URI to access the job.
        /// </summary>
        public virtual Uri Uri => GenerateUri();

        /// <summary>
        /// Gets the workspace.
        /// </summary>
        public virtual IWorkspace Workspace { get; private set; }

        /// <summary>
        /// Gets the unique identifier for the provider.
        /// </summary>
        public virtual string ProviderId => this.Details?.ProviderId;

        /// <summary>
        /// Gets the target identifier to run the job.
        /// </summary>
        public string Target => this.Details?.Target;

        /// <summary>
        /// If available, returns Uri with the results of the execution.
        /// </summary>>
        public virtual Uri OutputDataUri => (this.Details?.OutputDataUri != null)
            ? new Uri(this.Details?.OutputDataUri)
            : null;

        /// <summary>
        /// If available, returns the data format of the execution results.
        /// </summary>
        public virtual string OutputDataFormat => this.Details?.OutputDataFormat;

        /// <summary>
        /// Gets the underlying job Details?.
        /// </summary>
        public virtual JobDetails Details { get; private set; }

        /// <summary>
        /// Refreshes the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns></returns>
        public virtual async Task RefreshAsync(CancellationToken cancellationToken = default)
        {
            CloudJob job = (CloudJob)await this.Workspace.GetJobAsync(this.Details?.Id, cancellationToken);
            this.Details = job.Details;
        }

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns></returns>
        public virtual async Task CancelAsync(CancellationToken cancellationToken = default)
        {
            CloudJob job = (CloudJob)await this.Workspace.CancelJobAsync(this.Details?.Id, cancellationToken);
            this.Details = job.Details;
        }

        /// <summary>
        /// Keeps polling the server until the Job status changes to be not in progress.
        /// </summary>
        /// <param name="pollIntervalMilliseconds">Time to wait between polls. Defaults to 500.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns></returns>
        public async Task WaitForCompletion(int pollIntervalMilliseconds = 500, CancellationToken cancellationToken = default)
        {
            await this.RefreshAsync(cancellationToken);

            while (this.InProgress)
            {
                await Task.Delay(TimeSpan.FromMilliseconds(pollIntervalMilliseconds));
                await this.RefreshAsync();
            }
        }

        private Uri GenerateUri()
        {
            var uriStr = $"https://portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/{Workspace.SubscriptionId}/resourceGroups/{Workspace.ResourceGroupName}/providers/Microsoft.Quantum/Workspaces/{Workspace.WorkspaceName}/job_management?microsoft_azure_quantum_jobid={Id}";
            return new Uri(uriStr);
        }
    }
}
