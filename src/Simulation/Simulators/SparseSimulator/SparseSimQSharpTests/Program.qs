// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.SparseSimulatorTests {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;

    internal operation ApplyToEachCA<'T> (singleElementOperation : ('T => Unit is Adj + Ctl), register : 'T[])
    : Unit is Adj + Ctl {
        for idxQubit in IndexRange(register) {
            singleElementOperation(register[idxQubit]);
        }
    }

    internal operation ApplyToFirstTwoQubitsCA (op : ((Qubit, Qubit) => Unit is Adj + Ctl), register : Qubit[]) 
    : Unit is Adj + Ctl {
        if (Length(register) < 2)
        {
            fail $"Must have at least two qubits to act on.";
        }
        
        op(register[0], register[1]);
    }    

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

    operation _R(pauli : Pauli, theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        R(pauli, theta, qubits[0]);
    }
    operation _MCR(pauli : Pauli, theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        (Controlled R)(qubits[1..Length(qubits)-1], (pauli, theta, qubits[0]));
    }
    operation _MCExp(pauli : Pauli, theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl {
        (Controlled Exp)(qubits[1..Length(qubits)-1], ([pauli], theta, [qubits[0]]));
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation ExpRCompare() : Unit {
        for angle in 0..2*314 {
           AssertOperationsEqualReferenced(1, _R(PauliX, -IntAsDouble(angle)/100.0, _), Exp([PauliX], IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _R(PauliZ, -IntAsDouble(angle)/100.0, _), Exp([PauliZ], IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _R(PauliY, -IntAsDouble(angle)/100.0, _), Exp([PauliY], IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _R(PauliI, -IntAsDouble(angle)/100.0, _), Exp([PauliI], IntAsDouble(angle)/200.0, _));
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation MCExpMCRCompare() : Unit {
        for angle in 0..2*314 {
           AssertOperationsEqualReferenced(1, _MCR(PauliX, -IntAsDouble(angle)/100.0, _), _MCExp(PauliX, IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _MCR(PauliZ, -IntAsDouble(angle)/100.0, _),  _MCExp(PauliZ, IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _MCR(PauliY, -IntAsDouble(angle)/100.0, _),  _MCExp(PauliY, IntAsDouble(angle)/200.0, _));
           AssertOperationsEqualReferenced(1, _MCR(PauliI, -IntAsDouble(angle)/100.0, _),  _MCExp(PauliI, IntAsDouble(angle)/200.0, _));
        }
    }

    internal operation ControlledRz(angle : Double, (control : Qubit, target : Qubit)) : Unit is Adj + Ctl {
        Controlled Rz([control], (angle, target));
        DumpMachine();
    }

    internal operation ControlledRzAsR1(angle : Double, (control : Qubit, target : Qubit)) : Unit is Adj + Ctl {
        Controlled R1([control], (angle, target));
        R1(-angle / 2.0, control);
        DumpMachine();
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation TestEqualityOfControlledRz() : Unit {
        for _ in 1..10 {
            let angle = Microsoft.Quantum.Random.DrawRandomDouble(0.0, 2.0 * PI());
            AssertOperationsEqualReferenced(2, ApplyToFirstTwoQubitsCA(ControlledRzAsR1(angle, _), _), ApplyToFirstTwoQubitsCA(ControlledRz(angle, _), _));
        }
    }

    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation LargeStateTests() : Unit {
        let nqubits = 12;
        LargeStateTestWrapper(Rotation1CompareTest, nqubits);
        LargeStateTestWrapper(RotationCompareTest, nqubits);
        LargeStateTestWrapper(SWAPTest, nqubits);
        LargeStateTestWrapper(CSWAPTest, nqubits);
        LargeStateTestWrapper(CNOTTest, nqubits);
        LargeStateTestWrapper(ResetTest, nqubits);
        LargeStateTestWrapper(AssertTest, nqubits);
        //LargeStateTestWrapper(AndChainTest, nqubits);
        //LargeStateTestWrapper(CZTest, nqubits);
        LargeStateTestWrapper(AllocationTest, nqubits);
        LargeStateTestWrapper(Rotation1CompareTest, nqubits);
        LargeStateTestWrapper(RotationFracCompareTest, nqubits);

    }

    operation _ToffoliCSwap(targets : Qubit[]) : Unit is Ctl + Adj {
        CCNOT(targets[0], targets[1], targets[2]);
        CCNOT(targets[0], targets[2], targets[1]);
        CCNOT(targets[0], targets[1], targets[2]);
    }
    operation _ArrayCSwap(targets : Qubit[]) : Unit is Ctl + Adj {
        (Controlled SWAP)([targets[0]], (targets[1], targets[2]));
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation CCNOTvToffoliTest() : Unit {
        AssertOperationsEqualReferenced(3, _ArrayCSwap, _ToffoliCSwap);
    }

    // Creates a big state so an existing test forces parallel execution
    operation LargeStateTestWrapper(test : (Unit => Unit), nqubits : Int) : Unit {
        let prob = PowD(0.5, IntAsDouble(nqubits));
         use qubits = Qubit[nqubits];
        for idx in 0..nqubits - 1 {
            H(qubits[idx]);
        }
        for idy in 1..128 {
            CCNOT(qubits[idy % nqubits], qubits[(idy+1) % nqubits], qubits[(idy+2) % nqubits]);
        }
        test();
        ResetAll(qubits);
    }

    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
	operation PartialDumpTest() : Unit  {
        use qubits = Qubit[4] {
            ApplyToEachCA(H, qubits);
            CNOT(qubits[2], qubits[3]);
            DumpRegister("Test_file_1", qubits[0..1]);
            DumpRegister("Test_file_2", qubits[2..3]);
            CNOT(qubits[2], qubits[3]);
            H(qubits[2]);
            CNOT(qubits[0], qubits[2]);
            DumpRegister("Test_file_3", qubits[0..1]);
            DumpRegister("Test_file_4", qubits);
            ResetAll(qubits);
        }
    }

    
    internal operation FakeR1Frac(numerator : Int, denominator : Int, qubit : Qubit[]) : Unit is Adj + Ctl {
        RFrac(PauliZ, -numerator, denominator + 1, qubit[0]);
        RFrac(PauliI, numerator, denominator + 1, qubit[0]);
    }
    
    internal operation R1FracWithArray(numerator : Int, denominator : Int, qubit : Qubit[]) : Unit is Adj + Ctl {
        R1Frac(numerator, denominator, qubit[0]);
    }

    internal operation FakeR1(angle : Double, qubit : Qubit[]) : Unit is Adj + Ctl {
        R(PauliZ, angle, qubit[0]);
        R(PauliI, -angle, qubit[0]);
    }
    internal operation R1WithArray(angle : Double, qubit : Qubit[]) : Unit is Adj + Ctl {
        R1(angle, qubit[0]);
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation Rotation1CompareTest() : Unit {
        for denom in 0..5{
            for num in 1..2..(2^denom - 1){
                AssertOperationsEqualReferenced(1, R1FracWithArray(num, denom, _), FakeR1Frac(num, denom, _));
                AssertOperationsEqualReferenced(1, FakeR1Frac(num, denom, _), R1FracWithArray(num, denom, _));
		    }
        }
        for angle in 0..314 {
            AssertOperationsEqualReferenced(1, R1WithArray(IntAsDouble(angle)/100.0, _), FakeR1(IntAsDouble(angle)/100.0, _));
            AssertOperationsEqualReferenced(1, FakeR1(IntAsDouble(angle)/100.0, _), R1WithArray(IntAsDouble(angle)/100.0, _));
        }
    }

    internal operation RFracWithArray(axis : Pauli, num : Int, denom : Int, qubit : Qubit[]) : Unit is Adj + Ctl {
        RFrac(axis, num, denom, qubit[0]);
    }
    internal operation RWithArray(axis : Pauli, angle : Double, qubit : Qubit[]) : Unit is Adj + Ctl {
        R(axis, angle, qubit[0]);
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation RotationFracCompareTest() : Unit {
        for denom in 0..5{
            for num in 1..2..(2^denom - 1){
                let angle = -3.14159265*IntAsDouble(num)/(2.0 ^IntAsDouble(denom-1));
                AssertOperationsEqualReferenced(1, RFracWithArray(PauliX, num, denom, _), RWithArray(PauliX, angle, _));
                AssertOperationsEqualReferenced(1, RWithArray(PauliX, angle, _), RFracWithArray(PauliX, num, denom, _));
                AssertOperationsEqualReferenced(1, RFracWithArray(PauliY, num, denom, _), RWithArray(PauliY, angle, _));
                AssertOperationsEqualReferenced(1, RWithArray(PauliY, angle, _), RFracWithArray(PauliY, num, denom, _));
                AssertOperationsEqualReferenced(1, RFracWithArray(PauliZ, num, denom, _), RWithArray(PauliZ, angle, _));
                AssertOperationsEqualReferenced(1, RWithArray(PauliZ, angle, _), RFracWithArray(PauliZ, num, denom, _));
		    }
        }
    }

    operation _HadamardByRotations(qubit : Qubit[]) : Unit is Adj + Ctl {
        RFrac(PauliY, -1, 2, qubit[0]);
        RFrac(PauliX, -1, 1, qubit[0]);
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation RotationCompareTest() : Unit {
        AssertOperationsEqualReferenced(1, _HadamardByRotations(_), ApplyToEachCA(H, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(R1Frac(1,0,_), _), ApplyToEachCA(Z, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(R1Frac(1,1,_), _), ApplyToEachCA(S, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(R1Frac(1,2,_), _), ApplyToEachCA(T, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(RFrac(PauliX, 1, 1, _), _), ApplyToEachCA(X, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(RFrac(PauliY, 1, 1, _), _), ApplyToEachCA(Y, _));
        AssertOperationsEqualReferenced(1, ApplyToEachCA(RFrac(PauliZ, 1, 1, _), _), ApplyToEachCA(Z, _));
    }

    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation AllocationTest() : Unit {
        use qubits = Qubit[512]{
            for idx in 0..511 {
                X(qubits[idx]);
            }
            ResetAll(qubits);
        }
    }

    // Taken from the PurifiedMixedState documentation
    //@Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    //operation QROMPrepareTest() : Unit {
    //    let coefficients = [1.0, 2.0, 3.0, 4.0, 5.0];
    //    let targetError = 1e-3;
    //    let purifiedState = PurifiedMixedState(targetError, coefficients);
    //    use indexRegister = Qubit[purifiedState::Requirements::NIndexQubits] {
    //         use garbageRegister = Qubit[purifiedState::Requirements::NGarbageQubits] {
    //             purifiedState::Prepare(LittleEndian(indexRegister), new Qubit[0], garbageRegister);
    //             ResetAll(garbageRegister);
    //         }
    //         ResetAll(indexRegister);
    //     }
    //}
    

    //@Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    //operation CZTest() : Unit {
    //    let num_qubits = 5;
    //    use qubits = Qubit[num_qubits]{
    //        H(qubits[0]);
    //        for idx in 0..(2^(num_qubits-1) - 1) {
    //            let result = (idx == 2^(num_qubits - 1) - 1);
    //            within {
    //                ApplyXorInPlace(idx, LittleEndian(qubits[1..num_qubits - 1]));
    //                (Controlled Z)(qubits[1..num_qubits -1], (qubits[0]));
	//		    } apply {
    //                if (result){
    //                    AssertMeasurement([PauliX], qubits[0..0], One, "CZ failed to add phase");
    //                } else {
    //                    AssertMeasurement([PauliX], qubits[0..0], Zero, "CZ added unexpected phase");
    //                }
	//		    }
	//		}
    //       H(qubits[0]);
    //    }
    //}

    //operation ApplyAndChain(andOp : ((Qubit, Qubit, Qubit)=>Unit is Adj + Ctl), auxRegister : Qubit[], ctrlRegister : /Qubit/[], target : Qubit)
    //: Unit is Adj {
    //    if (Length(ctrlRegister) == 0) {
    //        X(target);
    //    } elif (Length(ctrlRegister) == 1) {
    //        CNOT(ctrlRegister[0], target);
    //    } else {
    //        EqualityFactI(Length(auxRegister), Length(ctrlRegister) - 2, "Unexpected number of auxiliary qubits");
    //        let controls1 = ctrlRegister[0..0] + auxRegister;
    //        let controls2 = ctrlRegister[1...];
    //        let targets = auxRegister + [target];
    //        ApplyToEachCA(andOp, Zipped3(controls1, controls2, targets));
    //    }
    //}

    //@Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    //operation AndChainTest() : Unit {
    //    let num_qubits = 5;
    //    use qubits = Qubit[num_qubits]{
    //        use aux = Qubit[num_qubits - 3]{
    //            for idx in 0..(2^(num_qubits-1) - 1) {
    //                let result = (idx == 2^(num_qubits - 1) - 1);
    //                within {
    //                    ApplyXorInPlace(idx, LittleEndian(qubits[1..num_qubits - 1]));
    //                    ApplyAndChain(ApplyAnd, aux, qubits[1..num_qubits -1], qubits[0]);
	//		        } apply {
    //                    let after = M(qubits[0]);
    //                    if (result){
    //                        Fact(after == One, "Did not apply AND");
    //                    } else {
    //                        Fact(after == Zero, "Applied AND unexpectedly");
    //                    }
	//		        }
	//		    }
	//		}
    //    }
    //}


    operation DumpMCXFrac() : Unit {
        use qubits = Qubit[2] {
            H(qubits[0]);
            H(qubits[1]);
            (Controlled RFrac)([qubits[0]], (PauliX, -1, 3, qubits[1]));
            DumpMachine();
            (Adjoint Controlled RFrac)([qubits[0]], (PauliX, -1, 3, qubits[1]));
            H(qubits[0]);
            H(qubits[1]);
            H(qubits[0]);
            H(qubits[1]);
            (Controlled R)([qubits[0]], (PauliX, 0.25*Microsoft.Quantum.Math.PI(), qubits[1]));
            DumpMachine();
            (Adjoint Controlled R)([qubits[0]], (PauliX, 0.25*Microsoft.Quantum.Math.PI(), qubits[1]));
            H(qubits[0]);
            H(qubits[1]);
        }
    }

    operation DumpMCZFrac() : Unit {
        use qubits = Qubit[2] {
            H(qubits[0]);
            H(qubits[1]);
            (Controlled RFrac)([qubits[0]], (PauliZ, -1, 3, qubits[1]));
            DumpMachine();
            (Adjoint Controlled RFrac)([qubits[0]], (PauliZ, -1, 3, qubits[1]));
            H(qubits[0]);
            H(qubits[1]);
            H(qubits[0]);
            H(qubits[1]);
            (Controlled R)([qubits[0]], (PauliZ, 0.25*Microsoft.Quantum.Math.PI(), qubits[1]));
            DumpMachine();
            (Adjoint Controlled R)([qubits[0]], (PauliZ, 0.25*Microsoft.Quantum.Math.PI(), qubits[1]));
            H(qubits[0]);
            H(qubits[1]);
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation AssertProbTest() : Unit {
        let tolerance = 0.000001;
        use qubit = Qubit() {
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 1.0, "Failed assert Z on |0>", tolerance);
            AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "Failed assert X on |0>", tolerance);
            AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, "Failed assert Y on |0>", tolerance);
            H(qubit);
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "Failed assert Z on |+>", tolerance);
            AssertMeasurementProbability([PauliX], [qubit], Zero, 1.0, "Failed assert X on |+>", tolerance);
            AssertMeasurementProbability([PauliY], [qubit], Zero, 0.5, "Failed assert X on |+>", tolerance);
            S(qubit);
            AssertMeasurementProbability([PauliZ], [qubit], Zero, 0.5, "Failed assert Z on |+>", tolerance);
            AssertMeasurementProbability([PauliX], [qubit], Zero, 0.5, "Failed assert X on |+>", tolerance);
            AssertMeasurementProbability([PauliY], [qubit], Zero, 1.0, "Failed assert Y on |i>", tolerance);
            S(qubit);
            use buddy = Qubit() {
                CNOT(qubit, buddy);
                AssertMeasurementProbability([PauliZ, PauliZ], [qubit, buddy], Zero, 1.0, "Failed assert ZZ on |++>", tolerance);
                AssertMeasurementProbability([PauliZ, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert ZI on |++>", tolerance);
                AssertMeasurementProbability([PauliX, PauliX], [qubit, buddy], Zero, 0.0, "Failed assert XX on |++>", tolerance);
                AssertMeasurementProbability([PauliX, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert XI on |++>", tolerance);
                AssertMeasurementProbability([PauliY, PauliY], [qubit, buddy], Zero, 1.0, "Failed assert YY on |++>", tolerance);
                AssertMeasurementProbability([PauliY, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert YI on |++>", tolerance);
                AssertMeasurementProbability([PauliX, PauliZ], [qubit, buddy], Zero, 0.5, "Failed assert XZ on |++>", tolerance);
                AssertMeasurementProbability([PauliX, PauliY], [qubit, buddy], Zero, 0.5, "Failed assert XY on |++>", tolerance);
                AssertMeasurementProbability([PauliY, PauliZ], [qubit, buddy], Zero, 0.5, "Failed assert YZ on |++>", tolerance);
                Z(qubit);
                AssertMeasurementProbability([PauliZ, PauliZ], [qubit, buddy], Zero, 1.0, "Failed assert ZZ on |-->", tolerance);
                AssertMeasurementProbability([PauliZ, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert ZI on |-->", tolerance);
                AssertMeasurementProbability([PauliX, PauliX], [qubit, buddy], Zero, 1.0, "Failed assert XX on |-->", tolerance);
                AssertMeasurementProbability([PauliX, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert XI on |-->", tolerance);
                AssertMeasurementProbability([PauliY, PauliY], [qubit, buddy], Zero, 0.0, "Failed assert YY on |-->", tolerance);
                AssertMeasurementProbability([PauliY, PauliI], [qubit, buddy], Zero, 0.5, "Failed assert YI on |-->", tolerance);
                AssertMeasurementProbability([PauliX, PauliZ], [qubit, buddy], Zero, 0.5, "Failed assert XZ on |-->", tolerance);
                AssertMeasurementProbability([PauliX, PauliY], [qubit, buddy], Zero, 0.5, "Failed assert XY on |-->", tolerance);
                AssertMeasurementProbability([PauliY, PauliZ], [qubit, buddy], Zero, 0.5, "Failed assert YZ on |-->", tolerance);
                Reset(buddy);
            }
            Reset(qubit);
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation AssertTest() : Unit {
        use qubits = Qubit[3] {
            AssertMeasurement([PauliZ, PauliZ, PauliZ], qubits, Zero, "Assert fails Pauli Z");
            X(qubits[0]);
            X(qubits[1]);
            X(qubits[2]);
            AssertMeasurement([PauliZ, PauliZ, PauliZ], qubits, One, "Assert fails Pauli Z");
            AssertMeasurement([PauliZ, PauliZ, PauliI], qubits, Zero, "Assert fails Pauli Z");
            X(qubits[2]);
            X(qubits[1]);
            X(qubits[0]);
            H(qubits[0]);
            CNOT(qubits[0], qubits[1]);
            CNOT(qubits[0], qubits[2]);
            AssertMeasurement([PauliX, PauliX, PauliX], qubits, Zero, "Assert fails Pauli X");
            Z(qubits[0]);
            AssertMeasurement([PauliX, PauliX, PauliX], qubits, One, "Assert fails Pauli X");
            S(qubits[0]);
            AssertMeasurement([PauliY, PauliY, PauliY], qubits, Zero, "Assert fails Pauli Y");
            Z(qubits[0]);
            AssertMeasurement([PauliY, PauliY, PauliY], qubits, One, "Assert fails Pauli Y");
            ResetAll(qubits);
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation MTest() : Unit {
        use qubit = Qubit() {
            X(qubit);
            let test = M(qubit);
            Fact(M(qubit) == test, "M does not preserves state");
            X(qubit);
            let test2 = M(qubit);
            Fact(M(qubit) == test2, "M does not preserve state");
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation ResetTest() : Unit {
        use qubit = Qubit() {
            Reset(qubit);
            Fact(M(qubit) == Zero, "Failed reset");
            X(qubit);
            Reset(qubit);
            Fact(M(qubit) == Zero, "Failed reset");
            use buddy = Qubit() {
                X(qubit);
                CNOT(qubit, buddy);
                Reset(qubit);
                Fact(M(qubit) == Zero, "Failed entangled reset");
                Fact(M(buddy) == One,  "Failed entangled reset");
                Reset(buddy);
                Fact(M(buddy) == Zero, "Failed entangled reset");
            }
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation SWAPTest () : Unit {
        use qubits = Qubit[2] {
            SWAP(qubits[0], qubits[1]);
            Fact(M(qubits[0]) == Zero, "Bad swap on 00");
            Fact(M(qubits[1]) == Zero, "Bad swap on 00");
            X(qubits[0]);
            SWAP(qubits[0], qubits[1]);
            Fact(M(qubits[0]) == Zero, "Bad swap on 01");
            Fact(M(qubits[1]) == One, "Bad swap on 01");
            X(qubits[0]);
            SWAP(qubits[0], qubits[1]);
            Fact(M(qubits[0]) == One, "Bad swap on 11");
            Fact(M(qubits[1]) == One, "Bad swap on 11");
            X(qubits[0]);
            SWAP(qubits[0], qubits[1]);
            Fact(M(qubits[0]) == One, "Bad swap on 10");
            Fact(M(qubits[1]) == Zero, "Bad swap on 10");
            X(qubits[0]);
        }
    }

    operation AreAllQubitsOne(qubits : Qubit[]) : Bool {
        mutable qubits_all_true = true;
        for idx in 0..Length(qubits) - 1 {
            if (M(qubits[idx]) == Zero){ 
                set qubits_all_true = false;
            }
        }
        return qubits_all_true;
    }

    operation CNOTTestInternal(target : Qubit) : Unit {
        body (...){ 

        }
        controlled (controls, ...){
            if (AreAllQubitsOne(controls)){
                (Controlled X)(controls, target);
                Fact(M(target) == One, "Bad CNOT");
                (Controlled X)(controls, target);
                Fact(M(target) == Zero, "Bad CNOT");
            } else {
                (Controlled X)(controls, target);
                Fact(M(target) == Zero, "Bad CNOT");
                X(target);
                (Controlled X)(controls, target);
                Fact(M(target) == One, "Bad CNOT");
                X(target);
            }
        }
    }
    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation CNOTTest() : Unit {
        use qubits = Qubit[3] {
            (Controlled CNOTTestInternal)(qubits[0..1], qubits[2]);
            X(qubits[0]);
            (Controlled CNOTTestInternal)(qubits[0..1], qubits[2]);
            X(qubits[1]);
            (Controlled CNOTTestInternal)(qubits[0..1], qubits[2]);
            X(qubits[0]);
            (Controlled CNOTTestInternal)(qubits[0..1], qubits[2]);
            X(qubits[1]);
        }
    }

    operation CSwapTestInternal (qubits : Qubit[]) : Unit {
        body (...){
            // nothing
        }
        controlled (controls, ...) {
			if (not AreAllQubitsOne(controls)) {
				(Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == Zero, "Bad swap on 00");
                Fact(M(qubits[1]) == Zero, "Bad swap on 00");
                X(qubits[0]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == One, "Bad swap on 01");
                Fact(M(qubits[1]) == Zero, "Bad swap on 01");
                X(qubits[1]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == One, "Bad swap on 11");
                Fact(M(qubits[1]) == One, "Bad swap on 11");
                X(qubits[0]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == Zero, "Bad swap on 10");
                Fact(M(qubits[1]) == One, "Bad swap on 10");
                X(qubits[1]);
			} else {
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == Zero, "Bad swap on 00");
                Fact(M(qubits[1]) == Zero, "Bad swap on 00");
                X(qubits[0]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == Zero, "Bad swap on 01");
                Fact(M(qubits[1]) == One, "Bad swap on 01");
                X(qubits[0]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == One, "Bad swap on 11");
                Fact(M(qubits[1]) == One, "Bad swap on 11");
                X(qubits[0]);
                (Controlled SWAP)(controls, (qubits[0], qubits[1]));
                Fact(M(qubits[0]) == One, "Bad swap on 10");
                Fact(M(qubits[1]) == Zero, "Bad swap on 10");
                X(qubits[0]);
            }
        }
    }

    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation CSWAPTest () : Unit {
        use qubits = Qubit[4] {
            (Controlled CSwapTestInternal)(qubits[0..1], qubits[2..3]);
            X(qubits[0]);
            (Controlled CSwapTestInternal)(qubits[0..1], qubits[2..3]);
            X(qubits[1]);
            (Controlled CSwapTestInternal)(qubits[0..1], qubits[2..3]);
            X(qubits[0]);
            (Controlled CSwapTestInternal)(qubits[0..1], qubits[2..3]);
            X(qubits[1]);
        }
        use qubits = Qubit[7] {
            (Controlled CSwapTestInternal)([qubits[0]], [qubits[6], qubits[3]]);
            X(qubits[0]);
            (Controlled CSwapTestInternal)([qubits[0]], [qubits[6], qubits[3]]);
            X(qubits[0]);
        }
    }

    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    operation BasicTest () : Unit {
        use new_qubit = Qubit() {
            H(new_qubit);
            X(new_qubit);
            Z(new_qubit);
            Y(new_qubit);
            T(new_qubit);
            (Adjoint T)(new_qubit);
            S(new_qubit);
            (Adjoint S)(new_qubit);
            Y(new_qubit);
            Z(new_qubit);
            X(new_qubit);
            H(new_qubit); 
        }
        use new_qubits = Qubit[4] {
            for idx in 0..3 {
                H(new_qubits[idx]);
            }
            for idx in 0..3 {
                H(new_qubits[idx]);
            }
        }
    }
}
