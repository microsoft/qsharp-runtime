// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.Azure.Quantum.Client.Models;
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
        /// <param name="jobDetails">The job details.</param>
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
        public string Id => Details.Id;

        /// <summary>
        /// Gets whether the job execution has completed.
        /// </summary>
        public bool InProgress => Status != "Cancelled" &&
                                  Status != "Failed" &&
                                  Status != "Succeeded";

        /// <summary>
        /// Gets the status of the submitted job.
        /// </summary>
        public string Status => Details.Status;

        /// <summary>
        /// Gets whether the job execution completed successfully.
        /// </summary>
        public bool Succeeded => Status == "Succeeded";

        /// <summary>
        /// Gets an URI to access the job.
        /// </summary>
        public Uri Uri => GenerateUri();

        /// <summary>
        /// Gets the workspace.
        /// </summary>
        public IWorkspace Workspace { get; private set; }

        /// <summary>
        /// Gets the job details.
        /// </summary>
        public JobDetails Details { get; private set; }

        /// <summary>
        /// Refreshes the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        public async Task RefreshAsync(CancellationToken cancellationToken = default)
        {
            CloudJob job = (CloudJob)await this.Workspace.GetJobAsync(this.Details.Id, cancellationToken);
            this.Details = job.Details;
        }

        /// <summary>
        /// Cancels the job.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        public async Task CancelAsync(CancellationToken cancellationToken = default)
        {
            CloudJob job = (CloudJob)await this.Workspace.CancelJobAsync(this.Details.Id, cancellationToken);
            this.Details = job.Details;
        }

        private Uri GenerateUri()
        {
            if (!(this.Workspace is Workspace cloudWorkspace))
            {
                throw new NotSupportedException($"{typeof(CloudJob)}'s Workspace is not of type {typeof(Workspace)} and does not have enough data to generate URI");
            }

            var uriStr = $"https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/{cloudWorkspace.SubscriptionId}/resourceGroups/{cloudWorkspace.ResourceGroupName}/providers/Microsoft.Quantum/Workspaces/{cloudWorkspace.WorkspaceName}/job_management?microsoft_azure_quantum_jobid={Id}";
            return new Uri(uriStr);
        }
    }
}
