namespace Microsoft.Quantum.Extensions.Diagnostics {
    open Microsoft.Quantum.Warnings;

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.dumpmachine".
    function DumpMachine<'T> (location : 'T) : Unit {
        _Renamed("Microsoft.Quantum.Diagnostics.Extensions.DumpMachine", "Microsoft.Quantum.Diagnostics.DumpMachine");
        return Microsoft.Quantum.Diagnostics.DumpMachine(location);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.diagnostics.dumpregister".
    function DumpRegister<'T> (location : 'T, qubits : Qubit[]) : Unit {
        _Renamed("Microsoft.Quantum.Diagnostics.Extensions.DumpRegister", "Microsoft.Quantum.Diagnostics.DumpRegister");
        return Microsoft.Quantum.Diagnostics.DumpRegister(location, qubits);
    }

}
