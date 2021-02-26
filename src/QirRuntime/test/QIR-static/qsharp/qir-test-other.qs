// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Other {

    open Microsoft.Quantum.Bitwise;

    function ParityTest() : Int {
        //function Parity (a : Int) : Int
        if 0 != Parity(0)                       { return  1; }
        if 1 != Parity(1)                       { return  2; }
        if 1 != Parity(2)                       { return  3; }
        if 0 != Parity(3)                       { return  4; }
        if 0 != Parity(0xFF)                    { return  5; }
        if 1 != Parity(0x100)                   { return  6; }
        if 0 != Parity(0xFFFF)                  { return  7; }
        if 1 != Parity(0x10000)                 { return  8; }
        if 1 != Parity(0x7F00000000000000)      { return  9; }
        if 0 != Parity(0x0F00000000000000)      { return 10; }
                                                       
        if 0 != Parity(-1)                      { return 11; }    // 0xFFFFFFFFFFFFFFFF
        if 1 != Parity(-2)                      { return 12; }    // 0xFFFFFFFFFFFFFFFE

        return 0;
    }

}
