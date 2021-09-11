// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Runtime.Submitters;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// An interface for submitting Q# programs to Azure.
    /// </summary>
    // 
    // TODO: deprecate once IQSharpSubmitter is fully hooked up.
    //[Obsolete("Replaced by IQSharpSubmitter.")]
    public interface IQuantumMachine
    {
        /// <summary>
        /// TODO.
        /// </summary>
        string Target { get; }

        /// <summary>
        /// Function that configures a job object before submission.
        /// </summary>
        public delegate void ConfigureJob(object job);

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
