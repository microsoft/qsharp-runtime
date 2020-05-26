// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// A quantum machine that does nothing.
    /// </summary>
    internal class NothingMachine : IQuantumMachine
    {
        public string ProviderId => nameof(NothingMachine);

        public string Target => "Nothing";

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info, TInput input) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info,
                TInput input,
                IQuantumMachineSubmissionContext submissionContext) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info,
                TInput input, 
                IQuantumMachineSubmissionContext submissionContext,
                IQuantumMachine.ConfigureJob configureJobCallback) => 
            throw new NotSupportedException();

        public Task<IQuantumMachineOutput<TOutput>> ExecuteAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info,
                TInput input,
                IQuantumMachineExecutionContext executionContext) =>
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
            Task.FromResult<IQuantumMachineJob>(new DefaultJob());

        public Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info,
                TInput input,
                IQuantumMachineSubmissionContext submissionContext) =>
            throw new NotSupportedException();

        public Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info,
                TInput input, 
                IQuantumMachineSubmissionContext submissionContext, 
                IQuantumMachine.ConfigureJob configureJobCallback) =>
            throw new NotSupportedException();

        public (bool IsValid, string Message) Validate<TInput, TOutput>(
                EntryPointInfo<TInput, TOutput> info, TInput input) => 
            throw new NotSupportedException();

        /// <summary>
        /// A quantum machine job with default properties.
        /// </summary>
        private class DefaultJob : IQuantumMachineJob
        {
            public string Id { get; } = "00000000-0000-0000-0000-0000000000000";

            public string Status { get; } = "NotImplemented";

            public bool InProgress { get; } = false;

            public bool Succeeded { get; } = false;

            public bool Failed { get; } = true;

            public Uri Uri => new Uri("https://example.com/" + Id);

            public Task CancelAsync(CancellationToken cancellationToken = default) => throw new NotSupportedException();

            public Task RefreshAsync(CancellationToken cancellationToken = default) =>
                throw new NotSupportedException();
        }
    }
}
