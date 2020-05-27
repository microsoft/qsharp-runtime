// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Azure.Quantum.Exceptions
{
    public class AzureQuantumException : Exception
    {
        public AzureQuantumException(string message = "An exception related to the Azure quantum service or storage occurred.")
            : base(message)
        {
        }
    }
}
