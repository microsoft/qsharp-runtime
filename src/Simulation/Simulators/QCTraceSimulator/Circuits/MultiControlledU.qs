// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    /// # Summary
    /// Applies multiply controlled unitary given a singly controlled one
    /// 
    /// # Input
    /// ## controlledU
    /// Singly controlled unitary to turn into multiply-controlled.
    /// First argument is control, second is target.
    operation MultiControlledU (controlledU : ((Qubit, Qubit) => Unit is Adj), controls : Qubit[], target : Qubit) : Unit
    is Adj {

        FailOn(Length(controls) < 2, $"operation is defined for 2 or more controls");
            
        using (ands = Qubit[Length(controls) - 1])
        {
            AndLadder(controls, ands);
            controlledU(ands[Length(ands) - 1], target);
            Adjoint AndLadder(controls, ands);
        }
    }
    
    
    /// # Summary
    /// Applies multiply controlled unitary given a singly controlled one
    /// 
    /// # Input
    /// ## controlledU
    /// Singly controlled unitary to turn into multiply-controlled. 
    /// First argument is control, second and third are targets
    operation MultiControlledUTwoTargets (controlledU : ((Qubit, Qubit, Qubit) => Unit is Adj), controls : Qubit[], target1 : Qubit, target2 : Qubit) : Unit
    is Adj {

        FailOn(Length(controls) < 2, $"function is defined for 2 or more controls");
            
        using (ands = Qubit[Length(controls) - 1])
        {
            AndLadder(controls, ands);
            controlledU(ands[Length(ands) - 1], target1, target2);
            Adjoint AndLadder(controls, ands);
        }
    }
    
}


