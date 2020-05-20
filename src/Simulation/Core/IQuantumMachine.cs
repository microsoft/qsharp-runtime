// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface that a quantum machine must implement.
    /// </summary>
    public interface IQuantumMachine
    {

        /// <summary>
        /// Function that configures a job object before submission.
        /// </summary>
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
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <param name="configureJobCallback">Function that configures a job object before submission.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            ConfigureJob configureJobCallback);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="executionContext">Provides configuration details to manage execution.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineExecutionContext executionContext);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="executionContext">Provides configuration details to manage execution.</param>
        /// <param name="configureJobCallback">Function that configures a job object before submission.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineExecutionContext executionContext,
            ConfigureJob configureJobCallback);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <param name="executionContext">Provides configuration details to manage execution.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
        Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachineExecutionContext executionContext);

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns an object that implements the IQuantumMachineOutput interface through which the execution output can be obtained.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <param name="executionContext">Provides configuration details to manage execution.</param>
        /// <param name="configureJobCallback">Function that configures a job object before submission.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineOutput interface.</returns>
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
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="submissionContext">Provides configuration details to submit a job.</param>
        /// <param name="configureJobCallback">Function that configures a job object before submission.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            ConfigureJob configureJobCallback);

        /// <summary>
        /// Validates whether a Q# program can be executed in the quantum machine.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>A (bool, string) tuple in which the first element represents whether the Q# program can be executed in the quantum machine and the second element is a string that provides details in case the Q# program is invalid.</returns>
        (bool IsValid, string Message) Validate<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input);
    }
}
