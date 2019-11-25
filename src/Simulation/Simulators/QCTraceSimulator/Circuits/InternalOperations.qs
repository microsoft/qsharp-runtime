// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits {
    
    open Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;
    
    
    function Enum_Identity () : Int {
        return 0;
    }
    
    
    function Enum_H () : Int {
        return 1;
    }
    
    
    function Enum_S () : Int {
        return 2;
    }
    
    
    function Enum_HthenS () : Int {
        return 3;
    }
    
    
    function Enum_SthenH () : Int {
        return 4;
    }
    
    
    function Enum_HSH () : Int {
        return 5;
    }
    
    /// # Summary
    /// Hadamard gate, e.g. [[1,1],[1,-1]]/Sqrt{2} 
    operation InternalH (target : Qubit) : Unit
    {
        body (...)
        {
            Interface_Clifford(Enum_H(), PauliI, target);
        }
        
        adjoint self;
    }
    
    
    /// <summary> Hadamard gate, e.g. [[1,1],[1,-1]]/Sqrt{2} </summary>
    /// 
    
    /// # Summary
    /// Hadamard gate, e.g. [[1,1],[1,-1]]/Sqrt{2}
    operation InternalHY (target : Qubit) : Unit
    {
        body (...)
        {
            Interface_Clifford(Enum_HthenS(), PauliI, target);
        }
        
        adjoint (...)
        {
            Interface_Clifford(Enum_SthenH(), PauliZ, target);
        }
    }
    
    
    /// <summary> S gate, e.g. [[1,0],[0,i]] </summary>
    /// 
    
    /// # Summary
    /// S gate, e.g. [[1,0],[0,i]]
    operation InternalS (target : Qubit) : Unit
    {
        body (...)
        {
            Interface_Clifford(Enum_S(), PauliI, target);
        }
        
        adjoint (...)
        {
            Interface_Clifford(Enum_S(), PauliZ, target);
        }
    }
    
    
    operation InternalR (axis : Pauli, angle : Double, target : Qubit) : Unit
    {
        body (...)
        {
            Interface_R(axis, angle, target);
        }
        
        adjoint (...)
        {
            Interface_R(axis, -angle, target);
        }
    }
    
    
    operation InternalRz (angle : Double, target : Qubit) : Unit
    is Adj {
        InternalR(PauliZ, angle, target);
    }
    
    
    operation InternalRFrac (axis : Pauli, numerator : Int, power : Int, target : Qubit) : Unit
    {
        body (...)
        {
            Interface_RFrac(axis, numerator, power, target);
        }
        
        adjoint (...)
        {
            Interface_RFrac(axis, -numerator, power, target);
        }
    }
    
    
    operation InternalRzFrac (numerator : Int, power : Int, target : Qubit) : Unit
    is Adj {
        InternalRFrac(PauliZ, numerator, power, target);
    }
    
    
    operation InternalT (target : Qubit) : Unit
    is Adj {
        InternalRzFrac(-1, 3, target);
    }
    
    
    operation InternalCX (control : Qubit, target : Qubit) : Unit
    {
        body (...)
        {
            Interface_CX(control, target);
        }
        
        adjoint self;
    }
    
    
    operation InternalPauli (pauli : Pauli, target : Qubit) : Unit
    {
        body (...)
        {
            Interface_Clifford(Enum_Identity(), pauli, target);
        }
        
        adjoint self;
    }
    
}


