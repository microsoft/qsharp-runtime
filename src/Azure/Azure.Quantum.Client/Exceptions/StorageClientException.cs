// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Exceptions
{
    using System;

    /// <summary>
    /// The exception that is thrown when an error related to the Azure storage client occurs.
    /// </summary>
    public class StorageClientException : AzureQuantumException
    {
        private const string BaseMessage = "An exception related to the Azure storage client occurred";

        /// <summary>
        /// Initializes a new instance of the <see cref="StorageClientException"/> class with a default error message.
        /// </summary>
        public StorageClientException()
            : base(BaseMessage)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="StorageClientException"/> class with a specified error message.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        public StorageClientException(
            string message)
            : base($"{BaseMessage}: {message}")
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="StorageClientException"/> class with a specified error message and a reference to another exception that caused this one.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        /// <param name="inner">Exception that is the cause of the current one.</param>
        public StorageClientException(
            string message,
            Exception inner)
            : base($"{BaseMessage}: {message}", inner)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="StorageClientException"/> class with a specified error message, a reference to another exception that caused this one and more detailes that are specific to the storage client.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        /// <param name="containerName">Name of the container involved in the operation that caused the exception.</param>
        /// <param name="blobName">Name of the BLOB involved in the operation that caused the exception.</param>
        /// <param name="inner">Exception that is the cause of the current one.</param>
        public StorageClientException(
            string message,
            string containerName,
            string blobName,
            Exception inner)
            : base(
                  $"{BaseMessage}: {message}{Environment.NewLine}" +
                  $"ContainerName: {containerName}{Environment.NewLine}" +
                  $"BlobName: {blobName}",
                  inner)
        {
        }
    }
}
