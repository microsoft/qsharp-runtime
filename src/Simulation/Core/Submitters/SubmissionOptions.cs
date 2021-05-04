// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Options for a job submitted to Azure Quantum.
    /// </summary>
    public class SubmissionOptions
    {
        /// <summary>
        /// A name describing the job.
        /// </summary>
        public string FriendlyName { get; }

        /// <summary>
        /// The number of times the program will be executed.
        /// </summary>
        public int Shots { get; }

        /// <summary>
        /// Creates a new set of submission options.
        /// </summary>
        /// <param name="friendlyName">A name describing the job.</param>
        /// <param name="shots">The number of times the program will be executed.</param>
        public SubmissionOptions(string friendlyName, int shots) =>
            (this.FriendlyName, this.Shots) = (friendlyName, shots);
    }
}
