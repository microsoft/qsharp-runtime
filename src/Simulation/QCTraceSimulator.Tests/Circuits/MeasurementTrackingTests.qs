// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;
    
    
    operation SimpleMeasurementTest () : Unit {
        
        
        using (qs = Qubit[2]) {
            Assert([PauliX], [qs[0]], Zero, $"");
            let res = Measure([PauliX], [qs[0]]);
            
            if (res != Zero) {
                fail $"Tracer does not follow asserts";
            }
            
            Assert([PauliY], [qs[1]], Zero, $"");
            let res2 = Measure([PauliY], [qs[1]]);
            
            if (res2 != Zero) {
                fail $"Tracer does not follow asserts";
            }
        }
    }
    
    
    operation SwappedMeasurementTest () : Unit {
        
        
        using (qs = Qubit[2]) {
            Assert([PauliX, PauliZ], qs, Zero, $"");
            let res = Measure([PauliZ, PauliX], [qs[1], qs[0]]);
            
            if (res != Zero) {
                fail $"Tracer does not follow asserts";
            }
        }
    }
    
    
    operation ForcedMeasurementTest () : Unit {
        
        
        using (qs = Qubit[2]) {
            ForceMeasure([PauliZ, PauliX], qs, Zero);
            let res = Measure([PauliZ, PauliX], qs);
            
            if (res != Zero) {
                fail $"Tracer does not follow asserts";
            }
        }
    }
    
    
    operation AllocatedConstraintTest () : Unit {
        
        
        using (qs = Qubit[1]) {
            let res = Measure([PauliZ], qs);
            
            if (res != Zero) {
                fail $"Tracer does not follow asserts";
            }
        }
    }
    
    
    operation MeausermentPreverseConstraintTest () : Unit {
        
        
        using (qs = Qubit[2]) {
            ForceMeasure([PauliZ, PauliX], qs, Zero);
            let res = Measure([PauliZ, PauliX], qs);
            let res2 = Measure([PauliZ, PauliX], qs);
            H(qs[0]);
        }
    }
    
    
    operation UnconstrainedMeasurement1Test () : Unit {
        
        
        using (qs = Qubit[2]) {
            let res = Measure([PauliZ, PauliX], qs);
            H(qs[0]);
        }
    }
    
    
    operation UnconstrainedMeasurement2Test () : Unit {
        
        
        using (qs = Qubit[2]) {
            ForceMeasure([PauliZ, PauliX], qs, Zero);
            H(qs[0]);
            let res = Measure([PauliZ, PauliX], qs);
            H(qs[0]);
        }
    }
    
}


