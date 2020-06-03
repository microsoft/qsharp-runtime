// Methods in this file implement executing multiple variants of a given operator
// to exercise its decompositions in all of those cases. For testing convenience
// similar operators are grouped into a few batches.
namespace IntrinsicTesting {

    open Microsoft.Quantum.Decompositions.Utilities as Utils;
    open Microsoft.Quantum.Diagnostics;

    //=========================================================================
    // Groups of operators that can be tested together
    //=========================================================================
    operation ExecuteBasicInstrinsics(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        let eq = ExecuteWithAdjointAndControlledQ;
        eq(intrinsics::X);
        eq(intrinsics::Y);
        eq(intrinsics::Z);
        eq(intrinsics::H);
        eq(intrinsics::S);
        eq(intrinsics::T);
    }

    operation ExecuteSWAPandCNOT(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        let eq = ExecuteWithAdjointAndControlledQQ;
        eq(intrinsics::CNOT);
        eq(intrinsics::SWAP);
    }

    operation ExecuteRotations(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        let eq = ExecuteWithAdjointAndControlledDQ;
        eq(intrinsics::Rx);
        eq(intrinsics::Ry);
        eq(intrinsics::Rz);
        eq(intrinsics::R1);
    }

    operation ExecuteCCNOT(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledQQQ(intrinsics::CCNOT);
    }

    operation ExecuteR(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledPDQ(intrinsics::R);
    }

    operation ExecuteR1Frac(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledIIQ(intrinsics::R1Frac);
    }

    operation ExecuteRFrac(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledPIIQ(intrinsics::RFrac);
    }

    operation ExecuteExp(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledPADQA(intrinsics::Exp);
    }

    operation ExecuteExpFrac(intrinsics : UnitaryQSharpIntrinsics) : Unit {
        ExecuteWithAdjointAndControlledPAIIQA(intrinsics::ExpFrac);
    }

    //=========================================================================
    // Helpers for executing adjoint and controlled variants of an operator.
    //=========================================================================
    operation ExecuteOnQubitArray(nQubits : Int, op : (Qubit[] => Unit is Adj))  : Unit {
        using( qubits = Qubit[nQubits] ) {
            op(qubits);
            Adjoint op(qubits);
        }
    }

    operation ExecuteWithAdjointAndControlled<'TupleT>(op : ('TupleT => Unit is Adj + Ctl), tupleMapper : (Qubit[] -> (Qubit[], 'TupleT) ), tupleSize : Int ) : Unit {
        let op_composed = ApplyComposedA(Controlled op, tupleMapper, _);
        Microsoft.Quantum.Intrinsic.Message($"Executing {op}");

        for (numQubits in tupleSize .. MaxControls() + tupleSize) {
            Microsoft.Quantum.Intrinsic.Message($"Total number of qubits: {numQubits}");
            for (repetition in 1 .. NumberOfTestRepetitions()) {
                ExecuteOnQubitArray(numQubits, op_composed);
            }
        }
    }

    operation ExecuteWithAdjointAndControlledQ(op : (Qubit => Unit is Adj + Ctl)) : Unit {
        ExecuteWithAdjointAndControlled(op, ArrayAsTupleAO<Qubit>, 1);
    }

    operation ExecuteWithAdjointAndControlledAQ(numQubits : Int, op : (Qubit[] => Unit is Adj + Ctl)) : Unit {
        ExecuteWithAdjointAndControlled(op, ArrayAsTupleAA<Qubit>(numQubits,_), numQubits);
    }

    operation _ExecuteWithAdjointAndControlledAPQ(paulis : Pauli[], op : ((Pauli[],Qubit[]) => Unit is Adj + Ctl)) : Unit {
        Microsoft.Quantum.Intrinsic.Message($"Checking for Pauli: {paulis}.");
        ExecuteWithAdjointAndControlledAQ(Length(paulis), op(paulis,_));
    }

    operation ExecuteWithAdjointAndControlledAPQ(op : ((Pauli[],Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (numQubits in 1 .. MaxTargets()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking with {numQubits} qubits.");
            IterateThroughCartesianPowerP(numQubits, PaulisToTest(), _ExecuteWithAdjointAndControlledAPQ(_, op));
        }
    }

    operation ExecuteWithAdjointAndControlledPADQA(op : ((Pauli[],Double,Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (angle in AnglesToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking angle {angle}");
            ExecuteWithAdjointAndControlledAPQ(op(_,angle,_));
        }
    }

    operation ExecuteWithAdjointAndControlledPAIIQA(op : ((Pauli[],Int,Int,Qubit[]) => Unit is Adj + Ctl)) : Unit {
        for (fraction in FractionsToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking fraction {fraction}");
            let (numerator, denominatorPower) = fraction;
            ExecuteWithAdjointAndControlledAPQ(op(_,numerator,denominatorPower,_));
        }
    }

    operation ExecuteWithAdjointAndControlledDQ(op : ((Double, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (angle in AnglesToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking angle {angle}");
            ExecuteWithAdjointAndControlledQ(op(angle,_));
        }
    }

    operation ExecuteWithAdjointAndControlledPDQ(op : ((Pauli, Double, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (pauli in PaulisToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking Pauli: {pauli}");
            ExecuteWithAdjointAndControlledDQ(op(pauli, _,_));
        }
    }

    operation ExecuteWithAdjointAndControlledIIQ(op : ((Int, Int, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (fraction in FractionsToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking fraction {fraction}");
            let (numerator, denominatorPower) = fraction;
            ExecuteWithAdjointAndControlledQ(op(numerator,denominatorPower,_));
        }
    }

    operation ExecuteWithAdjointAndControlledPIIQ(op : ((Pauli, Int, Int, Qubit) => Unit is Adj + Ctl)) : Unit {
        for (pauli in PaulisToTest()) {
            Microsoft.Quantum.Intrinsic.Message($"Checking Pauli: {pauli}");
            ExecuteWithAdjointAndControlledIIQ(op(pauli, _,_,_));
        }
    }

    operation ExecuteWithAdjointAndControlledQQ(op : ((Qubit,Qubit) => Unit is Adj + Ctl)) : Unit {
        ExecuteWithAdjointAndControlled(op, ArrayAsTupleAIOO<Qubit>, 2);
    }

    operation ExecuteWithAdjointAndControlledQQQ(op : ((Qubit,Qubit,Qubit) => Unit is Adj + Ctl)) : Unit {
        ExecuteWithAdjointAndControlled(op, ArrayAsTupleAIOOO<Qubit>, 3);
    }
}