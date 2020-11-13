// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{

    /// # Summary
    /// Calls "fail message" when the first argument is True
    function FailOn (failIfTrue : Bool, message : String) : Unit
    {
        if (failIfTrue)
        {
            fail message;
        }
    }
    
}


