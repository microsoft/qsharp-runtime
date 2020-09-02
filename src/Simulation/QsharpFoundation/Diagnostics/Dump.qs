// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {

    /// # Summary
    /// Dumps the current target machine's status.
    ///
    /// # Input
    /// ## location
    /// Provides information on where to generate the machine's dump.
    ///
    /// # Output
    /// None.
    ///
    /// # Remarks
    /// This method allows you to dump information about the current status of the
    /// target machine into a file or some other location.
    /// The actual information generated and the semantics of `location`
    /// are specific to each target machine. However, providing an empty tuple as a location (`()`)
    /// or just omitting the `location` parameter typically means to generate the output to the console.
    ///
    /// For the local full state simulator distributed as part of the
    /// Quantum Development Kit, this method  expects a string with
    /// the path to a file in which it will write the wave function as a
    /// one-dimensional array of complex numbers, in which each element represents
    /// the amplitudes of the probability of measuring the corresponding state.
    function DumpMachine<'T> (location : 'T) : Unit {
    }

    /// # Summary
    /// Dumps the current target machine's status associated with the given qubits.
    ///
    /// # Input
    /// ## location
    /// Provides information on where to generate the state's dump.
    /// ## qubits
    /// The list of qubits to report.
    ///
    /// # Output
    /// None.
    ///
    /// # Remarks
    /// This method allows you to dump the information associated with the state of the
    /// given qubits into a file or some other location.
    /// The actual information generated and the semantics of `location`
    /// are specific to each target machine. However, providing an empty tuple as a location (`()`)
    /// typically means to generate the output to the console.
    ///
    /// For the local full state simulator distributed as part of the
    /// Quantum Development Kit, this method  expects a string with
    /// the path to a file in which it will write the
    /// state of the given qubits (i.e. the wave function of the corresponding  subsystem) as a
    /// one-dimensional array of complex numbers, in which each element represents
    /// the amplitudes of the probability of measuring the corresponding state.
    /// If the given qubits are entangled with some other qubit and their
    /// state can't be separated, it just reports that the qubits are entangled.
    function DumpRegister<'T> (location : 'T, qubits : Qubit[]) : Unit {
    }

}
