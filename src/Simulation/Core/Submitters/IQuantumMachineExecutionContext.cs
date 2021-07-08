// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface to provide configuration details to manage execution.
    /// </summary>
    [Obsolete("No longer used. Some of these options might be supported in the future by the SubmissionOptions class.")]
    public interface IQuantumMachineExecutionContext
    {
        /// <summary>
        /// Represents the job refresh frequency to determine whether execution has been completed.
        /// </summary>
        int PollingInterval { get; set; }

        /// <summary>
        /// Represents how long to wait for the job to complete its execution.
        /// </summary>
        int Timeout { get; set; }
    }
}
