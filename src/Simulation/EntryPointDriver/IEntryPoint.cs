using System;
using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// The interface between the entry point and the command-line program.
    /// </summary>
    /// <remarks>
    /// Contains entry point properties needed by the command-line interface and allows the entry point to use
    /// command-line arguments. The implementation of this interface is code-generated.
    /// </remarks>
    /// <typeparam name="T">The entry point's return type.</typeparam>
    public interface IEntryPoint<T>
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
        string DefaultSimulator { get; }

        /// <summary>
        /// Creates an instance of the default simulator if it is a custom simulator.
        /// </summary>
        /// <returns>An instance of the default custom simulator.</returns>
        /// <exception cref="InvalidOperationException">
        /// Thrown if the default simulator is not a custom simulator.
        /// </exception>
        IOperationFactory CreateDefaultCustomSimulator();

        /// <summary>
        /// Runs the entry point.
        /// </summary>
        /// <param name="factory">The operation factory to use.</param>
        /// <param name="parseResult">The result of parsing the command-line options.</param>
        /// <returns>The return value of the entry point.</returns>
        Task<T> Run(IOperationFactory factory, ParseResult parseResult);
    }
}
