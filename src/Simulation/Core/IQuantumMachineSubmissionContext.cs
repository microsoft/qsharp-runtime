// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Runtime
{
    public interface IQuantumMachineSubmissionContext
    {
        string FriendlyName { get; set; }
        int Shots { get; set; }
    }
}
