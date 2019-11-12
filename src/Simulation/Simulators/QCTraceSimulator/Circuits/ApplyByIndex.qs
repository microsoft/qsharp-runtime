// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> Applies operation given by op to
    /// array of qubits constructed as [ target[k] : k ∈ index ]
    /// </summary>
    /// <param name="op"> Operation to apply, must have an Adjoint
    /// and Controlled </param>
    operation ApplyByIndexAdjointableControllable (op : (Qubit[] => Unit is Adj + Ctl), index : Int[], target : Qubit[]) : Unit
    {
        body (...)
        {
            mutable newTarget = new Qubit[Length(index)];
            
            for (i in 0 .. Length(index) - 1)
            {
                set newTarget = newTarget w/ i <- target[index[i]];
            }
            
            op(newTarget);
        }
        
        adjoint (...)
        {
            mutable newTarget = new Qubit[Length(index)];
            
            for (i in 0 .. Length(index) - 1)
            {
                set newTarget = newTarget w/ i <- target[index[i]];
            }
            
            Adjoint op(newTarget);
        }
        
        controlled (ctrls, ...)
        {
            mutable newTarget = new Qubit[Length(index)];
            
            for (i in 0 .. Length(index) - 1)
            {
                set newTarget = newTarget w/ i <- target[index[i]];
            }
            
            Controlled op(ctrls, newTarget);
        }
        
        controlled adjoint (ctrls, ...)
        {
            mutable newTarget = new Qubit[Length(index)];
            
            for (i in 0 .. Length(index) - 1)
            {
                set newTarget = newTarget w/ i <- target[index[i]];
            }
            
            Adjoint Controlled op(ctrls, newTarget);
        }
    }
    
}


