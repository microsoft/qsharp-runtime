// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    public class StorageClientException : AzureQuantumException
    {
        private const string BaseMessage = "An exception related to the Azure storage client occurred";

        public StorageClientException()
            : base(BaseMessage)
        {
        }

        public StorageClientException(
            string message)
            : base($"{BaseMessage}: {message}")
        {
        }

        public StorageClientException(
            string message,
            Exception inner)
            : base($"{BaseMessage}: {message}", inner)
        {
        }

        public StorageClientException(
            string message,
            string connectionString,
            string containerName,
            string blobName,
            Exception inner)
            : base(
                  $"{BaseMessage}: {message}{Environment.NewLine}" +
                  $"ConnectionString: {connectionString}{Environment.NewLine}" +
                  $"ContainerName: {containerName}{Environment.NewLine}" +
                  $"BlobName: {blobName}",
                  inner)
        {
        }
    }
}
