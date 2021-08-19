// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Runtime.Submitters
{
    /// <summary>
    /// An interface for submitting QIR programs to Azure.
    /// </summary>
    public interface IQirSubmitter : IAzureSubmitter
    {
        /// <summary>
        /// Submits a job to execute a QIR program without waiting for execution to complete.
        /// </summary>
        /// <param name="qir">The QIR program as a byte stream.</param>
        /// <param name="entryPoint">The fully-qualified name of the entry point to execute.</param>
        /// <param name="arguments">The arguments to the entry point in the order in which they are declared.</param>
        /// <param name="options">Additional options for the submission.</param>
        /// <returns>The submitted job.</returns>
        Task<IQuantumMachineJob> SubmitAsync(
            Stream qir, string entryPoint, IReadOnlyList<Argument> arguments, SubmissionOptions options);

        /// <summary>
        /// Validates a QIR program for execution on Azure Quantum.
        /// </summary>
        /// <param name="qir">The QIR program as a byte stream.</param>
        /// <param name="entryPoint">The fully-qualified name of the entry point to execute.</param>
        /// <param name="arguments">The arguments to the entry point in the order in which they are declared.</param>
        /// <returns><c>null</c> if the program is valid, or an error message otherwise.</returns>
        string? Validate(Stream qir, string entryPoint, IReadOnlyList<Argument> arguments);
    }
}
