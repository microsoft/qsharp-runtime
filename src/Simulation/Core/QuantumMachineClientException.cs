// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Runtime
{
    public class QuantumMachineClientException : Exception
    {
        public QuantumMachineClientException()
            : base("An exception occurred in the quantum machine client.")
        {
        }

        public QuantumMachineClientException(string message)
            : base(message)
        {
        }

        public QuantumMachineClientException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
