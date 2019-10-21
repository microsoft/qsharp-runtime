// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Extensions.Diagnostics {

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.dumpmachine".
    @ Deprecated("Microsoft.Quantum.Diagnostics.DumpMachine")
    function DumpMachine<'T> (location : 'T) : Unit {
        return Microsoft.Quantum.Diagnostics.DumpMachine(location);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.dumpregister".
    @ Deprecated("Microsoft.Quantum.Diagnostics.DumpRegister")
    function DumpRegister<'T> (location : 'T, qubits : Qubit[]) : Unit {
        return Microsoft.Quantum.Diagnostics.DumpRegister(location, qubits);
    }

}
