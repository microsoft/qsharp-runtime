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
    public interface IQuantumMachine
    {

        public delegate void ConfigureJob(object job);

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
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            ConfigureJob configureJobCallback);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineExecutionContext executionContext);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineExecutionContext executionContext,
            ConfigureJob configureJobCallback);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachineExecutionContext executionContext);

        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachineExecutionContext executionContext,
            ConfigureJob configureJobCallback);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input);

        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext);

        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            ConfigureJob configureJobCallback);
    }
}
