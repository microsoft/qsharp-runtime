// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Simulation.Common.Exceptions
{
    public class QuantumProcessorTranslationException : Exception
    {
        public QuantumProcessorTranslationException()
            : base("An exception occurred while performing a translation on a quantum processor.")
        {
        }

        public QuantumProcessorTranslationException(string message)
            : base(message)
        {
        }

        public QuantumProcessorTranslationException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
}
