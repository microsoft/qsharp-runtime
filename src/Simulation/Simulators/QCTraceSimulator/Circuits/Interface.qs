// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation {

    /// # Summary
    /// Controlled-X gate natively supported by the machine
    ///
    /// # Input
    /// ## control
    /// the qubit used to control the application of X gate
    /// ## target
    /// the qubit to which Pauli X is applied when control qubit is in state |1⟩
    ///
    /// # Remarks
    /// Controlled-X gate with target on qubit 2 and control on qubit 1
    /// is C₁X₂ = [ [1,0,0,0], [0,1,0,0], [0,0,0,1], [0,0,1,0] ]
    operation Interface_CX (control : Qubit, target : Qubit) : Unit {
        body intrinsic;
    }

    /// # Summary
    /// R gate natively supported by the machine. It is exp(-iφP/2) where P is the Pauli matrix
    ///
    /// # Input
    /// ## axis
    /// Pauli matrix, P
    /// ## angle
    /// Rotation angle, φ
    /// ## target
    /// the qubit operation is acting on
    operation Interface_R (axis : Pauli, angle : Double, target : Qubit) : Unit {
        body intrinsic;
    }

    /// # Summary
    /// RzFrac gate natively supported by the machine. It is exp(iπkP/2ⁿ) where P is the Pauli matrix
    ///
    /// # Input
    /// ## axis
    /// Pauli matrix, P
    /// ## numerator
    /// k
    /// ## power
    /// n
    /// ## target
    /// the qubit operation is acting on
    ///
    /// # Remarks
    /// When power is 3 or less the operation is guaranteed to use S and T and Z gates to perform rotation
    operation Interface_RFrac (axis : Pauli, numerator : Int, power : Int, target : Qubit) : Unit {
        body intrinsic;
    }

    /// # Summary
    /// Applies Clifford multiplied by a pauli matrix
    /// given by 'pauli' to the qubit given by 'target'
    ///
    /// # Input
    /// ## cliffordId
    /// Id of the single qubit unitary to apply. See remarks
    ///
    /// # Remarks
    /// The list of id's corresponding to Cliffords is given by:
    /// Identity - 0
    /// H - 1
    /// S - 2
    /// H followed by S ( as circuit ) - 3
    /// S followed by H ( as circuit ) - 4
    /// H S H - 5
    operation Interface_Clifford (cliffordId : Int, pauli : Pauli, target : Qubit) : Unit {
        body intrinsic;
    }


    /// <summary> Forces the future measurement of a given observable to give specified result </summary>
    operation ForceMeasure (observable : Pauli[], target : Qubit[], result : Result) : Unit {
        body intrinsic;
    }
}
