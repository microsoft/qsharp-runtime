// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// <summary> Doubly-controlled X. Maps qubits in computational state |a,b,c⟩ to
    ///  |a,b,(c⊕(a∧b)⟩ </summary>
    /// <param name = "control1"> qubit corresponding to 'a' above </param>
    /// <param name = "control2"> qubit corresponding to 'b' above </param>
    /// <param name = "target"> qubit corresponding to 'c' above </param>
    operation CCX (control1 : Qubit, control2 : Qubit, target : Qubit) : Unit
    is Adj {
        PauliZFlip(PauliX, target);
        CCZ(control1, control2, target);
        Adjoint PauliZFlip(PauliX, target);
    }
    
}


