// This file contains tests removed from the original test set.
// Tests were removed because they were using operations that are not possible in a quantum computer.
// such as measuring qubit states without projection.
// TODO: These test should be re-written using allowed operations.

namespace Microsoft.Quantum.SparseSimulatorTests {

//    @Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
//    operation ControlledHTest() : Unit {
//        use qubits = Qubit[4]{
//            H(qubits[0]);
//            H(qubits[1]);
//            CNOT(qubits[0], qubits[2]);
//            CNOT(qubits[1], qubits[3]);
//            (Controlled H)([qubits[2]], (qubits[3]));
//            let expected_vals = [
//                Complex(0.5, 0.0),
//                Complex(0.353553,0.0),
//                Complex(0.5,0.0),
//                Complex(0.353553,0.0),
//                Complex(0.353553,0.0),
//                Complex(-0.353553,0.0)];
//            let expected_labels = [
//                0L,
//                5L,
//                10L,
//                7L,
//                13L,
//                15L];
//            AssertAmplitudes(expected_labels, expected_vals, LittleEndian(qubits), 0.001);
//            ResetAll(qubits);
//        }
//    }

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

    // These two tests are from LargeStateTests.
    //@Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")
    //operation LargeStateTests() : Unit {
    //    let nqubits = 12;
    //    LargeStateTestWrapper(AndChainTest, nqubits);
    //    LargeStateTestWrapper(CZTest, nqubits);
    //}

}
