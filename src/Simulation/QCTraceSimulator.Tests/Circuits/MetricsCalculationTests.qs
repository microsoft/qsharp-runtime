// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests {
    
    open Microsoft.Quantum.Intrinsic;
    
    
    operation TwoCNOTsTest () : Unit {
        
        
        using (qs = Qubit[3]) {
            CNOT(qs[0], qs[1]);
            CNOT(qs[1], qs[2]);
        }
    }
    
    
    operation ThreeCNOTsTest () : Unit {
        
        
        using (qs = Qubit[3]) {
            CNOT(qs[0], qs[1]);
            CNOT(qs[1], qs[2]);
            CNOT(qs[0], qs[1]);
        }
    }
    
    operation TDepthWidth () : Unit {
        // q2 q1 q3 q4
        // |  |      
        // O--O      
        // |  |      
        //    |  |  |
        //    |  O--O
        //    |  |  |
        //    |  |   
        //    O--O   
        //    |  |   
        //           
        // Width 4, Depth 2.
        // Alternatively q2 is reused for q4 (or q3)
        // Width 3, Depth 3.

        using (q1 = Qubit()) {
            using (q2 = Qubit()) {
                Controlled Z([q2], q1);
            }
            using (q3 = Qubit()) {
                using (q4 = Qubit()) {
                    Controlled Z([q4], q3);
                }
                Controlled Z([q3], q1);
            }
        }
    }

    operation BunchOfCNOTs (qs : Qubit[], moreQubits : Qubit[]) : Unit {
        
        body (...) {
            
            for (j in 0 .. Length(qs) - 2) {
                
                for (k in j .. Length(qs) - 1) {
                    CNOT(qs[k], moreQubits[k]);
                }
            }
        }
        
        adjoint invert;
    }
    
    
    operation TDepthOne () : Unit {
        
        let num = 4;
        
        using (qs = Qubit[num]) {
            
            using (moreQubits = Qubit[num]) {
                BunchOfCNOTs(qs, moreQubits);
                
                for (k in 0 .. Length(qs) - 1) {
                    T(qs[k]);
                    Adjoint T(moreQubits[k]);
                }
                
                Adjoint BunchOfCNOTs(qs, moreQubits);
            }
        }
    }
    
    operation TCountZeroGatesTest () : Unit {
        
        
        using (qs = Qubit[3]) {
            let qubit = qs[0];
            S(qubit);
            Adjoint S(qubit);
            
            for (i in 0 .. 10) {
                let pow = 2 * i + 1;
                let denomPow = 2;
                RFrac(PauliZ, pow, denomPow, qubit);
                RFrac(PauliY, pow, denomPow, qubit);
                RFrac(PauliX, pow, denomPow, qubit);
                ExpFrac([PauliZ], pow, denomPow, [qubit]);
                ExpFrac([PauliY], pow, denomPow, [qubit]);
                ExpFrac([PauliX], pow, denomPow, [qubit]);
                R1Frac(pow, denomPow - 1, qubit);
            }
            
            ExpFrac([PauliI, PauliI, PauliI], 1, 3, qs);
            RFrac(PauliI, 1, 3, qubit);
        }
    }
    
    
    operation TCountOneGatesTest () : Unit {
        
        
        using (qs = Qubit[3]) {
            let qubit = qs[0];
            T(qubit);
            Adjoint T(qubit);
            
            for (i in 0 .. 10) {
                let pow = 2 * i + 1;
                let denomPow = 3;
                RFrac(PauliZ, pow, denomPow, qubit);
                RFrac(PauliY, pow, denomPow, qubit);
                RFrac(PauliX, pow, denomPow, qubit);
                ExpFrac([PauliZ], pow, denomPow, [qubit]);
                ExpFrac([PauliY], pow, denomPow, [qubit]);
                ExpFrac([PauliX], pow, denomPow, [qubit]);
                R1Frac(pow, denomPow - 1, qubit);
            }
        }
    }
    
}


