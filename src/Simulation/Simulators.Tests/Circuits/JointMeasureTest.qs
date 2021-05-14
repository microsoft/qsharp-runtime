// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    // From Microsoft.Quantum.Diagnostics Standard Library.
    internal function FormattedFailure<'T>(actual : 'T, expected : 'T, message : String) : Unit {
        fail $"{message}\n\tExpected:\t{expected}\n\tActual:\t{actual}";
    }

    // From Microsoft.Quantum.Diagnostics Standard Library.
    internal function EqualityFactR (actual : Result, expected : Result, message : String) : Unit {
        if (actual != expected) {
            FormattedFailure(actual, expected, message);
        }
    }

    // From Microsoft.Quantum.Arrays Standard Library.
    internal operation ApplyToEach<'T> (singleElementOperation : ('T => Unit), register : 'T[]) : Unit {
        for idxQubit in IndexRange(register) {
            singleElementOperation(register[idxQubit]);
        }
    }

    operation JointMeasureTest () : Unit {
        use qs = Qubit[2];
        let measOp = Measure(_, qs);
        let assertZero = AssertMeasurement(_, qs, Zero, _);
        let equalityZeroFact = EqualityFactR(_, Zero, _);
        let assertOne = AssertMeasurement(_, qs, One, _);
        let equalityOneFact = EqualityFactR(_, One, _);

        // Formally ensure that the starting state of all qubits is |0⟩.
        AssertAllZero(qs);

        assertZero([PauliZ, PauliZ], "PauliZ joint measurement should be Zero");
        equalityZeroFact(measOp([PauliZ, PauliZ]), "PauliZ joint measurement should be Zero");
        
        ApplyToEach(X, qs);
        assertZero([PauliZ, PauliZ], "After X, PauliZ joint measurement should be Zero");
        equalityZeroFact(measOp([PauliZ, PauliZ]), "After X, PauliZ joint measurement should be Zero");
        
        ApplyToEach(H, qs);
        assertZero([PauliX, PauliX], "After HX, PauliX joint measurement should be Zero");
        equalityZeroFact(measOp([PauliX, PauliX]), "After HX, PauliX joint measurement should be Zero");

        ApplyToEach(S, qs);
        assertZero([PauliY, PauliY], "After SHX, PauliY joint measurement should be Zero");
        equalityZeroFact(measOp([PauliY, PauliY]), "After SHX, PauliY joint measurement should be Zero");

        within {
            X(qs[0]); // Change the parity.
        }
        apply {

            assertOne([PauliY, PauliY], "After parity change and SHX, PauliY joint measurement should be One");
            equalityOneFact(measOp([PauliY, PauliY]), "After parity change and SHX, PauliY joint measurement should be One");
            ApplyToEach(Adjoint S, qs);

            assertOne([PauliX, PauliX], "After parity change and HX, PauliX joint measurement should be One");
            equalityOneFact(measOp([PauliX, PauliX]), "After parity change and HX, PauliX joint measurement should be One");
            ApplyToEach(H, qs);

            assertOne([PauliZ, PauliZ], "After parity change and X, PauliZ joint measurement should be One");
            equalityOneFact(measOp([PauliZ, PauliZ]), "After parity change and X, PauliZ joint measurement should be One");
            ApplyToEach(X, qs);

            assertOne([PauliZ, PauliZ], "After parity change, PauliZ joint measurement should be One");
            equalityOneFact(measOp([PauliZ, PauliZ]), "After parity change, PauliZ joint measurement should be One");
        }

        // The above sequence is effectively 𝑌, in that 𝑋𝑆⁺𝐻𝑋𝐻𝑆𝑋 = 𝑌. Because the within/apply undoes the 𝑋, which
        // means this code only works because we know the qubits start in the |0⟩ state. This may not work with other
        // states because the sequence is not actually equivalent to 𝟙 (identity).

        AssertAllZero(qs);

        within {
            H(qs[0]);
            CNOT(qs[0], qs[1]); // Establish Bell state.
        }
        apply {
            assertZero([PauliZ, PauliZ], "On Bell state, PauliZ joint measurement should be Zero");
            equalityZeroFact(measOp([PauliZ, PauliZ]), "On Bell state, PauliZ joint measurement should be Zero");

            assertZero([PauliX, PauliX], "On Bell state, PauliX joint measurement should be Zero");
            equalityZeroFact(measOp([PauliX, PauliX]), "On Bell state, PauliX joint measurement should be Zero");
        }

        // Since |β₀₀⟩ ≔ (|00⟩ + |11⟩) / √2 is the unique +1 eigenvector of 𝑋𝑋 and 𝑍𝑍, unwinding with the 
        // within/apply block and then asserting that everything is still actually in the |00⟩ state makes 
        // sure that the post-measurement state is correct.
        AssertAllZero(qs);

        // Possible other tests would use other Bell states that are also eigenstates of both 𝑋𝑋 and 𝑍𝑍, but 
        // with different eigenvalues. In particular, |βᵢⱼ⟩ = 𝑋^𝑖 𝑍^𝑗 |β₀₀⟩ should give a result of One when 
        // measuring [PauliX, PauliX] when 𝑗 = 1 and a result of One when measuring [PauliZ, PauliZ] when 𝑖 = 1.

        within {
            H(qs[0]); // Change the basis of one of the qubits
        }
        apply {
            assertZero([PauliX, PauliZ], "PauliX-PauliZ joint measurement should be Zero");
            equalityZeroFact(measOp([PauliX, PauliZ]), "PauliX-PauliZ joint measurement should be Zero");

            ApplyToEach(X, qs);
            assertOne([PauliX, PauliZ], "After X, PauliX-PauliZ joint measurement should be One");
            equalityOneFact(measOp([PauliX, PauliZ]), "After X, PauliX-PauliZ joint measurement should be One");
            
            ApplyToEach(H, qs);
            assertOne([PauliZ, PauliX], "After HX, PauliZ-PauliX joint measurement should be One");
            equalityOneFact(measOp([PauliZ, PauliX]), "After HX, PauliZ-PauliX joint measurement should be One");

            ApplyToEach(S, qs);
            assertOne([PauliZ, PauliY], "After SHX, PauliZ-PauliY joint measurement should be One");
            equalityOneFact(measOp([PauliZ, PauliY]), "After SHX, PauliZ-PauliY joint measurement should be One");

            within {
                X(qs[1]); // Change the parity.
            }
            apply {

                assertZero([PauliZ, PauliY], "After parity change and SHX, PauliZ-PauliY joint measurement should be Zero");
                equalityZeroFact(measOp([PauliZ, PauliY]), "After parity change and SHX, PauliZ-PauliY joint measurement should be Zero");
                ApplyToEach(Adjoint S, qs);

                assertZero([PauliZ, PauliX], "After parity change and HX, PauliZ-PauliX joint measurement should be Zero");
                equalityZeroFact(measOp([PauliZ, PauliX]), "After parity change and HX, PauliZ-PauliX joint measurement should be Zero");
                ApplyToEach(H, qs);

                assertZero([PauliX, PauliZ], "After parity change and X, PauliX-PauliZ joint measurement should be Zero");
                equalityZeroFact(measOp([PauliX, PauliZ]), "After parity change and X, PauliX-PauliZ joint measurement should be Zero");
                ApplyToEach(X, qs);

                assertOne([PauliX, PauliZ], "After parity change, PauliX-PauliZ joint measurement should be One");
                equalityOneFact(measOp([PauliX, PauliZ]), "After parity change, PauliX-PauliZ joint measurement should be One");
            }
        }

        AssertAllZero(qs);
    }
    
}


