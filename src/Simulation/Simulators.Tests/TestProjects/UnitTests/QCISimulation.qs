// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.QCI {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.QCI.ClassicallyControlledSupportTests;
    open Microsoft.Quantum.Simulation.Testing.QCI.MeasurementSupportTests;
    
    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }
    
    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation BranchOnMeasurementTest() : Unit {
        BranchOnMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation BasicLiftTest() : Unit {
        BasicLift();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftLoopsTest() : Unit {
        LiftLoops();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftSingleNonCallTest() : Unit {
        LiftSingleNonCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation DontLiftReturnStatementsTest() : Unit {
        DontLiftReturnStatements();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation DontLiftFunctionsTest() : Unit {
        DontLiftFunctions();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftSelfContainedMutableTest() : Unit {
        LiftSelfContainedMutable();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation DontLiftGeneralMutableTest() : Unit {
        DontLiftGeneralMutable();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ArgumentsPartiallyResolveTypeParametersTest() : Unit {
        ArgumentsPartiallyResolveTypeParameters();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftFunctorApplicationTest() : Unit {
        LiftFunctorApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftPartialApplicationTest() : Unit {
        LiftPartialApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftArrayItemCallTest() : Unit {
        LiftArrayItemCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiftOneNotBothTest() : Unit {
        LiftOneNotBoth();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation IfInvalidTest() : Unit {
        IfInvalid();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ElseInvalidTest() : Unit {
        ElseInvalid();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation BothInvalidTest() : Unit {
        BothInvalid();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyIfZeroTest() : Unit {
        ApplyIfZero_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyIfOneTest() : Unit {
        ApplyIfOne_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyIfZeroElseOneTest() : Unit {
        ApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyIfOneElseZeroTest() : Unit {
        ApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation IfElifTest() : Unit {
        IfElif();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation AndConditionTest() : Unit {
        AndCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation OrConditionTest() : Unit {
        OrCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyConditionallyTest() : Unit {
        ApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ApplyConditionallyWithNoOpTest() : Unit {
        ApplyConditionallyWithNoOp();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation InequalityWithApplyConditionallyTest() : Unit {
        InequalityWithApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation InequalityWithApplyIfOneElseZeroTest() : Unit {
        InequalityWithApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation InequalityWithApplyIfZeroElseOneTest() : Unit {
        InequalityWithApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation InequalityWithApplyIfOneTest() : Unit {
        InequalityWithApplyIfOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation InequalityWithApplyIfZeroTest() : Unit {
        InequalityWithApplyIfZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation LiteralOnTheLeftTest() : Unit {
        LiteralOnTheLeft();
    }

    //@Test("QuantumSimulator")
    //@Test("ResourcesEstimator")
    //operation GenericsSupportTest() : Unit {
    //    GenericsSupport<Int, Int, Int>();
    //}

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation WithinBlockSupportTest() : Unit {
        WithinBlockSupport();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation AdjointSupportProvidedTest() : Unit {
        AdjointSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation AdjointSupportSelfTest() : Unit {
        AdjointSupportSelf();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation AdjointSupportInvertTest() : Unit {
        AdjointSupportInvert();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledSupportProvidedTest() : Unit {
        ControlledSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledSupportDistributeTest() : Unit {
        ControlledSupportDistribute();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportProvided_ProvidedBodyTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportProvided_ProvidedAdjointTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportProvided_ProvidedControlledTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportProvided_ProvidedAllTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportDistribute_DistributeBodyTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportDistribute_DistributeAdjointTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportDistribute_DistributeControlledTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportDistribute_DistributeAllTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportInvert_InvertBodyTest() : Unit {
        ControlledAdjointSupportInvert_InvertBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportInvert_InvertAdjointTest() : Unit {
        ControlledAdjointSupportInvert_InvertAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportInvert_InvertControlledTest() : Unit {
        ControlledAdjointSupportInvert_InvertControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportInvert_InvertAllTest() : Unit {
        ControlledAdjointSupportInvert_InvertAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportSelf_SelfBodyTest() : Unit {
        ControlledAdjointSupportSelf_SelfBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    operation ControlledAdjointSupportSelf_SelfControlledTest() : Unit {
        ControlledAdjointSupportSelf_SelfControlled();
    }

}
