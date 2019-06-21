// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    
    
    operation Interface_Clifford (cliffordId : Int, pauli : Pauli, target : Qubit) : Unit {
        
        
        if (pauli == PauliI) {
        }
        elif (pauli == PauliZ) {
            Z(target);
        }
        elif (pauli == PauliX) {
            X(target);
        }
        elif (pauli == PauliY) {
            Y(target);
        }
        else {
            fail $"this line should never be reached";
        }
        
        if (cliffordId == 0) {
        }
        elif (cliffordId == 1) {
            H(target);
        }
        elif (cliffordId == 2) {
            S(target);
        }
        elif (cliffordId == 3) {
            H(target);
            S(target);
        }
        elif (cliffordId == 4) {
            S(target);
            H(target);
        }
        elif (cliffordId == 5) {
            H(target);
            S(target);
            H(target);
        }
        else {
            fail $"this line should never be reached";
        }
    }
    
}


