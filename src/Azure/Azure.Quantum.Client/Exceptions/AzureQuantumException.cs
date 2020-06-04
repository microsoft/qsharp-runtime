// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    /// <summary>
    /// The exception that is thrown when an error related to Azure quantum occurs.
    /// </summary>
    public class AzureQuantumException : Exception
    {

        /// <summary>
        /// Initializes a new instance of the <see cref="AzureQuantumException"/> class with a default error message.
        /// </summary>
        public AzureQuantumException()
            : base("An exception related to Azure quantum occurred")
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="AzureQuantumException"/> class with a specified error message.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        public AzureQuantumException(string message)
            : base(message)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="AzureQuantumException"/> class with a specified error message and a reference to another exception that caused this one.
        /// </summary>
        /// <param name="message">Error message that explains the reason for the exception.</param>
        /// <param name="inner">Exception that is the cause of the current one.</param>
        public AzureQuantumException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
