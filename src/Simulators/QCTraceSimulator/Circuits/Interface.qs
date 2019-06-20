namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation {
    
    /// <summary> Controlled-X gate natively supported by the machine </summary>
    /// <param name="control"> the qubit used to control the application of X gate</param>
    /// <param name="target"> the qubit to which Pauli X is applied when control qubit is in state |1⟩ </param>
    /// <remarks> Controlled-X gate with target on qubit 2 and control on qubit 1
    /// is C₁X₂ = [ [1,0,0,0], [0,1,0,0], [0,0,0,1], [0,0,1,0] ]
    /// </remarks>
    operation Interface_CX (control : Qubit, target : Qubit) : Unit {
        body intrinsic;
    }
    
    
    /// <summary> R gate natively supported by the machine. It is exp(-iφP/2) where P is the Pauli matrix </summary>
    /// <param name="axis"> Pauli matrix, P </param>
    /// <param name="angle"> Rotation algle, φ </param>
    /// <param name="target"> the qubit operation is acting on </param>
    operation Interface_R (axis : Pauli, angle : Double, target : Qubit) : Unit {
        body intrinsic;
    }
    
    
    /// <summary> RzFrac gate natively supported by the machine. It is exp(iπkP/2ⁿ) where P is the Pauli matrix </summary>
    /// <param name="axis"> Pauli matrix, P </param>
    /// <param name="numerator"> k </param>
    /// <param name="power"> n </param>
    /// <param name="target"> the qubit operation is acting on </param>
    /// <remarks> When power is 3 or less the operation is guaranteed to use S and T and Z gates to perform rotation </remarks>
    operation Interface_RFrac (axis : Pauli, numerator : Int, power : Int, target : Qubit) : Unit {
        body intrinsic;
    }
    
    
    /// <summary> Applies Clifford multiplied by a pauli matrix
    /// given by 'pauli' to the qubit given by 'target' </summary>
    /// <param name="cliffordID"> Id of the single qubit unitary to apply. See remarks </param>
    /// <remarks>
    /// The list of id's corresponding to Cliffords is given by:
    /// Idenity - 0
    /// H - 1
    /// S - 2
    /// H followed by S ( as circuit ) - 3
    /// S followed by H ( as circuit ) - 4
    /// H S H - 5
    /// </remarks>
    operation Interface_Clifford (cliffordId : Int, pauli : Pauli, target : Qubit) : Unit {
        body intrinsic;
    }
    
    
    /// <summary> Forces the future measurement of a given observable to give specified result </summary>
    operation ForceMeasure (observable : Pauli[], target : Qubit[], result : Result) : Unit {
        body intrinsic;
    }
    
}


