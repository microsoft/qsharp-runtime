namespace IntrinsicTesting {

    open Microsoft.Quantum.Decompositions.Utilities as Utils;
    open Microsoft.Quantum.Diagnostics;

    newtype UnitaryQSharpIntrinsics = (
        X : (Qubit => Unit is Adj + Ctl),
        Y : (Qubit => Unit is Adj + Ctl),
        Z : (Qubit => Unit is Adj + Ctl),
        H : (Qubit => Unit is Adj + Ctl),
        S : (Qubit => Unit is Adj + Ctl),
        T : (Qubit => Unit is Adj + Ctl),
        CNOT : ((Qubit,Qubit) => Unit is Adj + Ctl),
        CCNOT : ((Qubit,Qubit,Qubit) => Unit is Adj + Ctl),
        SWAP : ((Qubit,Qubit) => Unit is Adj + Ctl),
        R : ((Pauli, Double, Qubit) => Unit is Adj + Ctl),
        RFrac : ((Pauli, Int, Int, Qubit) => Unit is Adj + Ctl),
        Rx : ((Double, Qubit) => Unit is Adj + Ctl),
        Ry : ((Double, Qubit) => Unit is Adj + Ctl),
        Rz : ((Double, Qubit) => Unit is Adj + Ctl),
        R1 : ((Double, Qubit) => Unit is Adj + Ctl),
        R1Frac : ((Int, Int, Qubit) => Unit is Adj + Ctl ),
        Exp : ((Pauli[], Double, Qubit[]) => Unit is Adj + Ctl),
        ExpFrac : ((Pauli[], Int, Int, Qubit[]) => Unit is Adj + Ctl)
    );

    function StandardIntrinsics() : UnitaryQSharpIntrinsics {
        return UnitaryQSharpIntrinsics(
            Microsoft.Quantum.Intrinsic.X,
            Microsoft.Quantum.Intrinsic.Y,
            Microsoft.Quantum.Intrinsic.Z,
            Microsoft.Quantum.Intrinsic.H,
            Microsoft.Quantum.Intrinsic.S,
            Microsoft.Quantum.Intrinsic.T,
            Microsoft.Quantum.Intrinsic.CNOT,
            Microsoft.Quantum.Intrinsic.CCNOT,
            Microsoft.Quantum.Intrinsic.SWAP,
            Microsoft.Quantum.Intrinsic.R,
            Microsoft.Quantum.Intrinsic.RFrac,
            Microsoft.Quantum.Intrinsic.Rx,
            Microsoft.Quantum.Intrinsic.Ry,
            Microsoft.Quantum.Intrinsic.Rz,
            Microsoft.Quantum.Intrinsic.R1,
            Microsoft.Quantum.Intrinsic.R1Frac,
            Microsoft.Quantum.Intrinsic.Exp,
            Microsoft.Quantum.Intrinsic.ExpFrac);
    }

    function PaulisToTest() : Pauli[] {
        return [PauliI, PauliX, PauliY, PauliZ];
    }

    operation AssertEqualWithAdjointAndControlled<'TupleT>(actual : ('TupleT => Unit is Adj + Ctl), expected : ('TupleT => Unit is Adj + Ctl), tupleMapper : (Qubit[] -> (Qubit[], 'TupleT) ), tupleSize : Int ) : Unit {
        let actualOnArr = ApplyComposedA(Controlled actual,tupleMapper,_);
        let expectedOnArr = ApplyComposedA(Controlled expected,tupleMapper,_);
        Microsoft.Quantum.Intrinsic.Message($"Checking equality of operations {actual} and {expected}");
        for (numQubits in tupleSize .. MaxControls() + tupleSize) {
            Microsoft.Quantum.Intrinsic.Message($"Total number of qubits: {numQubits}");
            for (repetition in 1 .. NumberOfTestRepetitions()) {
                AssertOperationsEqualReferenced(numQubits, actualOnArr, expectedOnArr);
                AssertOperationsEqualReferenced(numQubits, Adjoint actualOnArr, Adjoint expectedOnArr);
            }
        }
        Microsoft.Quantum.Intrinsic.Message($"Operations {actual} and {expected} are equal as well as their adjoint and controlled versions up to {MaxControls()} controls");
    }

    operation AssertEqualWithAdjointAndControlledQ(actual : (Qubit => Unit is Adj + Ctl), expected : (Qubit => Unit is Adj + Ctl)) : Unit {
        AssertEqualWithAdjointAndControlled(actual, expected, ArrayAsTupleAO<Qubit>, 1);
    }

    operation AssertEqualWithAdjointAndControlledAQ(numQubits : Int, actual : (Qubit[] => Unit is Adj + Ctl), expected : (Qubit[] => Unit is Adj + Ctl)) : Unit {
            AssertEqualWithAdjointAndControlled(actual, expected, ArrayAsTupleAA<Qubit>(numQubits,_), numQubits);
    }

    operation _AssertEqualWithAdjointAndControlledAPQ(paulis : Pauli[], actual : ((Pauli[],Qubit[]) => Unit is Adj + Ctl), expected : ((Pauli[],Qubit[]) => Unit is Adj + Ctl)) : Unit {
        Microsoft.Quantum.Intrinsic.Message($"Checking for Pauli: {paulis}.");
        AssertEqualWithAdjointAndControlledAQ(Length(paulis), actual(paulis,_), expected(paulis,_));
    }

    operation AssertEqualWithAdjointAndControlledAPQ(actual : ((Pauli[],Qubit[]) => Unit is Adj + Ctl), expected : ((Pauli[],Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (numQubits in 1 .. MaxTargets()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking with {numQubits} qubits.");
            IterateThroughCartesianPowerP( numQubits, PaulisToTest(), _AssertEqualWithAdjointAndControlledAPQ(_,actual,expected));
        }
    }

    operation AssertEqualWithAdjointAndControlledPADQA(actual : ((Pauli[],Double,Qubit[]) => Unit is Adj + Ctl), expected : ((Pauli[],Double,Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (angle in AnglesToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking angle {angle}");
            AssertEqualWithAdjointAndControlledAPQ(actual(_,angle,_), expected(_,angle,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledPAIIQA(actual : ((Pauli[],Int,Int,Qubit[]) => Unit is Adj + Ctl), expected : ((Pauli[],Int,Int,Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (fraction in FractionsToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking fraction {fraction}");
            let (numerator, denominatorPower) = fraction;
            AssertEqualWithAdjointAndControlledAPQ(actual(_,numerator,denominatorPower,_), expected(_,numerator,denominatorPower,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledDQ(actual : ((Double, Qubit) => Unit is Adj + Ctl), expected : ((Double, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (angle in AnglesToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking angle {angle}");
            AssertEqualWithAdjointAndControlledQ(actual(angle,_), expected(angle,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledPDQ(actual : ((Pauli, Double, Qubit) => Unit is Adj + Ctl), expected : ((Pauli, Double, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (pauli in PaulisToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking Pauli: {pauli}");
            AssertEqualWithAdjointAndControlledDQ(actual(pauli, _,_), expected(pauli, _,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledIIQ(actual : ((Int, Int, Qubit) => Unit is Adj + Ctl), expected : ((Int, Int, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (fraction in FractionsToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking fraction {fraction}");
            let (numerator, denominatorPower) = fraction;
            AssertEqualWithAdjointAndControlledQ(actual(numerator,denominatorPower,_), expected(numerator,denominatorPower,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledPIIQ(actual : ((Pauli, Int, Int, Qubit) => Unit is Adj + Ctl), expected : ((Pauli, Int, Int, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (pauli in PaulisToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking Pauli: {pauli}");
            AssertEqualWithAdjointAndControlledIIQ(actual(pauli, _,_,_), expected(pauli, _,_,_));
        }
    }

    operation AssertEqualWithAdjointAndControlledQQ(actual : ((Qubit,Qubit) => Unit is Adj + Ctl), expected : ((Qubit,Qubit) => Unit is Adj + Ctl)) : Unit {
        AssertEqualWithAdjointAndControlled(actual, expected, ArrayAsTupleAIOO<Qubit>, 2);
    }

    operation AssertEqualWithAdjointAndControlledQQQ(actual : ((Qubit,Qubit,Qubit) => Unit is Adj + Ctl), expected : ((Qubit,Qubit,Qubit) => Unit is Adj + Ctl)) : Unit {
            AssertEqualWithAdjointAndControlled(actual, expected, ArrayAsTupleAIOOO<Qubit>, 3);
    }

    operation TestInstrinsics( actualIntrinsics : UnitaryQSharpIntrinsics, expectedIntrinsics : UnitaryQSharpIntrinsics ) : Unit {
        if (true) { 
            let eq = AssertEqualWithAdjointAndControlledQ;
            eq(actualIntrinsics::X, expectedIntrinsics::X);
            eq(actualIntrinsics::Y, expectedIntrinsics::Y);
            eq(actualIntrinsics::Z, expectedIntrinsics::Z);
            eq(actualIntrinsics::H, expectedIntrinsics::H);
            eq(actualIntrinsics::S, expectedIntrinsics::S);
            eq(actualIntrinsics::T, expectedIntrinsics::T);
        }

        if (true) {
            let eq = AssertEqualWithAdjointAndControlledQQ;
            eq(actualIntrinsics::CNOT, expectedIntrinsics::CNOT);
            eq(actualIntrinsics::SWAP, expectedIntrinsics::SWAP);
        }

        AssertEqualWithAdjointAndControlledQQQ(actualIntrinsics::CCNOT, expectedIntrinsics::CCNOT);
        AssertEqualWithAdjointAndControlledPDQ(actualIntrinsics::R, expectedIntrinsics::R);

        if (true) {
            let eq = AssertEqualWithAdjointAndControlledDQ;
            eq(actualIntrinsics::Rx, expectedIntrinsics::Rx);
            eq(actualIntrinsics::Ry, expectedIntrinsics::Ry);
            eq(actualIntrinsics::Rz, expectedIntrinsics::Rz);
            eq(actualIntrinsics::R1, expectedIntrinsics::R1);
        }

        AssertEqualWithAdjointAndControlledIIQ(actualIntrinsics::R1Frac, expectedIntrinsics::R1Frac);
        AssertEqualWithAdjointAndControlledPIIQ(actualIntrinsics::RFrac, expectedIntrinsics::RFrac);
        AssertEqualWithAdjointAndControlledPADQA(actualIntrinsics::Exp, expectedIntrinsics::Exp);
        AssertEqualWithAdjointAndControlledPAIIQA(actualIntrinsics::ExpFrac, expectedIntrinsics::ExpFrac);
    }
}