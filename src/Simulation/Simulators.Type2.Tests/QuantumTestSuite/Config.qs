// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    function IsReversibleSimulator () : Bool {
        
        return true;
    }
    
    
    function IsStabilizerSimulator () : Bool {
        
        return true;
    }
    
    
    function Accuracy () : Double {
        
        return 1E-10;
    }
    
    
    function MaxQubitsToAllocateForOneQubitTests () : Int {
        
        return 5;
    }
    
    
    function MaxQubitsToAllocateForTwoQubitTests () : Int {
        
        return 2;
    }
    
    
    function IsFullSimulator () : Bool {
        
        return true;
    }
    
    
    function MaxDenomiantorPowerToTest () : Int {
        
        return 3;
    }
    
}


