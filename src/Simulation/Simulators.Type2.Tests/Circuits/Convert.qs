// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    open Microsoft.Quantum.Convert;
    
    
    operation ConvertTest () : Unit {
        let (v1, b1) = MaybeBigIntAsInt(10L);
        let (v2, b2) = MaybeBigIntAsInt(9223372036854775807L);
        let (v3, b3) = MaybeBigIntAsInt(9223372036854775808L);
        let (v4, b4) = MaybeBigIntAsInt(-10L);
        let (v5, b5) = MaybeBigIntAsInt(-9223372036854775808L);
        let (v6, b6) = MaybeBigIntAsInt(-9223372036854775809L);

        AssertEqual(10, v1);
        AssertEqual(true, b1);

        AssertEqual(9223372036854775807, v2);
        AssertEqual(true, b2);

        AssertEqual(0, v3);
        AssertEqual(false, b3);

        AssertEqual(-10, v4);
        AssertEqual(true, b4);

        //AssertEqual(-9223372036854775808, v5); should not fail
        AssertEqual(true, b5);

        AssertEqual(0, v6);
        AssertEqual(false, b6);
    }
    
}
