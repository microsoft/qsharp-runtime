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

    // Returns the amplitude of the quantum state which has a specific qubit
    // label (e.g., "|101>" has label 5)
    internal function GetAmplitudeFromInt(qubit : Qubit[], label : Int) : Complex {
        body intrinsic;
    }
    internal function GetAmplitude(qubit : Qubit[], label : BigInt) : Complex {
        body intrinsic;
    }

    // Asserts (within some tolerance) that the probability of measuring the result passed as 
    // stateIndex is a specific value.
    operation AssertProbBigInt (stateIndex : BigInt, expected : Double, qubits : Microsoft.Quantum.Arithmetic.LittleEndian, tolerance : Double) : Unit {
       Fact(AbsD(AbsSquaredComplex  (GetAmplitude(qubits!, stateIndex)) - expected) < tolerance, "Probability failed");
    }

    // Asserts that the amplitudes of an array of states in superposition on a collection of qubits are equal 
    // (within tolerance) to a specified array, up to a global phase. 
    operation AssertAmplitudes(stateIndices : BigInt[], expected : Complex[], qubits : Microsoft.Quantum.Arithmetic.LittleEndian, tolerance : Double) : Unit {
        let basicC = GetAmplitude(qubits!, stateIndices[0]);
        let invC = Complex(basicC::Real/AbsSquaredComplex(basicC), basicC::Imag/AbsSquaredComplex(basicC));
        let expInv = Complex(expected[0]::Real/AbsSquaredComplex(expected[0]), expected[0]::Imag/AbsSquaredComplex(expected[0]));
        for idx in 0..Length(stateIndices)-1 {
            let c = TimesC(GetAmplitude(qubits!, stateIndices[idx]), invC);
            let expC = TimesC(expected[idx], expInv);
            Fact(AbsD(c::Real  - expC::Real) + AbsD(c::Imag - expC::Imag) < 0.001, "Amplitude incorrect");
        }
    }

    // Asserts that if the qubits in `register` were measured, they would pass some check.
    // The measurement would product an array of boolean values, so the argument `assertion`
    // should check whether an input array of boolean values, representing a measurement
    // output, satisfies some criteria.
    operation AssertSample(assertion : (Bool[] -> Bool), register : Qubit[]) : Unit {
        Fact(assertion(Sample(register)), "Sampling failed");
    }
}
