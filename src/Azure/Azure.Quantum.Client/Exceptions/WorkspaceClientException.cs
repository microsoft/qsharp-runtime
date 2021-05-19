// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    /// <summary>
    /// The exception that is thrown when an error related to the Azure workspace client occurs.
    /// </summary>
    public class WorkspaceClientException : AzureQuantumException
    {
        private const string BaseMessage = "An exception related to the Azure workspace client occurred";

        public string ErrorCode { get; }

        public int Status { get; }

        /// <summary>
        /// Initializes a new instance of the <see cref="WorkspaceClientException"/> class with a default error message.
        /// </summary>
        public WorkspaceClientException()
            : base(BaseMessage)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="WorkspaceClientException"/> class with a specified error message.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        public WorkspaceClientException(
            string message)
            : base($"{BaseMessage}: {message}")
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="WorkspaceClientException"/> class with a specified error message and a reference to another exception that caused this one.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        /// <param name="inner">Exception that is the cause of the current one.</param>
        public WorkspaceClientException(
            string message,
            Exception inner)
            : base($"{BaseMessage}: {message}", inner)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="WorkspaceClientException"/> class with a specified error message, a reference to another exception that caused this one and details about the Azure workspace client.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        /// <param name="subscriptionId">ID of the subscription used by the Azure workspace client.</param>
        /// <param name="resourceGroupName">Name of the resource group used by the Azure workspace client.</param>
        /// <param name="workspaceName">Name of the workspace used by the Azure workspace client.</param>
        /// <param name="location">Workspace's location (region).</param>
        /// <param name="jobId">ID of the job involved in the operation that caused the exception.</param>
        /// <param name="inner">Exception that is the cause of the current one.</param>
        public WorkspaceClientException(
            string message,
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            string location,
            string jobId,
            Exception inner)
            : base(
                  $"{BaseMessage}: {message}{Environment.NewLine}" +
                  $"SubscriptionId: {subscriptionId}{Environment.NewLine}" +
                  $"ResourceGroupName: {resourceGroupName}{Environment.NewLine}" +
                  $"WorkspaceName: {workspaceName}{Environment.NewLine}" +
                  $"Location: {location}{Environment.NewLine}" +
                  $"JobId: {jobId}{Environment.NewLine}" +
                  FormatInnerException(inner),
                  inner)
        {
            // Handle specific types of exceptions for additional data
            if (inner is global::Azure.RequestFailedException requestException)
            {
                this.ErrorCode = requestException.ErrorCode;
                this.Status = requestException.Status;
            }
        }

        /// <summary>
        /// Formats the contents of the inner exception in <see cref="WorkspaceClientException"/> so it can be included in the
        /// exception message and presented in an informative way.
        /// </summary>
        /// <param name="ex">Inner exception that we want to include in the outer exception message.</param>
        /// <return>
        /// A string representing the contents of the inner exception.
        /// </return>
        private static string FormatInnerException(Exception ex)
        {
            string formattedException = string.Empty;
            if (ex != null)
            {
                formattedException += $"Server Error: {ex.Message}{Environment.NewLine}";
            }

            return formattedException;
        }
    }
}
