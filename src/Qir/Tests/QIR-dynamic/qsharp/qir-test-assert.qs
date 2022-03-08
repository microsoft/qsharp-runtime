// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// https://docs.microsoft.com/azure/quantum/concepts-the-qubit#single-qubit-operations    Qubit and Operations
// https://docs.microsoft.com/azure/quantum/user-guide/libraries/standard/prelude         Operation Details, Multi-Qubit Operations

namespace Microsoft.Quantum.Testing.QIR  {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    // To avoid the potential circular dependency on QuantumLibraries repo we redefine the following {
    // Identifiers from Microsoft.Quantum.Arrays:
    // QuantumLibraries\Standard\src\Arrays\Arrays.qs:
    internal function Head<'A> (array : 'A[]) : 'A {
        //EqualityFactB(Length(array) > 0, true, $"Array must be of the length at least 1");
        if Length(array) == 0 {
            fail "Array must be of the length at least 1";
        }
        return array[0];
    }
    internal function Rest<'T> (array : 'T[]) : 'T[] {
        return array[1 .. Length(array) - 1];
    }
    internal function ConstantArray<'T> (length : Int, value : 'T) : 'T[] {
        mutable arr = new 'T[length];

        for i in 0 .. length - 1 {
            set arr w/= i <- value;
        }

        return arr;
    }
    internal function Most<'T> (array : 'T[]) : 'T[] {
        return array[0 .. Length(array) - 2];
    }

    // QuantumLibraries\Standard\src\Arrays\Zip.qs:
    internal function Zipped<'T, 'U>(left : 'T[], right : 'U[]) : ('T, 'U)[] {
        let nElements = Length(left) < Length(right)
                        ? Length(left)
                        | Length(right);
        mutable output = new ('T, 'U)[nElements];

        for idxElement in 0 .. nElements - 1 {
            set output w/= idxElement <- (left[idxElement], right[idxElement]);
        }

        return output;
    }

    // qsharp-runtime\src\Simulation\QSharpFoundation\Arrays\Enumeration.qs:
    internal function IndexRange<'TElement>(array : 'TElement[]) : Range {
       return 0..(Length(array) - 1);
    }

    // Identifiers from open Microsoft.Quantum.Canon:
    // QuantumLibraries\Standard\src\Canon\Combinators\ApplyToEach.qs:
    internal operation ApplyToEachCA<'T> (singleElementOperation : ('T => Unit is Adj + Ctl), register : 'T[])
    : Unit is Adj + Ctl {
        for idxQubit in IndexRange(register) {
            singleElementOperation(register[idxQubit]);
        }
    }
    // QuantumLibraries\Standard\src\Canon\DataStructures\Pairs.qs:
    internal function Fst<'T, 'U> (pair : ('T, 'U)) : 'T {
        let (fst, snd) = pair;
        return fst;
    }
    internal function Snd<'T, 'U> (pair : ('T, 'U)) : 'U {
        let (fst, snd) = pair;
        return snd;
    }
    // } To avoid the potential circular dependency...


    // |0> -> |1> 
    @EntryPoint()
    operation AssertMeasAlloc1OKTest() : Unit {
        use qubit = Qubit();    // |0>

        AssertMeasurement(           [PauliZ], [qubit], Zero,      "0: Newly allocated qubit must be in the |0> state.");
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 1.0, "1: Newly allocated qubit must be in the |0> state.", 1e-10);

        within {
            X(qubit);   // |0> -> |1>
        }
        apply {
            AssertMeasurement(           [PauliZ], [qubit], One,      "2: Newly allocated qubit after X() must be in the |1> state.");
            AssertMeasurementProbability([PauliZ], [qubit], One, 1.0, "3: Newly allocated qubit after X() must be in the |1> state.", 1e-10);
        }
    }

    @EntryPoint()
    operation AssertMeasProbAlloc1HalfProbTest() : Unit {
        use qubit = Qubit();    // |0>

        // Measuring in PauliX: 50% |0>, 50% |1>
        AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "0: Newly allocated qubit must be in the |0> state.", 1e-3);
        AssertMeasurementProbability([PauliX], [qubit],  One, 0.5, "1: Newly allocated qubit must be in the |0> state.", 1e-3);
        // Measuring in PauliY: 50% |0>, 50% |1>
        AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, "2: Newly allocated qubit must be in the |0> state.", 1e-3);
        AssertMeasurementProbability([PauliY], [qubit],  One, 0.5, "3: Newly allocated qubit must be in the |0> state.", 1e-3);
    }

    // |+>, |->
    @EntryPoint()
    operation AssertMeasProbAllocPlusMinusTest() : Unit {
        use qubit = Qubit();    // |0>

        within {
            H(qubit);               // |+>
        } apply {
            let str = "Newly allocated qubit after H() must be in the |+> state";

            AssertMeasurement(           [PauliX], [qubit], Zero, str);
            // 50% probability in other Pauli bases:
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, str, 1e-10);
            AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, str, 1e-10);
            AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, str, 1e-10);
            AssertMeasurementProbability([PauliY], [qubit],  One, 0.5, str, 1e-10);
        }  //H(qubit);   // Back to |0>

        let str2 = "Newly allocated qubit after x() followed by H() must be in the |-> state";
        within {
            X(qubit);   // |1>
            H(qubit);   // |->
        }
        apply {
            AssertMeasurement(           [PauliX], [qubit], One, str2);
            // 50% probability in other Pauli bases:
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, str2, 1e-10);
            AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, str2, 1e-10);
            AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, str2, 1e-10);
            AssertMeasurementProbability([PauliY], [qubit],  One, 0.5, str2, 1e-10);
        }
    }

    // (|0> + i|1>) / SQRT(2) = SH|0> = S|+> 
    // (|0> - i|1>) / SQRT(2) = SH|1> = S|->
    @EntryPoint()
    operation AssertMeasSPlusMinusTest() : Unit {
        use qubit = Qubit();    // |0>
        within {
            H(qubit);               // |+>
            S(qubit);               // (|0> + i|1>) / SQRT(2)
        } apply {
            AssertMeasurement(           [PauliY], [qubit], Zero,      "0: Call failed");
            // 50% probability in other Pauli bases:
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "1: Call failed", 1e-10);
            AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, "2: Call failed", 1e-10);
            AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "3: Call failed", 1e-10);
            AssertMeasurementProbability([PauliX], [qubit],  One, 0.5, "4: Call failed", 1e-10);
        } // Adjoint S(qubit);   // Back to |+>    // H(qubit);   // Back to |0>

        within {
            X(qubit);   // |1>
            H(qubit);   // |->
            S(qubit);   // (|0> - i|1>) / SQRT(2)
        }
        apply {
            AssertMeasurement(           [PauliY], [qubit], One,       "5: Call failed");
            // 50% probability in other Pauli bases:
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "6: Call failed", 1e-10);
            AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, "7: Call failed", 1e-10);
            AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "8: Call failed", 1e-10);
            AssertMeasurementProbability([PauliX], [qubit],  One, 0.5, "9: Call failed", 1e-10);
        }
    }


    // Multiple qubits:

    // Quantum Katas, Joint Measurement Workbook,
    //  https://mybinder.org/v2/gh/microsoft/QuantumKatas/main?urlpath=/notebooks/JointMeasurements%2FWorkbook_JointMeasurements.ipynb

    //  Task 1. Single-qubit measurement
    //  Task 2. Parity measurement
    // |0>, |1>, |->
    @EntryPoint()
    operation AssertMeas0011() : Unit {
        use left = Qubit();
        use right = Qubit();

        AssertMeasurement(           [PauliZ, PauliZ], [left, right], Zero,      "0: Call failed");
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 1.0, "1: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.0, "2: Call failed", 1E-05);

        within {
            H(left);        // |+>
            H(right);       // |+>
        } apply {
            AssertMeasurement(           [PauliX, PauliX], [left, right],  Zero,     "B: Call failed");
            // 50% probability in other Pauli bases:
            AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 0.5, "C: Call failed", 1E-05);
            AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.5, "D: Call failed", 1E-05);
            AssertMeasurementProbability([PauliY, PauliY], [left, right], Zero, 0.5, "E: Call failed", 1E-05);
            AssertMeasurementProbability([PauliY, PauliY], [left, right],  One, 0.5, "F: Call failed", 1E-05);
        } // H(right); // Back to |0>     // H(left); // Back to |0>   

        X(left);        // |1>
        X(right);       // |1>
        AssertMeasurement(           [PauliZ, PauliZ], [left, right], Zero,      "3: Call failed");    // |11>  (+1 eigenstate)
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 1.0, "4: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.0, "5: Call failed", 1E-05);

        H(left);        // |->
        H(right);       // |->
        AssertMeasurement(           [PauliX, PauliX], [left, right],  Zero,     "6: Call failed");
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 0.5, "7: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.5, "8: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right], Zero, 0.5, "9: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right],  One, 0.5, "A: Call failed", 1E-05);

        H(right);       // Back to |1>
        X(right);       // Back to |0>
        H(right);       // |+>
        // |left right> = |-+>
        AssertMeasurement(           [PauliX, PauliX], [left, right],  One,      "G: Call failed");
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 0.5, "H: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.5, "I: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right], Zero, 0.5, "J: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right],  One, 0.5, "K: Call failed", 1E-05);

        Reset(right);
        Reset(left);
    }

    // Task 3.  |0000>+|1111>  or  |0011>+|1100> ?
    @EntryPoint()
    operation AssertMeas4Qubits() : Unit {
        use qubitIds = Qubit[4];        // |0000>

        H(qubitIds[0]);                 // |+>, equally probable |0> and |1> in PauliZ basis.

        if M(qubitIds[0]) == One {      // |+> collapses to |1> (-1 eigenvalue is observed)
            X(qubitIds[1]);             //      |1100>
        } else {
            X(qubitIds[2]);             //      |0010>
            X(qubitIds[3]);             //      |0011>
        }

        // Equally probable |1100> or |0011> in PauliZ basis.

        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[0], qubitIds[1]], Zero,      "0: Call failed");  // |00> or |11>
        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[1], qubitIds[2]],  One,      "1: Call failed");  // |01> or |10>
        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[2], qubitIds[3]], Zero,      "2: Call failed");  // |00> or |11>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[0], qubitIds[1]], Zero, 1.0, "3: Call failed", 1E-05);   // |00> or |11>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[1], qubitIds[2]],  One, 1.0, "4: Call failed", 1E-05);   // |01> or |10>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[2], qubitIds[3]], Zero, 1.0, "5: Call failed", 1E-05);   // |00> or |11>

        ResetAll(qubitIds);
    }

    // Bell states (superposition of |00> and |11>, `(|10> + |01>) / SQRT(2)`):
    // https://github.com/microsoft/Quantum/blob/0ec53c6efe09c0f725aae01648cd92377e2fcc99/samples/getting-started/measurement/Measurement.qs#L89
    // "Quantum Computing : A Gentle Introduction", Example 3.2.1. https://mitpress.mit.edu/books/quantum-computing

    // States based on Bell state:
    internal operation PrepareBellPair((applyX : Bool, applyZ : Bool), (left : Qubit, right : Qubit))  : Unit is Adj + Ctl {
                            // Expects: |00>. Comments below are in Z-basis.
        H(left);            // Equally probable |0>  or |1>.  `(|0>  + |1> ) / SQRT(2)`
        CNOT(left, right);  // Equally probable |00> or |11>. `(|00> + |11>) / SQRT(2)`

        if applyX { 
            X(left);        // Equally probable |10> or |01>. `(|10> + |01>) / SQRT(2)`.
        }
        if applyZ {
            Z(left);        // Left qubit is `*` (0 or 1). Equally probable |*0> or -|*1>. `(|*0> - |*1>) / SQRT(2)`.
        }
    }

    @EntryPoint()
    operation AssertBellPairMeasurementsAreCorrectTest() : Unit {
        for applyX in [false, true] {
            for applyZ in [false, true] {
                use left  = Qubit();
                use right = Qubit();

                within {
                    PrepareBellPair((applyX, applyZ), (left, right));
                } apply {
                    AssertMeasurement(           [PauliZ, PauliZ], [left, right], applyX ?  One | Zero,      "0: 𝑍-basis parity was wrong");
                    AssertMeasurementProbability([PauliZ, PauliZ], [left, right], applyX ?  One | Zero, 1.0, "1: 𝑍-basis parity was wrong", 1E-05);
                    AssertMeasurementProbability([PauliZ, PauliZ], [left, right], applyX ? Zero |  One, 0.0, "2: 𝑍-basis parity was wrong", 1E-05);
                    AssertMeasurement(           [PauliX, PauliX], [left, right], applyZ ?  One | Zero,      "0: 𝑋-basis parity was wrong");
                    AssertMeasurementProbability([PauliX, PauliX], [left, right], applyZ ?  One | Zero, 1.0, "1: 𝑋-basis parity was wrong", 1E-05);
                    AssertMeasurementProbability([PauliX, PauliX], [left, right], applyZ ? Zero |  One, 0.0, "2: 𝑋-basis parity was wrong", 1E-05);

                    // Padding:
                    use aux = Qubit();
                    AssertMeasurement([PauliI, PauliZ, PauliZ], [aux, left, right], applyX ? One | Zero, "3: 𝑍-basis parity was wrong.");
                    AssertMeasurement([PauliZ, PauliZ, PauliI], [left, right, aux], applyX ? One | Zero, "4: 𝑍-basis parity was wrong.");
                    AssertMeasurement([PauliI, PauliX, PauliX], [aux, left, right], applyZ ? One | Zero, "3: 𝑋-basis parity was wrong.");
                    AssertMeasurement([PauliX, PauliX, PauliI], [left, right, aux], applyZ ? One | Zero, "4: 𝑋-basis parity was wrong.");                    
                }
            }
        }
    }

    // Chris: mixed bases (e.g.: (|0+> + |1->) / SQRT(2) returns Zero when measuring in the [PauliZ, PauliX] basis)
    @EntryPoint()
    operation AssertMeasMixedBasesTest() : Unit {
        use left = Qubit();
        use right = Qubit();

        H(left);                // Op Result: (|0>  + |1> )/SQRT(2). Total: (|00> + |10>) / SQRT(2).
        CNOT(left, right);      // (|00> + |11>)/SQRT(2)    Bell pair.
        H(right);               // (|0+> + |1->)/SQRT(2)
        // Chris: The trick there is to keep in mind that |+⟩ = 𝐻|0⟩ and |−⟩ = 𝐻|1⟩ (that's actually sufficient to define 𝐻). 
        // From there, everything proceeds by linearity. 
        // In particular, (|0+⟩ + |1−⟩) / √2 = ([𝟙 ⊗ 𝐻] |00⟩ + [𝟙 ⊗ 𝐻] |11⟩) / √2, 
        // so that we can factor out [𝟙 ⊗ 𝐻] to get that you need to apply H(right) to a register in a Bell pair.

        AssertMeasurement(           [PauliZ, PauliX], [left, right], Zero,      "Error: Measuring (|0+> + |1->)/SQRT(2) must return Zero in 𝑍𝑋-basis"              );
        AssertMeasurementProbability([PauliZ, PauliX], [left, right], Zero, 1.0, "Error: Measuring (|0+> + |1->)/SQRT(2) must return Zero always in 𝑍𝑋-basis", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliX], [left, right],  One, 0.0, "Error: Measuring (|0+> + |1->)/SQRT(2) must not return One in 𝑍𝑋-basis"    , 1E-05);

        AssertMeasurement(           [PauliX, PauliZ], [left, right], Zero,      "Error: Measuring (|0+> + |1->)/SQRT(2) must return Zero in 𝑋𝑍-basis"              );
        AssertMeasurementProbability([PauliX, PauliZ], [left, right], Zero, 1.0, "Error: Measuring (|0+> + |1->)/SQRT(2) must return Zero always in 𝑋𝑍-basis", 1E-05);
        AssertMeasurementProbability([PauliX, PauliZ], [left, right],  One, 0.0, "Error: Measuring (|0+> + |1->)/SQRT(2) must not return One in 𝑋𝑍-basis"    , 1E-05);

        Reset(right);
        Reset(left);
    }


    // Multi-qubit entangled states, e.g.: (|000> + |111>) / SQRT(2) - GHZ States:
    internal operation PrepareGHZState(qs : Qubit[]) : Unit is Adj + Ctl {
        H(Head(qs));
        ApplyToEachCA(CNOT(Head(qs), _), Rest(qs));
    }

    internal operation AssertGHZMeasurementsAreCorrect(n : Int) : Unit {
        use qs = Qubit[n];
        within {
            PrepareGHZState(qs);
        } apply {
            if (n &&& 1) == 0 {   // Even number of qubits.
                AssertMeasurement(           ConstantArray(n, PauliZ), qs, Zero,      "0: Z-basis parity was wrong. n: {n}");
                AssertMeasurementProbability(ConstantArray(n, PauliZ), qs, Zero, 1.0, "1: Z-basis parity was wrong. n: {n}", 1E-05);
                AssertMeasurementProbability(ConstantArray(n, PauliZ), qs,  One, 0.0, "2: Z-basis parity was wrong. n: {n}", 1E-05);
            }
            AssertMeasurement(           ConstantArray(n, PauliX), qs, Zero,      "0: X-basis parity was wrong. n: {n}");
            AssertMeasurementProbability(ConstantArray(n, PauliX), qs, Zero, 1.0, "1: X-basis parity was wrong. n: {n}", 1E-05);
            AssertMeasurementProbability(ConstantArray(n, PauliX), qs,  One, 0.0, "2: X-basis parity was wrong. n: {n}", 1E-05);
            for pair in Zipped(Most(qs), Rest(qs)) {
                AssertMeasurement(           [PauliZ, PauliZ], [Fst(pair), Snd(pair)], Zero,      "3: Z-basis parity was wrong");
                AssertMeasurementProbability([PauliZ, PauliZ], [Fst(pair), Snd(pair)], Zero, 1.0, "4: Z-basis parity was wrong", 1E-05);
                AssertMeasurementProbability([PauliZ, PauliZ], [Fst(pair), Snd(pair)],  One, 0.0, "5: Z-basis parity was wrong", 1E-05);
            }
        }
    }

    @EntryPoint()
    operation AssertGHZMeasurementsTest() : Unit {
        for nQubits in 3 .. 6 {
            AssertGHZMeasurementsAreCorrect(nQubits);
        }
    }

    @EntryPoint()
    operation AssertMeasMessageTest(msg : String) : Unit {
        use qubit = Qubit();    // |0>

        // Must fail:
        AssertMeasurement([PauliZ], [qubit], One, msg);
    }

    @EntryPoint()
    operation AssertMeasProbMessageTest(msg : String) : Unit {
        use qubit = Qubit();    // |0>

        // Must fail:
        AssertMeasurementProbability([PauliZ], [qubit], One, 1.0, msg, 1e-10);
    }

} // namespace Microsoft.Quantum.Testing.QIR

