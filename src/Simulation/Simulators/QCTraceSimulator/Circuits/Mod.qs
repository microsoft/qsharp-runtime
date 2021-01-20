// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    /// # Summary
    /// returns 'val' modulo modulus
    function Mod (value : Int, modulus : Int) : Int
    {
        let mod = value % modulus;        
        return mod < 0 ? mod + modulus | mod;
    }
    
}


