// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Mock
{
    /// <summary>
    /// A quantum machine that always has an error.
    /// </summary>
    internal class ErrorQuantumMachine : IQuantumMachine
    {
        /// <summary>
        /// The target ID for the error quantum machine.
        /// </summary>
        internal const string TargetId = "test.error";

        public string ProviderId => nameof(ErrorQuantumMachine);

        public string Target => TargetId;

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input, IQuantumMachineSubmissionContext submissionContext) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachine.ConfigureJob configureJobCallback) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input, IQuantumMachineExecutionContext executionContext) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineExecutionContext executionContext,
            IQuantumMachine.ConfigureJob configureJobCallback) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachineExecutionContext executionContext) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachineExecutionContext executionContext,
            IQuantumMachine.ConfigureJob configureJobCallback) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input) =>
            throw new AzureQuantumException("This quantum machine always has an error.");

        public Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input, IQuantumMachineSubmissionContext submissionContext) => 
            SubmitAsync(info, input);

        public Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            IQuantumMachineSubmissionContext submissionContext,
            IQuantumMachine.ConfigureJob configureJobCallback) =>
            SubmitAsync(info, input);

        public (bool IsValid, string Message) Validate<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info, TInput input) =>
            (false, "This quantum machine always has an error.");
    }
}
