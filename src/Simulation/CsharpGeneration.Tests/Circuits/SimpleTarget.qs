// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Target definition file for testing target generation.
// 4 operations:
// - I should be ignored, it's not intrinsic.
// - X should generate 2 methods and have the adjoints just point to the normal specializations.
// - S should generate 4 methods.
// - Measure should generate just a body. It also tests intrinsics that take arrays.
namespace Microsoft.Quantum.Simple {
    operation I (target : Qubit) : Unit
    is Adj + Ctl {
        body (...) { }        
        adjoint self;
    }
    
    operation X (q1 : Qubit) : Unit 
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }

    
    operation S (q1 : Qubit) : Unit 
    is Adj + Ctl {
        body intrinsic;
        adjoint intrinsic;
    }

    operation Measure (bases : Pauli[], qubits : Qubit[]) : Result {
        body intrinsic;
    }

}


