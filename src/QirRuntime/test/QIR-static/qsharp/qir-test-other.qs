// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Bitwise {

    function MyParity(param : Int) : Int {
        mutable tmpParam = param;
        mutable result = false;
        while tmpParam != 0 {
            set tmpParam = tmpParam &&& (tmpParam - 1);
            set result = not result;
        }
        return (result ? 1 | 0);
    }
}

namespace Microsoft.Quantum.Testing.QIR.Other {

    open Microsoft.Quantum.Bitwise;

    function ParityTest() : Int {
        //function Parity (a : Int) : Int
        if 0 != MyParity(0)                       { return  1; }
        if 1 != MyParity(1)                       { return  2; }
        if 1 != MyParity(2)                       { return  3; }
        if 0 != MyParity(3)                       { return  4; }
        if 0 != MyParity(0xFF)                    { return  5; }
        if 1 != MyParity(0x100)                   { return  6; }
        if 0 != MyParity(0xFFFF)                  { return  7; }
        if 1 != MyParity(0x10000)                 { return  8; }
        if 1 != MyParity(0x7F00000000000000)      { return  9; }
        if 0 != MyParity(0x0F00000000000000)      { return 10; }
                                                         
        if 0 != MyParity(-1)                      { return 11; }    // 0xFFFFFFFFFFFFFFFF
        if 1 != MyParity(-2)                      { return 12; }    // 0xFFFFFFFFFFFFFFFE

        return 0;
    }

}
