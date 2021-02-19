// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    @Test("QuantumSimulator")
    // TODO: Disabled until we have a noise model for Rz.
    // @Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")
    operation TestTeleport() : Unit {
        use q1 = Qubit();
        use q2 = Qubit();
        use q3 = Qubit();

        // create a Bell pair
        H(q1);
        CNOT(q1, q2);

        // create quantum state
        H(q3);
        Rz(1.1, q3);

        // teleport
        CNOT(q3, q2);
        H(q3);
        Controlled X([q2], q1);
        Controlled Z([q3], q1);

        // check teleportation success
        Rz(-1.1, q1);
        H(q1);

        // Measure and make sure we get Zero.
        // We do so without use of diagnostics functions and operations, since
        // many don't exist yet at this point in the build.
        if M(q1) != Zero {
            fail "Expected Zero after teleportation, but got One.";
        }

        // Make sure all allocated qubits are retrurned to zero before release
        ResetAll([q1, q2, q3]);
    }

}
