// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime.Submitters
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
        /// The default submission options.
        /// </summary>
        public static SubmissionOptions Default { get; } = new SubmissionOptions("", 500);

        private SubmissionOptions(string friendlyName, int shots) => 
            (this.FriendlyName, this.Shots) = (friendlyName, shots);

        /// <summary>
        /// Updates the submission options with the provided values.
        /// </summary>
        /// <param name="friendlyName">The new friendly name, or <c>null</c> to leave unchanged.</param>
        /// <param name="shots">The new number of shots, or <c>null</c> to leave unchanged.</param>
        /// <returns>The updated submission options.</returns>
        public SubmissionOptions With(string? friendlyName = null, int? shots = null) =>
            new SubmissionOptions(friendlyName ?? this.FriendlyName, shots ?? this.Shots);
    }
}
