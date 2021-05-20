// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface to access the results of a program executed in a quantum machine.
    /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
    /// </summary>
    [Obsolete("No longer used.")]
    public interface IQuantumMachineOutput<TOutput>
    {
        /// <summary>
        /// Gets a histogram of outputs.
        /// The key is the output and the value is its frequency.
        /// </summary>
        IReadOnlyDictionary<TOutput, double> Histogram { get; }

        /// <summary>
        /// Gets the job associated to the output.
        /// </summary>
        IQuantumMachineJob Job { get; }

        /// <summary>
        /// Gets the number of times the program was executed.
        /// </summary>
        int Shots { get; }
    }
}
