// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using Microsoft.Quantum.Simulation.Core;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Runtime.Submitters
{
    /// <summary>
    /// An interface for submitting Q# programs to Azure.
    /// </summary>
    public interface IQSharpSubmitter
    {
        /// <summary>
        /// TODO.
        /// </summary>
        // TODO: Uncomment.
        //Target Target { get; }

        /// <summary>
        /// Submits a job to execute a Q# program without waiting for execution to complete.
        /// </summary>
        /// <typeparam name="TIn">The entry point argument type.</typeparam>
        /// <typeparam name="TOut">The entry point return type.</typeparam>
        /// <param name="entryPoint">The entry point information for the submitted program.</param>
        /// <param name="argument">The argument to the entry point.</param>
        /// <param name="options">Additional options for the submission.</param>
        /// <returns>The submitted job.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TIn, TOut>(
            EntryPointInfo<TIn, TOut> entryPoint, TIn argument, SubmissionOptions options);

        /// <summary>
        /// Validates a Q# program for execution on Azure Quantum.
        /// </summary>
        /// <typeparam name="TIn">The entry point argument type.</typeparam>
        /// <typeparam name="TOut">The entry point return type.</typeparam>
        /// <param name="entryPoint">The entry point information for the submitted program.</param>
        /// <param name="argument">The argument to the entry point.</param>
        /// <returns><c>null</c> if the program is valid, or an error message otherwise.</returns>
        string? Validate<TIn, TOut>(EntryPointInfo<TIn, TOut> entryPoint, TIn argument);
    }
}
