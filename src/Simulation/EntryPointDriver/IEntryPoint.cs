// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// The interface between the entry point and the command-line program.
    /// </summary>
    /// <remarks>
    /// Contains entry point properties needed by the command-line interface and allows the entry point to use
    /// command-line arguments. The implementation of this interface is code-generated.
    /// </remarks>
    public interface IEntryPoint
    {
        /// <summary>
        /// The name of the entry point.
        /// </summary>
        string Name { get; }

        /// <summary>
        /// The summary from the entry point's documentation comment.
        /// </summary>
        string Summary { get; }

        /// <summary>
        /// The command-line options corresponding to the entry point's parameters.
        /// </summary>
        IEnumerable<Option> Options { get; }

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The submission settings.</param>
        /// <returns>The exit code.</returns>
        Task<int> Submit(ParseResult parseResult, AzureSettings settings);

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The driver settings.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The exit code.</returns>
        Task<int> Simulate(ParseResult parseResult, DriverSettings settings, string simulator);
    }
}
