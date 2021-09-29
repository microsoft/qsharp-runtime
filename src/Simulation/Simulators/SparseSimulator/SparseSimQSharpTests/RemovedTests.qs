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

}
