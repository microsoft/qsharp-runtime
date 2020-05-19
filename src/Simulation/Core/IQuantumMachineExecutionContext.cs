// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Runtime
{
    public interface IQuantumMachineExecutionContext
    {
        int PollingInterval { get; set; }
        int Timeout { get; set; }
    }
}
