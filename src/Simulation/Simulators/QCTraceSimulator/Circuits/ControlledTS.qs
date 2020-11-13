// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    
    /// # Remarks
    /// Based on Remark 3.2 in https://arxiv.org/pdf/1210.0974.pdf
    /// This is a small refinement of a swap trick
    operation ControlledTS (control : Qubit, target : Qubit) : Unit
    is Adj {

        using (ans = Qubit[1])
        {
            let a = ans[0];
            CCminusIX(control, target, a);
            InternalT(a);
            InternalS(a);
            Adjoint CCminusIX(control, target, a);
        }
    }
    
}


