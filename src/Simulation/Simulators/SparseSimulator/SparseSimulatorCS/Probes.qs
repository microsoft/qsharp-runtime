// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.SparseSimulation {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    // These operations are physically unrealistic diagnostic 
    //   tools that can read amplitudes and probabilities 
    //   from a quantum state directly without modifyng it. 

    // Returns an output with the same distribution 
    // as measuring all the qubits, but does not 
    // modify the quantum state. 
    function Sample(register : Qubit[]) : Bool[] {
        body intrinsic;
    }

    // Returns the amplitude of the quantum state which has a specific qubit
    // label (e.g., "|101>" has label 5)
    function GetAmplitudeFromInt(qubit : Qubit[], label : Int) : Complex {
        fail "Only implemented for SparseSimulator";
    }
    function GetAmplitude(qubit : Qubit[], label : BigInt) : Complex {
        fail "Only implemented for SparseSimulator";
    }

    // Asserts (within some tolerance) that the probability of measuring the result passed as 
    // stateIndex is a specific value.
    operation AssertProbBigInt (stateIndex : BigInt, expected : Double, qubits : Microsoft.Quantum.Arithmetic.LittleEndian, tolerance : Double) : Unit {
        Fact(AbsD(AbsSquaredComplex  (GetAmplitude(qubits!, stateIndex)) - expected) < tolerance, "Probability failed");
    }
}
