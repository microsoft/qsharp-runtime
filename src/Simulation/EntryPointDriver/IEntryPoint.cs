// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
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
        /// Generates payload for Azure Quantum for the entry point.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The generate Azure payload settings.</param>
        /// <returns>The exit code of the payload generation operation. The exit code is 0 when the operation is successful, a non-zero integer value otherwise.</returns>
        Task<int> GenerateAzurePayload(ParseResult parseResult, GenerateAzurePayloadSettings settings);

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The submission settings.</param>
        /// <returns>The exit code of the submssion operation. The exit code is 0 when the operation is successful, a non-zero integer value otherwise.</returns>
        Task<int> Submit(ParseResult parseResult, AzureSettings settings);

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The driver settings.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The exit code of the simulation operation. The exit code is 0 when the operation is successful, a non-zero integer value otherwise.</returns>
        Task<int> Simulate(ParseResult parseResult, DriverSettings settings, string simulator);
    }
}
