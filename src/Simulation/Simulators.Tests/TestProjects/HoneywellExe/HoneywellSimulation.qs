// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.Honeywell {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Simulation.Testing.Honeywell.ClassicallyControlledSupportTests;
    open Microsoft.Quantum.Simulation.Testing.Honeywell.MeasurementSupportTests;

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation MeasureInMiddleTest() : Unit {
        MeasureInMiddle();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation QubitAfterMeasurementTest() : Unit {
        QubitAfterMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation BranchOnMeasurementTest() : Unit {
        BranchOnMeasurement();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation BasicLiftTest() : Unit {
        BasicLift();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftLoopsTest() : Unit {
        LiftLoops();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftSingleNonCallTest() : Unit {
        LiftSingleNonCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftSelfContainedMutableTest() : Unit {
        LiftSelfContainedMutable();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ArgumentsPartiallyResolveTypeParametersTest() : Unit {
        ArgumentsPartiallyResolveTypeParameters();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftFunctorApplicationTest() : Unit {
        LiftFunctorApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftPartialApplicationTest() : Unit {
        LiftPartialApplication();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftArrayItemCallTest() : Unit {
        LiftArrayItemCall();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiftOneNotBothTest() : Unit {
        LiftOneNotBoth();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyIfZeroTest() : Unit {
        ApplyIfZero_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyIfOneTest() : Unit {
        ApplyIfOne_Test();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyIfZeroElseOneTest() : Unit {
        ApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyIfOneElseZeroTest() : Unit {
        ApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation IfElifTest() : Unit {
        IfElif();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation AndConditionTest() : Unit {
        AndCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation OrConditionTest() : Unit {
        OrCondition();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyConditionallyTest() : Unit {
        ApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ApplyConditionallyWithNoOpTest() : Unit {
        ApplyConditionallyWithNoOp();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation InequalityWithApplyConditionallyTest() : Unit {
        InequalityWithApplyConditionally();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation InequalityWithApplyIfOneElseZeroTest() : Unit {
        InequalityWithApplyIfOneElseZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation InequalityWithApplyIfZeroElseOneTest() : Unit {
        InequalityWithApplyIfZeroElseOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation InequalityWithApplyIfOneTest() : Unit {
        InequalityWithApplyIfOne();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation InequalityWithApplyIfZeroTest() : Unit {
        InequalityWithApplyIfZero();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation LiteralOnTheLeftTest() : Unit {
        LiteralOnTheLeft();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation GenericsSupportTest() : Unit {
        GenericsSupport<Int, Int, Int>();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation WithinBlockSupportTest() : Unit {
        WithinBlockSupport();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation AdjointSupportProvidedTest() : Unit {
        AdjointSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation AdjointSupportSelfTest() : Unit {
        AdjointSupportSelf();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation AdjointSupportInvertTest() : Unit {
        AdjointSupportInvert();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledSupportProvidedTest() : Unit {
        ControlledSupportProvided();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledSupportDistributeTest() : Unit {
        ControlledSupportDistribute();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportProvided_ProvidedBodyTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportProvided_ProvidedAdjointTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportProvided_ProvidedControlledTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportProvided_ProvidedAllTest() : Unit {
        ControlledAdjointSupportProvided_ProvidedAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportDistribute_DistributeBodyTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportDistribute_DistributeAdjointTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportDistribute_DistributeControlledTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportDistribute_DistributeAllTest() : Unit {
        ControlledAdjointSupportDistribute_DistributeAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportInvert_InvertBodyTest() : Unit {
        ControlledAdjointSupportInvert_InvertBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportInvert_InvertAdjointTest() : Unit {
        ControlledAdjointSupportInvert_InvertAdjoint();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportInvert_InvertControlledTest() : Unit {
        ControlledAdjointSupportInvert_InvertControlled();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportInvert_InvertAllTest() : Unit {
        ControlledAdjointSupportInvert_InvertAll();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportSelf_SelfBodyTest() : Unit {
        ControlledAdjointSupportSelf_SelfBody();
    }

    @Test("QuantumSimulator")
    @Test("ResourcesEstimator")
    @Test("Microsoft.Quantum.Simulation.Simulators.SparseSimulator2")
    operation ControlledAdjointSupportSelf_SelfControlledTest() : Unit {
        ControlledAdjointSupportSelf_SelfControlled();
    }

}
