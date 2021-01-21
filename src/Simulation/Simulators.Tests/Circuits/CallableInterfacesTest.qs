// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    operation NoOp (qubit : Qubit) : Unit {
        
    }
    
    
    operation NoOpAdjoint (qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
    }
    
    
    operation NoOpControlled (qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        controlled distribute;
    }
    
    
    operation NoOpUnitary (qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation NoOpTuple (r : Result, i : Int, qubit : Qubit) : Unit {
        
    }
    
    
    operation NoOpAdjointTuple (r : Result, i : Int, qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
    }
    
    
    operation NoOpControlledTuple (r : Result, i : Int, qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        controlled distribute;
    }
    
    
    operation NoOpUnitaryTuple (r : Result, i : Int, qubit : Qubit) : Unit {
        
        body (...) {
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    operation CheckPlain (gate : (Qubit => Unit), qubit : Qubit) : Unit {
        
        gate(qubit);
    }
    
    
    operation CheckAdjoint (gate : (Qubit => Unit is Adj), qubit : Qubit) : Unit {
        
        Adjoint gate(qubit);
    }
    
    
    operation CheckControlled (gate : (Qubit => Unit is Ctl), qubit : Qubit) : Unit {
        
        
        using (ctrls = Qubit[2]) {
            Controlled gate(ctrls, qubit);
        }
    }
    
    
    operation CheckUnitary (gate : (Qubit => Unit is Adj + Ctl), qubit : Qubit) : Unit {
        
        
        using (ctrls = Qubit[2]) {
            Adjoint Controlled gate(ctrls, qubit);
            Controlled (Adjoint gate)(ctrls, qubit);
        }
    }
    
    
    operation OneRound (plain : (Qubit => Unit), adj : (Qubit => Unit is Adj), ctr : (Qubit => Unit is Ctl), uni : (Qubit => Unit is Adj + Ctl)) : Unit {
        
        
        using (qubits = Qubit[1]) {
            let qubit = qubits[0];
            CheckPlain(plain, qubit);
            CheckPlain(adj, qubit);
            CheckPlain(ctr, qubit);
            CheckPlain(uni, qubit);
            CheckAdjoint(adj, qubit);
            CheckAdjoint(uni, qubit);
            CheckControlled(ctr, qubit);
            CheckControlled(uni, qubit);
            CheckUnitary(uni, qubit);
        }
    }
    
    
    operation CallableInterfacesTest () : Unit {
        
        
        // good 'ol operations
        OneRound(NoOp, NoOpAdjoint, NoOpControlled, NoOpUnitary);
        
        // one level of partial application
        OneRound(NoOpTuple(Zero, 1, _), NoOpAdjointTuple(Zero, 1, _), NoOpControlledTuple(Zero, 1, _), NoOpUnitaryTuple(Zero, 1, _));
        
        // two level of partial application
        OneRound((NoOpTuple(One, _, _))(1, _), (NoOpAdjointTuple(One, _, _))(1, _), (NoOpControlledTuple(One, _, _))(1, _), (NoOpUnitaryTuple(One, _, _))(1, _));
    }
    
}


