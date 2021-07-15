// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface to provide configuration details to submit a job.
    /// </summary>
    [Obsolete("Replaced by SubmissionOptions.")]
    public interface IQuantumMachineSubmissionContext
    {
        /// <summary>
        /// Represents the friendly name assigned to the job.
        /// </summary>
        string FriendlyName { get; set; }

        /// <summary>
        /// Represents the number of times the program will be executed.
        /// </summary>
        int Shots { get; set; }
    }
}
