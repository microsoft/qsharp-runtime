// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Extensions.Bitwise {

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.xor".
    @Deprecated ("Microsoft.Quantum.Bitwise.Xor")
    function Xor(a : Int, b : Int) : Int {
        return Microsoft.Quantum.Bitwise.Xor(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.and".
    @Deprecated ("Microsoft.Quantum.Bitwise.And")
    function And(a : Int, b : Int) : Int {
        return Microsoft.Quantum.Bitwise.And(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.or".
    @Deprecated ("Microsoft.Quantum.Bitwise.Or")
    function Or(a : Int, b : Int) : Int {
        return Microsoft.Quantum.Bitwise.Or(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.not".
    @Deprecated ("Microsoft.Quantum.Bitwise.Not")
    function Not(a : Int) : Int {
        return Microsoft.Quantum.Bitwise.Not(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.parity".
    @Deprecated ("Microsoft.Quantum.Bitwise.Parity")
    function Parity(a : Int) : Int {
        return Microsoft.Quantum.Bitwise.Parity(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.xbits".
    @Deprecated ("Microsoft.Quantum.Bitwise.XBits")
    function XBits(paulies : Pauli[]) : Int {
        return Microsoft.Quantum.Bitwise.XBits(paulies);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.zbits".
    @Deprecated ("Microsoft.Quantum.Bitwise.ZBits")
    function ZBits(paulies : Pauli[]) : Int {
        return Microsoft.Quantum.Bitwise.ZBits(paulies);
    }

}
