// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Environment;

    operation BorrowSubTest () : (Int, Int)
    {
        mutable innerBorrow = 0;
        borrowing (qb = Qubit())
        {
            set innerBorrow = GetQubitsAvailableToBorrow() + GetQubitsAvailableToUse();
        }
        return (GetQubitsAvailableToBorrow() + GetQubitsAvailableToUse(), innerBorrow);
    }

    operation GetAvailableTest (allocSize : Int) : (Int, Int, Int, Int, Int, Int)
    {
        let initialUse = GetQubitsAvailableToUse();
        let initialBorrow = GetQubitsAvailableToBorrow() + initialUse;

        mutable result = (0, 0, 0, 0, 0, 0);

        using (qs = Qubit[allocSize])
        {
            let afterUse = GetQubitsAvailableToUse();
            let afterBorrow = GetQubitsAvailableToBorrow() + afterUse;
            let (subBorrow, innerBorrow) = BorrowSubTest();
            set result = (initialUse, initialBorrow, afterUse, afterBorrow, subBorrow, innerBorrow);
        }

        return result;
    }
}
