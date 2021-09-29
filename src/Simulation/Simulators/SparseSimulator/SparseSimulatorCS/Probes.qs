// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.SparseSimulation {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    // These internal operations are physically unrealistic diagnostic 
    //   tools that can read amplitudes and probabilities 
    //   from a quantum state directly without modifyng it. 

    // Returns an output with the same distribution 
    // as measuring all the qubits, but does not 
    // modify the quantum state. 
    internal function Sample(register : Qubit[]) : Bool[] {
        body intrinsic;
    }

    // Asserts that if the qubits in `register` were measured, they would pass some check.
    // The measurement would product an array of boolean values, so the argument `assertion`
    // should check whether an input array of boolean values, representing a measurement
    // output, satisfies some criteria.
    operation AssertSample(assertion : (Bool[] -> Bool), register : Qubit[]) : Unit {
        Fact(assertion(Sample(register)), "Sampling failed");
    }
}
