namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    open Microsoft.Quantum.Environment;

    operation BorrowSubTest () : (Int, Int)
    {
        mutable innerBorrow = 0;
        borrowing (qb = Qubit())
        {
            set innerBorrow = GetQubitsAvailableToBorrow();
        }
        return (GetQubitsAvailableToBorrow(), innerBorrow);
    }

    operation GetAvailableTest (allocSize : Int) : (Int, Int, Int, Int, Int, Int)
    {
        let initialUse = GetQubitsAvailableToUse();
        let initialBorrow = GetQubitsAvailableToBorrow();

        mutable result = (0, 0, 0, 0, 0, 0);

        using (qs = Qubit[allocSize])
        {
            let afterUse = GetQubitsAvailableToUse();
            let afterBorrow = GetQubitsAvailableToBorrow();
            let (subBorrow, innerBorrow) = BorrowSubTest();
            set result = (initialUse, initialBorrow, afterUse, afterBorrow, subBorrow, innerBorrow);
        }

        return result;
    }
}
