// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Runtime.Submitters;
using Microsoft.Quantum.Simulation.Core;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Mock
{
    /// <summary>
    /// A submitter that does nothing.
    /// </summary>
    internal class NoOpSubmitter : IQirSubmitter, IQSharpSubmitter
    {
        /// <summary>
        /// The target for the no-op submitter.
        /// </summary>
        internal const string Target = "test.submitter.noop";

        public string ProviderId => nameof(NoOpSubmitter);

        string IAzureSubmitter.Target => Target;

        public Task<IQuantumMachineJob> SubmitAsync(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments, SubmissionOptions options) =>
            Task.FromResult<IQuantumMachineJob>(new ExampleJob());

        public Task<IQuantumMachineJob> SubmitAsync<TIn, TOut>(
            EntryPointInfo<TIn, TOut> entryPoint, TIn argument, SubmissionOptions options) =>
            Task.FromResult<IQuantumMachineJob>(new ExampleJob());

        public string? Validate<TIn, TOut>(EntryPointInfo<TIn, TOut> entryPoint, TIn argument) => null;

        public string? Validate(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments) =>
            null;
    }
}
