// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    public class AzureQuantumException : Exception
    {
        public AzureQuantumException()
            : base("An exception related to Azure quantum occurred")
        {
        }

        public AzureQuantumException(string message)
            : base(message)
        {
        }

        public AzureQuantumException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
