// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// The interface between the entry point and the command-line program.
    /// </summary>
    /// <remarks>
    /// Contains entry point properties needed by the command-line interface and allows the entry point to use
    /// command-line arguments. The implementation of this interface is code-generated.
    /// </remarks>
    /// <typeparam name="TIn">The entry point's argument type.</typeparam>
    /// <typeparam name="TOut">The entry point's return type.</typeparam>
    public interface IEntryPoint<TIn, TOut>
    {
        /// <summary>
        /// The summary from the entry point's documentation comment.
        /// </summary>
        string Summary { get; }

        /// <summary>
        /// The command-line options corresponding to the entry point's parameters.
        /// </summary>
        IEnumerable<Option> Options { get; }

        /// <summary>
        /// The name of the default simulator to use when simulating the entry point.
        /// </summary>
        string DefaultSimulatorName { get; }

        /// <summary>
        /// The default execution target when to use when submitting the entry point to Azure Quantum.
        /// </summary>
        string DefaultExecutionTarget { get; }

        /// <summary>
        /// Additional information about the entry point.
        /// </summary>
        EntryPointInfo<TIn, TOut> Info { get; }

        /// <summary>
        /// Creates an instance of the default simulator if it is a custom simulator.
        /// </summary>
        /// <returns>An instance of the default custom simulator.</returns>
        /// <exception cref="InvalidOperationException">
        /// Thrown if the default simulator is not a custom simulator.
        /// </exception>
        IOperationFactory CreateDefaultCustomSimulator();

        /// <summary>
        /// Creates the argument to the entry point based on the command-line parsing result.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <returns>The argument to the entry point.</returns>
        TIn CreateArgument(ParseResult parseResult);

        Type TargetIntrinsicsType { get; }
    }
}
