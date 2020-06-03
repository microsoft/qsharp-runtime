namespace Type2.Decompositions.Tests {

    function Type2Decompositions() : IntrinsicTesting.UnitaryQSharpIntrinsics {
        return IntrinsicTesting.UnitaryQSharpIntrinsics(
            Test.Decompositions.X,
            Test.Decompositions.Y,
            Test.Decompositions.Z,
            Test.Decompositions.H,
            Test.Decompositions.S,
            Test.Decompositions.T,
            Test.Decompositions.CNOT,
            Test.Decompositions.CCNOT,
            Test.Decompositions.SWAP,
            Test.Decompositions.R,
            Test.Decompositions.RFrac,
            Test.Decompositions.Rx,
            Test.Decompositions.Ry,
            Test.Decompositions.Rz,
            Test.Decompositions.R1,
            Test.Decompositions.R1Frac,
            Test.Decompositions.Exp,
            Test.Decompositions.ExpFrac);
    }

    @Microsoft.Quantum.Diagnostics.Test("Test.Decompositions.Type2Simulator")
    operation UnitaryIntrinsicTest() : Unit {
        let standardIntrinsic = IntrinsicTesting.StandardIntrinsics();
        let decompositions = Type2Decompositions();
        IntrinsicTesting.TestInstrinsics(decompositions, standardIntrinsic);
    }

    // For running against Type2Processor simulator.
    // Here the meaning of oracle and test target switch places: Type2 decompositions
    // from this project become the reference, while the standard intrinsics implemented
    // by the Type2Processor become the test target.
    operation BasicGates_Decompostion() : Unit {
        IntrinsicTesting.ExecuteBasicInstrinsics(IntrinsicTesting.StandardIntrinsics());
    }
    operation BasicGates_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteBasicInstrinsics(Type2Decompositions());
    }
    operation SWAPandCNOT_Decompostion() : Unit {
        IntrinsicTesting.ExecuteSWAPandCNOT(IntrinsicTesting.StandardIntrinsics());
    }
    operation SWAPandCNOT_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteSWAPandCNOT(Type2Decompositions());
    }
    operation Rotations_Decompostion() : Unit {
        IntrinsicTesting.ExecuteSWAPandCNOT(IntrinsicTesting.StandardIntrinsics());
    }
    operation Rotations_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteSWAPandCNOT(Type2Decompositions());
    }
    operation CCNOT_Decompostion() : Unit {
        IntrinsicTesting.ExecuteCCNOT(IntrinsicTesting.StandardIntrinsics());
    }
    operation CCNOT_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteCCNOT(Type2Decompositions());
    }
    operation R_Decompostion() : Unit {
        IntrinsicTesting.ExecuteR(IntrinsicTesting.StandardIntrinsics());
    }
    operation R_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteR(Type2Decompositions());
    }
    operation R1Frac_Decompostion() : Unit {
        IntrinsicTesting.ExecuteR1Frac(IntrinsicTesting.StandardIntrinsics());
    }
    operation R1Frac_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteR1Frac(Type2Decompositions());
    }
    operation RFrac_Decompostion() : Unit {
        IntrinsicTesting.ExecuteRFrac(IntrinsicTesting.StandardIntrinsics());
    }
    operation RFrac_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteRFrac(Type2Decompositions());
    }
    operation Exp_Decompostion() : Unit {
        IntrinsicTesting.ExecuteExp(IntrinsicTesting.StandardIntrinsics());
    }
    operation Exp_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteExp(Type2Decompositions());
    }
    operation ExpFrac_Decompostion() : Unit {
        IntrinsicTesting.ExecuteExpFrac(IntrinsicTesting.StandardIntrinsics());
    }
    operation ExpFrac_Decomposition_Type2Reference() : Unit {
        IntrinsicTesting.ExecuteExpFrac(Type2Decompositions());
    }
}