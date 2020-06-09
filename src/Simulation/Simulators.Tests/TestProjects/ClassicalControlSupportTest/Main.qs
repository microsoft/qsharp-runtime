namespace Quantum.ClassicControlSupportTest {
    open Microsoft.Quantum.Simulation.QuantumProcessor.Extensions;
    @EntryPoint()
    operation Main () : Unit {
        ApplyIfZeroTest();
        ApplyIfZeroATest();
        ApplyIfZeroCTest();
        ApplyIfZeroCATest();
        
        ApplyIfOneTest();
        ApplyIfOneATest();
        ApplyIfOneCTest();
        ApplyIfOneCATest();
        
        ApplyIfElseRTest();
        ApplyIfElseRATest();
        ApplyIfElseRCTest();
        ApplyIfElseRCATest();
        
        ApplyConditionallyTest();
        ApplyConditionallyATest();
        ApplyConditionallyCTest();
        ApplyConditionallyCATest();
    }

    operation DoNothing() : Unit is Adj + Ctl { }
    
    // ApplyIfZero

    operation ApplyIfZeroTest() : Unit {
        ApplyIfZero(Zero, (DoNothing, ()));
    }

    operation ApplyIfZeroATest() : Unit {
        ApplyIfZeroA(Zero, (DoNothing, ()));
    }

    operation ApplyIfZeroCTest() : Unit {
        ApplyIfZeroC(Zero, (DoNothing, ()));
    }

    operation ApplyIfZeroCATest() : Unit {
        ApplyIfZeroCA(Zero, (DoNothing, ()));
    }

    // ApplyIfOne

    operation ApplyIfOneTest() : Unit {
        ApplyIfOne(Zero, (DoNothing, ()));
    }

    operation ApplyIfOneATest() : Unit {
        ApplyIfOneA(Zero, (DoNothing, ()));
    }

    operation ApplyIfOneCTest() : Unit {
        ApplyIfOneC(Zero, (DoNothing, ()));
    }

    operation ApplyIfOneCATest() : Unit {
        ApplyIfOneCA(Zero, (DoNothing, ()));
    }

    // ApplyIfElseR

    operation ApplyIfElseRTest() : Unit {
        ApplyIfElseR(Zero, (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyIfElseRATest() : Unit {
        ApplyIfElseRA(Zero, (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyIfElseRCTest() : Unit {
        ApplyIfElseRC(Zero, (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyIfElseRCATest() : Unit {
        ApplyIfElseRCA(Zero, (DoNothing, ()), (DoNothing, ()));
    }

    // ApplyConditionally

    operation ApplyConditionallyTest() : Unit {
        ApplyConditionally([Zero], [Zero], (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyConditionallyATest() : Unit {
        ApplyConditionallyA([Zero], [Zero], (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyConditionallyCTest() : Unit {
        ApplyConditionallyC([Zero], [Zero], (DoNothing, ()), (DoNothing, ()));
    }

    operation ApplyConditionallyCATest() : Unit {
        ApplyConditionallyCA([Zero], [Zero], (DoNothing, ()), (DoNothing, ()));
    }
}
