// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    operation MultiControlledFromOpAndSinglyCtrldOp (
        op : (Qubit => Unit is Adj), 
        singlyControlledOp : ((Qubit, Qubit) => Unit is Adj), 
        controls : Qubit[], target : Qubit) 
    : Unit
    is Adj
    {
        if (Length(controls) == 0)
        {
            op(target);
        }
        elif (Length(controls) == 1)
        {
            singlyControlledOp(controls[0], target);
        }
        else
        {
            MultiControlledU(singlyControlledOp, controls, target);
        }
    }
    
    
    operation MultiControlledFromOpAndSinglyCtrldOp2 (
        op : ((Qubit, Qubit) => Unit is Adj), 
        singlyControlledOp : ((Qubit, Qubit, Qubit) => Unit is Adj), 
        controls : Qubit[], 
        target1 : Qubit, target2 : Qubit) 
    : Unit
    is Adj
    {
        if (Length(controls) == 0)
        {
            op(target1, target2);
        }
        elif (Length(controls) == 1)
        {
            singlyControlledOp(controls[0], target1, target2);
        }
        else
        {
            MultiControlledUTwoTargets(singlyControlledOp, controls, target1, target2);
        }
    }
    
}


