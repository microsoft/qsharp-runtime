// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    operation _Decomposer_X (qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }    
    
    operation _Decomposer_Y (qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }   
    
    operation _Decomposer_Z (qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }   
    
    operation _Decomposer_H (qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }   
    
    operation _Decomposer_S(qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    operation _Decomposer_T(qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    operation _Decomposer_R (pauli : Pauli, theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   

    operation _Decomposer_RFrac (pauli : Pauli, numerator : Int, power : Int, qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }
    
    operation _Decomposer_Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   
    
    operation _Decomposer_ExpFrac (paulis : Pauli[], numerator : Int, power : Int, qubits : Qubit[]) : Unit
    is Adj + Ctl {
        body intrinsic;
    }   

    operation _Decomposer_Measure (bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }
    
    operation _Decomposer_M (qubit : Qubit) : Result {
        body intrinsic;
    }

    operation _Decomposer_SWAP (qubit1 : Qubit, qubit2 : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    operation _Decomposer_R1 (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation _Decomposer_R1Frac (numerator : Int, power : Int, qubit : Qubit) : Unit
    is Adj + Ctl {
        body intrinsic;
    }

    operation _Decomposer_CNOT (control : Qubit, target : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            Controlled _Decomposer_X([control], target);
        }
        adjoint self;
    }

    operation _Decomposer_CCNOT (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            Controlled _Decomposer_X([control1, control2], target);
        }
        adjoint self;
    }

    operation _Decomposer_Rx (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            _Decomposer_R(PauliX, theta, qubit);
        }
        adjoint (...) {
            _Decomposer_R(PauliX, -theta, qubit);
        }
    }

    operation _Decomposer_Ry (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            _Decomposer_R(PauliY, theta, qubit);
        }
        adjoint (...) {
            _Decomposer_R(PauliY, -theta, qubit);
        }
    }

    operation _Decomposer_Rz (theta : Double, qubit : Qubit) : Unit
    is Adj + Ctl {
        body (...) {
            _Decomposer_R(PauliZ, theta, qubit);
        }
        adjoint (...) {
            _Decomposer_R(PauliZ, -theta, qubit);
        }
    }

    operation _Decomposer_Reset (target : Qubit) : Unit {
        if (_Decomposer_M(target) == One) {
            _Decomposer_X(target);
        }
    }

    operation _Decomposer_ResetAll (qubits : Qubit[]) : Unit {
        for (qubit in qubits) {
            _Decomposer_Reset(qubit);
        }
    }
}