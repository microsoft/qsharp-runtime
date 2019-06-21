// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Extensions.Bitwise {
    open Microsoft.Quantum.Warnings;

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.xor".
    function Xor(a : Int, b : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.Xor", "Microsoft.Quantum.Bitwise.Xor");
        return Microsoft.Quantum.Bitwise.Xor(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.and".
    function And(a : Int, b : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.And", "Microsoft.Quantum.Bitwise.And");
        return Microsoft.Quantum.Bitwise.And(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.or".
    function Or(a : Int, b : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.Or", "Microsoft.Quantum.Bitwise.Or");
        return Microsoft.Quantum.Bitwise.Or(a, b);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.not".
    function Not(a : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.Not", "Microsoft.Quantum.Bitwise.Not");
        return Microsoft.Quantum.Bitwise.Not(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.parity".
    function Parity(a : Int) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.Parity", "Microsoft.Quantum.Bitwise.Parity");
        return Microsoft.Quantum.Bitwise.Parity(a);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.xbits".
    function XBits(paulies : Pauli[]) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.XBits", "Microsoft.Quantum.Bitwise.XBits");
        return Microsoft.Quantum.Bitwise.XBits(paulies);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.bitwise.zbits".
    function ZBits(paulies : Pauli[]) : Int {
        _Renamed("Microsoft.Quantum.Extensions.Bitwise.ZBits", "Microsoft.Quantum.Bitwise.ZBits");
        return Microsoft.Quantum.Bitwise.ZBits(paulies);
    }

}
