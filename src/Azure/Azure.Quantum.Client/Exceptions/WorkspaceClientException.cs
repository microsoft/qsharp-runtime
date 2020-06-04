// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    public class WorkspaceClientException : AzureQuantumException
    {
        private const string BaseMessage = "An exception related to the Azure workspace client occurred";

        public WorkspaceClientException()
            : base(BaseMessage)
        {
        }

        public WorkspaceClientException(
            string message)
            : base($"{BaseMessage}: {message}")
        {
        }

        public WorkspaceClientException(
            string message,
            Exception inner)
            : base($"{BaseMessage}: {message}", inner)
        {
        }

        public WorkspaceClientException(
            string message,
            string subscriptionId,
            string resourceGroupName,
            string workspaceName,
            Uri baseUri,
            string jobId,
            Exception inner)
            : base(
                  $"{BaseMessage}: {message}{Environment.NewLine}" +
                  $"SubscriptionId: {subscriptionId}{Environment.NewLine}" +
                  $"ResourceGroupName: {resourceGroupName}{Environment.NewLine}" +
                  $"WorkspaceName: {workspaceName}{Environment.NewLine}" +
                  $"BaseUri: {baseUri}{Environment.NewLine}" +
                  $"JobId: {jobId}",
                  inner)
        {
        }
    }
}
