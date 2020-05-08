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

        public Task<IQuantumMachineOutput<TOut>> ExecuteAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input) =>
            throw new NotImplementedException();

        public Task<IQuantumMachineJob> SubmitAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input) =>
            Task.FromResult<IQuantumMachineJob>(new DefaultJob());

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

            public Task CancelAsync(CancellationToken cancellationToken = default) => 
                throw new NotImplementedException();

            public Task RefreshAsync(CancellationToken cancellationToken = default) => 
                throw new NotImplementedException();
        }
    }
}
