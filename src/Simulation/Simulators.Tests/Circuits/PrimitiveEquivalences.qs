// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    
    
    //------------------------------------------------------------------------
    
    operation CNOTPrimitive (register : Qubit[]) : Unit {
        
        body (...) {
            CNOT(register[0], register[1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation CNOTEquivalent (register : Qubit[]) : Unit {
        
        body (...) {
            Controlled X([register[0]], register[1]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation CNOTEquivalenceTest () : Unit {
        AssertOperationsEqualInPlace(2, CNOTPrimitive, CNOTEquivalent);
    }
    
    
    //------------------------------------------------------------------------
    
    operation CCNOTPrimitive (register : Qubit[]) : Unit {
        
        body (...) {
            CCNOT(register[0], register[1], register[2]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation CCNOTEquivalent (register : Qubit[]) : Unit {
        
        body (...) {
            Controlled X(register[0 .. 1], register[2]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation CCNOTEquivalenceTest () : Unit {
        AssertOperationsEqualInPlace(3, CCNOTPrimitive, CCNOTEquivalent);
    }
    
    
    //------------------------------------------------------------------------
    
    operation R1Primitive (theta : Double, register : Qubit[]) : Unit {
        
        body (...) {
            R1(theta, register[0]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation R1Equivalent (theta : Double, register : Qubit[]) : Unit {
        
        body (...) {
            R(PauliZ, theta, register[0]);
            R(PauliI, -theta, register[0]);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation R1EquivalentTest () : Unit {
        
        let nTheta = 101;
        
        for (idxTheta in 0 .. nTheta) {
            let theta = ((2.0 * PI()) * IntAsDouble(idxTheta)) / IntAsDouble(nTheta);
            AssertOperationsEqualInPlace(1, R1Primitive(theta, _), R1Equivalent(theta, _));
        }
    }
    
}


