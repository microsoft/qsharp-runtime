// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Simulation.Common.Exceptions
{
    public class QuantumProcessorTranslationException : Exception
    {
        public QuantumProcessorTranslationException(string message = "An exception occurred while performing a translation on a quantum processor.")
            : base(message)
        {
        }
    }
}
