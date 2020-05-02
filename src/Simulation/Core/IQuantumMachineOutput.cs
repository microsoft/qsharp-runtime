// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface to access the results of a program executed in a quantum machine.
    /// </summary>
    public interface IQuantumMachineOutput
    {

        /// <summary>
        /// Gets an output probabilistically.
        /// Calls to this method are not deterministic, each call can return a different output.
        /// </summary>
        object GetOutput();

        /// <summary>
        /// Gets the most frequent output.
        /// If multiple outputs have the same frequency, it gets the first one in ascending order.
        /// </summary>
        object GetMostFrequentOutput();

        /// <summary>
        /// Gets a histogram of outputs.
        /// The key is the output and the value is its frequency.
        /// </summary>
        IDictionary<object, double> Histogram { get; }

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
