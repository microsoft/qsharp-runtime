// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.QCI {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.QCI.ClassicallyControlledSupportTests;
    open Microsoft.Quantum.Simulation.Testing.QCI.MeasurementSupportTests;

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation BranchOnMeasurementTest() : Unit {
        BranchOnMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation BasicLiftTest() : Unit {
        BasicLift();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftLoopsTest() : Unit {
        LiftLoops();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftSingleNonCallTest() : Unit {
        LiftSingleNonCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftSelfContainedMutableTest() : Unit {
        LiftSelfContainedMutable();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ArgumentsPartiallyResolveTypeParametersTest() : Unit {
        ArgumentsPartiallyResolveTypeParameters();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftFunctorApplicationTest() : Unit {
        LiftFunctorApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftPartialApplicationTest() : Unit {
        LiftPartialApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftArrayItemCallTest() : Unit {
        LiftArrayItemCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiftOneNotBothTest() : Unit {
        LiftOneNotBoth();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyIfZeroTest() : Unit {
        ApplyIfZero_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyIfOneTest() : Unit {
        ApplyIfOne_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyIfZeroElseOneTest() : Unit {
        ApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyIfOneElseZeroTest() : Unit {
        ApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation IfElifTest() : Unit {
        IfElif();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation AndConditionTest() : Unit {
        AndCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation OrConditionTest() : Unit {
        OrCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyConditionallyTest() : Unit {
        ApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ApplyConditionallyWithNoOpTest() : Unit {
        ApplyConditionallyWithNoOp();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation InequalityWithApplyConditionallyTest() : Unit {
        InequalityWithApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation InequalityWithApplyIfOneElseZeroTest() : Unit {
        InequalityWithApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation InequalityWithApplyIfZeroElseOneTest() : Unit {
        InequalityWithApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation InequalityWithApplyIfOneTest() : Unit {
        InequalityWithApplyIfOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation InequalityWithApplyIfZeroTest() : Unit {
        InequalityWithApplyIfZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation LiteralOnTheLeftTest() : Unit {
        LiteralOnTheLeft();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation GenericsSupportTest() : Unit {
        GenericsSupport<Int, Int, Int>();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation WithinBlockSupportTest() : Unit {
        WithinBlockSupport();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation AdjointSupportProvidedTest() : Unit {
        AdjointSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation AdjointSupportSelfTest() : Unit {
        AdjointSupportSelf();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation AdjointSupportInvertTest() : Unit {
        AdjointSupportInvert();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledSupportProvidedTest() : Unit {
        ControlledSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledSupportDistributeTest() : Unit {
        ControlledSupportDistribute();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportProvided_ProvidedBodyTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportProvided_ProvidedAdjointTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportProvided_ProvidedControlledTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportProvided_ProvidedAllTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportDistribute_DistributeBodyTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportDistribute_DistributeAdjointTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportDistribute_DistributeControlledTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportDistribute_DistributeAllTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportInvert_InvertBodyTest() : Unit {
        ControlledAdjointSupportInvert_InvertBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportInvert_InvertAdjointTest() : Unit {
        ControlledAdjointSupportInvert_InvertAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportInvert_InvertControlledTest() : Unit {
        ControlledAdjointSupportInvert_InvertControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportInvert_InvertAllTest() : Unit {
        ControlledAdjointSupportInvert_InvertAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportSelf_SelfBodyTest() : Unit {
        ControlledAdjointSupportSelf_SelfBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("SparseSimulator")
    operation ControlledAdjointSupportSelf_SelfControlledTest() : Unit {
        ControlledAdjointSupportSelf_SelfControlled();
    }

}
