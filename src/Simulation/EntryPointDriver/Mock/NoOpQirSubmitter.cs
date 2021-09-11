// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Runtime.Submitters;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Mock
{
    /// <summary>
    /// A QIR submitter that does nothing.
    /// </summary>
    internal class NoOpQirSubmitter : IQirSubmitter
    {
        /// <summary>
        /// The target for the no-op QIR submitter.
        /// </summary>
        internal const string Target = "test.submitter.qir.noop";
        string IQirSubmitter.Target => Target;

        public Task<IQuantumMachineJob> SubmitAsync(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments, SubmissionOptions options) =>
            Task.FromResult<IQuantumMachineJob>(new ExampleJob());

        public string? Validate(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments) =>
            null;
    }
}
