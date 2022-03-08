// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;

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
        /// Additional target-specific parameters for the job.
        /// </summary>
        public ImmutableDictionary<string, string> InputParams { get; }

        /// <summary>
        /// The default submission options.
        /// </summary>
        public static SubmissionOptions Default { get; } =
            new SubmissionOptions("", 500, ImmutableDictionary<string, string>.Empty);

        private SubmissionOptions(string friendlyName, int shots, ImmutableDictionary<string, string> inputParams)
        {
            FriendlyName = friendlyName;
            Shots = shots;
            InputParams = inputParams;
        }

        /// <summary>
        /// Updates the submission options with the provided values.
        /// </summary>
        /// <param name="friendlyName">The new friendly name, or <c>null</c> to leave unchanged.</param>
        /// <param name="shots">The new number of shots, or <c>null</c> to leave unchanged.</param>
        /// <param name="inputParams">The new input parameters, or <c>null</c> to leave unchanged.</param>
        /// <returns>The updated submission options.</returns>
        public SubmissionOptions With(
            string? friendlyName = null,
            int? shots = null,
            ImmutableDictionary<string, string>? inputParams = null) =>
            new SubmissionOptions(friendlyName ?? FriendlyName, shots ?? Shots, inputParams ?? InputParams);
    }
}
