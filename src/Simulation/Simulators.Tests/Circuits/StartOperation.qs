// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests.StartOperation {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics;
    
    
    newtype Qubits = Qubit[];
    
    newtype UDT1 = ((Int, Qubit, (Qubit, Qubit), Result) => Unit is Adj + Ctl);
    
    newtype UDT2 = (Qubit => Unit is Adj + Ctl);
    
    newtype UDT3 = ((Int, Qubit) => Int);
    
    
    operation Basic (a : Int, b : Qubit, (c : Qubit, d : Qubit), e : Result) : Unit {
        
        body (...) {
            X(b);
            X(c);
            X(d);
            X(b);
            Trace(a);
            Trace(b);
            Trace(c);
            Trace(d);
            Trace(e);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation B3 (i : Int, q : Qubit) : Int {
        
        Trace(q);
        return i;
    }
    
    
    operation AllVariants<'T> (gate : ('T => Unit is Adj + Ctl), i : 'T, ctrls : Qubits) : Unit {
        
        body (...) {
            gate(i);
            Adjoint gate(i);
            Controlled gate(ctrls!, i);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation StartOperationTest () : Unit {
        
        using (q = Qubit[5])
        {
            let data  = (0, q[1], (q[2], q[3]), One);                           
            let ctrls = Qubits(q[0..0]);                                        //  B   A   C  CA
                
            Basic(data);                                                        //  1
            (Adjoint Basic)(data);                                              //      1       
            (Controlled Basic)(ctrls!, data);                                    //          1
            (Adjoint (Controlled Basic))(ctrls!, data);                          //              1

            AllVariants(Basic, data, ctrls);                                    //  1   1   1   
            (Adjoint AllVariants)(Basic, data, ctrls);                          //  1   1       1
            (Controlled AllVariants)([q[4]], (Basic, data, ctrls));             //          2   1
            (Adjoint (Controlled AllVariants))([q[4]], (Basic, data, ctrls));   //          1   2
                                                                                        
            let partial = Basic(1, q[1], _, Zero);                               
            AllVariants(partial, (q[2], q[3]), ctrls);                          //  1   1   1
            (Adjoint AllVariants)(partial, (q[2], q[3]), ctrls);                //  1   1       1
            (Controlled AllVariants)([q[4]], (partial, (q[2], q[3]), ctrls));   //          2   1

            let partial2 = partial(q[2], _);    
            partial2(q[3]);                                                     //  1
            partial2(q[3]);                                                     //  1
            partial2(q[3]);                                                     //  1
            AllVariants(partial2, q[3], ctrls);                                 //  1   1   1
            (Adjoint partial2)(q[3]);                                           //      1
        }
    }
    
    
    // This is needed to fix the bug that the parser is reporting incorrectly the type of UDTs:
    
    function UDT1asUnitary (u : UDT1) : ((Int, Qubit, (Qubit, Qubit), Result) => Unit is Adj + Ctl) {
        
        return u!;
    }
    
    
    operation StartOperationUDTTest () : Unit {
        
        using (q = Qubit[5])
        {
            let data  = (0, q[1], (q[2], q[3]), One);
            let ctrls = Qubits(q[0..0]);                
            let u   = UDT1(Basic);
            let uni = UDT1asUnitary(UDT1(Basic));
                                                                                //  B   A   C  CA
            u!(data);                                                           //  1
            (Adjoint u!)(data);                                                 //      1       
            (Controlled u!)(ctrls!, data);                                      //          1
            (Adjoint (Controlled u!))(ctrls!, data);                            //              1

            uni(data);                                                          //  1
            AllVariants(uni, data, ctrls);                                      //  1   1   1   
            (Adjoint AllVariants)(uni, data, ctrls);                            //  1   1       1
            (Controlled AllVariants)([q[4]], (uni, data, ctrls));               //          2   1
            (Adjoint (Controlled AllVariants))([q[4]], (uni, data, ctrls));     //          1   2
                                                                                        
            let partial = uni(1, q[1], _, Zero);                                    
            AllVariants(partial, (q[2], q[3]), ctrls);                          //  1   1   1
            (Adjoint AllVariants)(partial, (q[2], q[3]), ctrls);                //  1   1       1
            (Controlled AllVariants)([q[4]], (partial, (q[2], q[3]), ctrls));   //          2   1
                                                                                        
            let partial2 = partial(q[2], _);                                    //  
            partial2(q[3]);                                                     //  1
            partial2(q[3]);                                                     //  1
            partial2(q[3]);                                                     //  1
            (Adjoint partial2)(q[3]);                                           //      1
                                                                                        
            let u2 = UDT2(partial2);                                                
            u2!(q[2]);                                                           //  1
            u2!(q[2]);                                                           //  1
            AllVariants(u2!, q[1], ctrls);                                       //  1   1   1   

            let u3 = UDT3(B3);
            let p3 = u3!(_, q[0]);
            mutable results = new Int[4];
            for (i in 0..3) 
            {
                set results = results 
                    w/ i <- u3!(i, q[i])
                    w/ i <- p3(i);
            }

            ResetAll(q);
        }
    }
    
}


