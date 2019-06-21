namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    function Add(a: Int, b: Int) : Int
    {
        return a + b;
    }

    function ApplyTwice<'T>(f: ('T -> Int), a: 'T) : Int
    {
        return f(a) + f(a);
    }

    operation PartialFunctionsTest () : Unit
    {
        let plusFive = Add(5, _);
        let partial_3 = ApplyTwice(_, 3);
        let partial_9 = ApplyTwice(_, 9);

        AssertEqual(12, ApplyTwice(plusFive, 1));
        AssertEqual(16, partial_3(plusFive));
        AssertEqual(28, partial_9(plusFive));
    }
}