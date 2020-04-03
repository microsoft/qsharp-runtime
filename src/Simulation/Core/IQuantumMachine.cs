// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface that a quantum machine must implement.
    /// </summary>
    /// <typeparam name="TJob">Type of job that handles the execution of a program in the quantum machine.</typeparam>
    /// <typeparam name="TRawResult">Type of result the quantum machine returns.</typeparam>
    public interface IQuantumMachine<TJob, TRawResult>
    {
        /// <summary>
        /// Gets the ID of the quantum machine provider.
        /// </summary>
        string ProviderId { get; }

        /// <summary>
        /// Gets the name of the target quantum machine.
        /// A provider may expose multiple targets that can be used to execute programs.
        /// Users may select which target they would like to be used for execution.
        /// </summary>
        string Target { get; }

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns its output.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>Sampled output of the quantum program</returns>
        Task<Tuple<TOutput, TRawResult>> ExecuteAsync<TInput, TOutput>(OperationInfo<TInput, TOutput> info, TInput input);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>A Job instance. Status and results from the execution can be retrieved from this instance.</returns>
        Task<TJob> SubmitAsync<TInput, TOutput>(OperationInfo<TInput, TOutput> info, TInput input);
    }
}
