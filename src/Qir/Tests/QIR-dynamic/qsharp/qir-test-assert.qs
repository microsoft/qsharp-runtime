// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// https://docs.microsoft.com/en-us/azure/quantum/concepts-the-qubit#single-qubit-operations    Qubit and Operations
// https://docs.microsoft.com/en-us/azure/quantum/user-guide/libraries/standard/prelude         Operation Details, Multi-Qubit Operations

namespace Microsoft.Quantum.Testing.QIR  {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    // |0> -> |1>
    @EntryPoint()
    operation AsrtMeasAlloc1OKTest() : Unit {
        use qubit = Qubit();    // |0>

        AssertMeasurement(           [PauliZ], [qubit], Zero,      "0: Newly allocated qubit must be in the |0> state.");
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 1.0, "1: Newly allocated qubit must be in the |0> state.", 1e-10);

        X(qubit);   // |0> -> |1>

        AssertMeasurement(           [PauliZ], [qubit], One,      "2: Newly allocated qubit after X() must be in the |1> state.");
        AssertMeasurementProbability([PauliZ], [qubit], One, 1.0, "3: Newly allocated qubit after X() must be in the |1> state.", 1e-10);
    }

    // Fail: Expecting |1>, should have expected |0>
    @EntryPoint()
    operation AsrtMeasAlloc1ExcTest() : Unit {
        use qubit = Qubit();    // |0>

        // Must fail:
        AssertMeasurement([PauliZ], [qubit], One, "Newly allocated qubit must be in the |0> state.");
    }

    // Fail: Expecting |1>, should have expected |0>
    @EntryPoint()
    operation AsrtMeasProbAlloc1ExcTest() : Unit {
        use qubit = Qubit();    // |0>

        // Must fail:
        AssertMeasurementProbability([PauliZ], [qubit], One, 1.0, "Newly allocated qubit must be in the |0> state.", 1e-10);
    }

    @EntryPoint()
    operation AsrtMeasProbAlloc1HalfProbTest() : Unit {     //!
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
    operation AsrtMeasProbAllocPlusMinusTest() : Unit {
        let str = "Newly allocated qubit after H() must be in the |+> state";

        use qubit = Qubit();    // |0>
        H(qubit);               // |+>
        AssertMeasurement(           [PauliX], [qubit], Zero, str);
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, str, 1e-10);
        AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, str, 1e-10);
        AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, str, 1e-10);
        AssertMeasurementProbability([PauliY], [qubit],  One, 0.5, str, 1e-10);

        let str2 = "Newly allocated qubit after x() followed by H() must be in the |-> state";
        H(qubit);   // Back to |0>
        X(qubit);   // |1>
        H(qubit);   // |->
        AssertMeasurement(           [PauliX], [qubit], One, str2);
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, str2, 1e-10);
        AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, str2, 1e-10);
        AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, str2, 1e-10);
        AssertMeasurementProbability([PauliY], [qubit],  One, 0.5, str2, 1e-10);
    }

    // (|0> + i|1>) / SQRT(2) = SH|0> = S|+> 
    // (|0> - i|1>) / SQRT(2) = SH|1> = S|->
    @EntryPoint()
    operation AsrtMeasSPlusMinusTest() : Unit {
        use qubit = Qubit();    // |0>
        H(qubit);               // |+>
        S(qubit);               // (|0> + i|1>) / SQRT(2)
        AssertMeasurement(           [PauliY], [qubit], Zero,      "0: Call failed");
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "1: Call failed", 1e-10);
        AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, "2: Call failed", 1e-10);
        AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "3: Call failed", 1e-10);
        AssertMeasurementProbability([PauliX], [qubit],  One, 0.5, "4: Call failed", 1e-10);

        Adjoint S(qubit);   // Back to |+>
        H(qubit);   // Back to |0>
        X(qubit);   // |1>
        H(qubit);   // |->
        S(qubit);   // (|0> - i|1>) / SQRT(2)
        AssertMeasurement(           [PauliY], [qubit], One,       "5: Call failed");
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "6: Call failed", 1e-10);
        AssertMeasurementProbability([PauliZ], [qubit],  One, 0.5, "7: Call failed", 1e-10);
        AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "8: Call failed", 1e-10);
        AssertMeasurementProbability([PauliX], [qubit],  One, 0.5, "9: Call failed", 1e-10);
    }


    // Multiple qubits:

    // Quantum Katas, Joint Measurement Workbook,
    //  https://hub.gke2.mybinder.org/user/microsoft-quantumkatas-jv0pu1ej/notebooks/JointMeasurements/Workbook_JointMeasurements.ipynb#Task-1.-Single-qubit-measurement

    //  Task 1. Single-qubit measurement
    //  Task 2. Parity measurement
    // |0>, |1>, |->
    @EntryPoint()
    operation AsrtMeas0011() : Unit {
        use left = Qubit();
        use right = Qubit();

        AssertMeasurement(           [PauliZ, PauliZ], [left, right], Zero,      "0: Call failed");
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 1.0, "1: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.0, "2: Call failed", 1E-05);

        H(left);        // |+>
        H(right);       // |+>
        AssertMeasurement(           [PauliX, PauliX], [left, right],  Zero,     "B: Call failed");
        // 50% probability in other Pauli bases:
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 0.5, "C: Call failed", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.5, "D: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right], Zero, 0.5, "E: Call failed", 1E-05);
        AssertMeasurementProbability([PauliY, PauliY], [left, right],  One, 0.5, "F: Call failed", 1E-05);
        
        H(left);        // Back to |0>
        H(right);       // Back to |0>
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
    }

    // Task 3.  |0000>+|1111>  or  |0011>+|1100> ?
    @EntryPoint()
    operation AsrtMeas4qubits() : Unit {
        use qubitIds = Qubit[4];        // |0000>

        H(qubitIds[0]);                 // |+>, equally probable |0> and |1> in PauliZ basis.

        if M(qubitIds[0]) == One {      // |+> collapses to |1> (-1 eigenvalue is observed)
            X(qubitIds[1]);             //      |1100>
        } else {
            X(qubitIds[2]);             //      |0010>
            X(qubitIds[3]);             //      |0011>
        }

        // Equally probable |1100> or |0011>.

        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[0], qubitIds[1]], Zero,      "0: Call failed");  // |00> or |11>
        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[1], qubitIds[2]],  One,      "1: Call failed");  // |01> or |10>
        AssertMeasurement(           [PauliZ, PauliZ], [qubitIds[2], qubitIds[3]], Zero,      "2: Call failed");  // |00> or |11>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[0], qubitIds[1]], Zero, 1.0, "3: Call failed", 1E-05);   // |00> or |11>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[1], qubitIds[2]],  One, 1.0, "4: Call failed", 1E-05);   // |01> or |10>
        AssertMeasurementProbability([PauliZ, PauliZ], [qubitIds[2], qubitIds[3]], Zero, 1.0, "5: Call failed", 1E-05);   // |00> or |11>
    }

    // Bell state:
    // https://github.com/microsoft/Quantum/blob/0ec53c6efe09c0f725aae01648cd92377e2fcc99/samples/getting-started/measurement/Measurement.qs#L89
    // "Quantum Computing : A Gentle Introduction", Example 3.2.1.  http://mmrc.amss.cas.cn/tlb/201702/W020170224608150244118.pdf
    @EntryPoint()
    operation AsrtMeasBellTest() : Unit {
        // The following using block allocates a pair of fresh qubits, which
        // start off in the |00> state by convention.
        use left = Qubit();
        use right = Qubit();
        // By applying the Hadamard and controlled-NOT (CNOT) operations,
        // we can prepare our qubits in an equal superposition of |00> and
        // |11>. This state is sometimes known as a Bell state.
        H(left);
        CNOT(left, right);

        // The following two assertions ascertain that the created state is indeed
        // invariant under both, the XX and the ZZ operations, i.e., it projects
        // into the +1 eigenstate of these two Pauli operators.
        AssertMeasurement(           [PauliZ, PauliZ], [left, right], Zero,      "Error: Bell state must be eigenstate of ZZ");
        AssertMeasurement(           [PauliX, PauliX], [left, right], Zero,      "Error: Bell state must be eigenstate of XX");
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right], Zero, 1.0, "Error: Bell state must be eigenstate of ZZ", 1E-05);
        AssertMeasurementProbability([PauliZ, PauliZ], [left, right],  One, 0.0, "Error: 01 or 10 should never occur as an outcome", 1E-05);
    }

    // TODO: mixed bases (e.g.: (|0+> + |1->) / SQRT(2) returns Zero when measuring in the [PauliZ, PauliX] basis)
    // TODO: https://teams.microsoft.com/l/message/19:a2559fdb51aa4b0c9904f06afd36a230@thread.skype/1620178597780?tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&groupId=e6e22ac8-e11f-44d0-b599-46e9bea42c53&parentMessageId=1620169396986&teamName=Quantum%20Systems&channelName=QDK%20Release&createdTime=1620178597780

} // namespace Microsoft.Quantum.Testing.QIR
