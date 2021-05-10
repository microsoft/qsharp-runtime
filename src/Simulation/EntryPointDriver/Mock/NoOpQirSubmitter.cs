// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Runtime.Submitters;

namespace Microsoft.Quantum.EntryPointDriver.Mock
{
    /// <summary>
    /// A QIR submitter that does nothing.
    /// </summary>
    internal class NoOpQirSubmitter : IQirSubmitter
    {
        /// <summary>
        /// The target ID for the no-op QIR submitter.
        /// </summary>
        internal const string TargetId = "test.noop";

        public string ProviderId => nameof(NoOpQirSubmitter);

        public string Target => TargetId;

        public Task<IQuantumMachineJob> SubmitAsync(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments, SubmissionOptions options) =>
            Task.FromResult<IQuantumMachineJob>(new ExampleJob());
    }
}
