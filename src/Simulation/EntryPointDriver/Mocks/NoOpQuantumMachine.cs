// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Mocks
{
    /// <summary>
    /// A quantum machine that does nothing.
    /// </summary>
    internal class NoOpQuantumMachine : IQuantumMachine
    {
        /// <summary>
        /// The target ID for the no-op quantum machine.
        /// </summary>
        internal const string TargetId = "test.noop";

        public string ProviderId => nameof(NoOpQuantumMachine);

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
            Task.FromResult<IQuantumMachineJob>(new ExampleJob());

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
            (true, string.Empty);
    }
}
