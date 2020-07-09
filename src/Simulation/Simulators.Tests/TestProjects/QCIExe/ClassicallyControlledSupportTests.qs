// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Simulation.Testing.QCI.ClassicallyControlledSupportTests {

    open Microsoft.Quantum.Intrinsic;

    operation SubOp1() : Unit { }
    operation SubOp2() : Unit { }
    operation SubOp3() : Unit { }

    operation SubOpCA1() : Unit is Ctl + Adj { }
    operation SubOpCA2() : Unit is Ctl + Adj { }
    operation SubOpCA3() : Unit is Ctl + Adj { }
    
    operation BranchOnMeasurement() : Unit {
        using (q = Qubit()) {
            H(q);
            let r = M(q);
            if (r == Zero) {
                SubOp1();
            }
            Reset(q);
        }
    }
    
    operation BasicLift() : Unit {
        let r = Zero;
        if (r == Zero) {
            SubOp1();
            SubOp2();
            SubOp3();
            let temp = 4;
            using (q = Qubit()) {
                let temp2 = q;
            }
        }
    }

    operation LiftLoops() : Unit {
        let r = Zero;
        if (r == Zero) {
            for (index in 0 .. 3) {
                let temp = index;
            }

            repeat {
                let success = true;
            } until (success)
            fixup {
                let temp2 = 0;
            }
        }
    }
    
    operation LiftSingleNonCall() : Unit {
        let r = Zero;
        if (r == Zero) {
            let temp = 2;
        }
    }

    operation LiftSelfContainedMutable() : Unit {
        let r = Zero;
        if (r == Zero) {
            mutable temp = 3;
            set temp = 4;
        }
    }

    operation PartiallyResolved<'Q, 'W> (q : 'Q, w : 'W) : Unit { }

    operation ArgumentsPartiallyResolveTypeParameters() : Unit {
        let r = Zero;
        if (r == Zero) {
            PartiallyResolved<Int, _>(1, 1.0);
        }
    }

    operation LiftFunctorApplication() : Unit {
        let r = Zero;
        if (r == Zero) {
            Adjoint SubOpCA1();
        }
    }

    operation PartialApplication(q : Int, w : Double) : Unit { }

    operation LiftPartialApplication() : Unit {
        let r = Zero;
        if (r == Zero) {
            (PartialApplication(1, _))(1.0);
        }
    }

    operation LiftArrayItemCall() : Unit {
        let f = [SubOp1];
        let r = Zero;
        if (r == Zero) {
            f[0]();
        }
    }

    operation LiftOneNotBoth() : Unit {
        let r = Zero;
        if (r == Zero) {
            SubOp1();
            SubOp2();
        }
        else {
            SubOp3();
        }
    }
    
    operation ApplyIfZero_Test() : Unit {
        let r = Zero;
        if (r == Zero) {
            SubOp1();
        }
    }

    operation ApplyIfOne_Test() : Unit {
        let r = Zero;
        if (r == One) {
            SubOp1();
        }
    }

    operation ApplyIfZeroElseOne() : Unit {
        let r = Zero;
        if (r == Zero) {
            SubOp1();
        } else {
            SubOp2();
        }
    }

    operation ApplyIfOneElseZero() : Unit {
        let r = Zero;
        if (r == One) {
            SubOp1();
        } else {
            SubOp2();
        }
    }

    operation IfElif() : Unit {
        let r = Zero;

        if (r == Zero) {
            SubOp1();
        } elif (r == One) {
            SubOp2();
        } else {
            SubOp3();
        }
    }

    operation AndCondition() : Unit {
        let r = Zero;
        if (r == Zero and r == One) {
            SubOp1();
        } else {
            SubOp2();
        }
    }

    operation OrCondition() : Unit {
        let r = Zero;
        if (r == Zero or r == One) {
            SubOp1();
        } else {
            SubOp2();
        }
    }

    operation ApplyConditionally() : Unit {
        let r1 = Zero;
        let r2 = Zero;
        if (r1 == r2) {
            SubOp1();
        }
        else {
            SubOp2();
        }
    }

    operation ApplyConditionallyWithNoOp() : Unit {
        let r1 = Zero;
        let r2 = Zero;
        if (r1 == r2) {
            SubOp1();
        }
    }

    operation InequalityWithApplyConditionally() : Unit {
        let r1 = Zero;
        let r2 = Zero;
        if (r1 != r2) {
            SubOp1();
        }
        else {
            SubOp2();
        }
    }

    operation InequalityWithApplyIfOneElseZero() : Unit {
        let r = Zero;
        if (r != Zero) {
            SubOp1();
        }
        else {
            SubOp2();
        }
    }

    operation InequalityWithApplyIfZeroElseOne() : Unit {
        let r = Zero;
        if (r != One) {
            SubOp1();
        }
        else {
            SubOp2();
        }
    }

    operation InequalityWithApplyIfOne() : Unit {
        let r = Zero;
        if (r != Zero) {
            SubOp1();
        }
    }

    operation InequalityWithApplyIfZero() : Unit {
        let r = Zero;
        if (r != One) {
            SubOp1();
        }
    }

    operation LiteralOnTheLeft() : Unit {
        let r = Zero;
        if (Zero == r) {
            SubOp1();
        }
    }

    operation GenericsSupport<'A, 'B, 'C>() : Unit {
        let r = Zero;
    
        if (r == Zero) {
            SubOp1();
            SubOp2();
        }
    }

    operation WithinBlockSupport() : Unit {
        let r = One;
        within {
            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        } apply {
            if (r == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation AdjointSupportProvided() : Unit is Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint (...) {
            let w = One;

            if (w == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation AdjointSupportSelf() : Unit is Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint self;
    }

    operation AdjointSupportInvert() : Unit is Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint invert;
    }

    operation ControlledSupportProvided() : Unit is Ctl {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation ControlledSupportDistribute() : Unit is Ctl {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled distribute;
    }

    operation ControlledAdjointSupportProvided_ProvidedBody() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled adjoint (ctl, ...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation ControlledAdjointSupportProvided_ProvidedAdjoint() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint (...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint (ctl, ...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation ControlledAdjointSupportProvided_ProvidedControlled() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint (ctl, ...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }
    }

    operation ControlledAdjointSupportProvided_ProvidedAll() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        adjoint (...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }

        controlled adjoint (ctl, ...) {
            let b = One;

            if (b == One) {
                let temp1 = 0;
                let temp2 = 0;
                SubOpCA3();
            }
        }
    }

    operation ControlledAdjointSupportDistribute_DistributeBody() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled adjoint distribute;
    }

    operation ControlledAdjointSupportDistribute_DistributeAdjoint() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint (...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint distribute;
    }

    operation ControlledAdjointSupportDistribute_DistributeControlled() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint distribute;
    }

    operation ControlledAdjointSupportDistribute_DistributeAll() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        adjoint (...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }

        controlled adjoint distribute;
    }

    operation ControlledAdjointSupportInvert_InvertBody() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled adjoint invert;
    }

    operation ControlledAdjointSupportInvert_InvertAdjoint() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        adjoint (...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint invert;
    }

    operation ControlledAdjointSupportInvert_InvertControlled() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint invert;
    }

    operation ControlledAdjointSupportInvert_InvertAll() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        adjoint (...) {
            let y = One;

            if (y == One) {
                SubOpCA2();
                SubOpCA3();
            }
        }

        controlled adjoint invert;
    }

    operation ControlledAdjointSupportSelf_SelfBody() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled adjoint self;
    }

    operation ControlledAdjointSupportSelf_SelfControlled() : Unit is Ctl + Adj {
        body (...) {
            let r = Zero;

            if (r == Zero) {
                SubOpCA1();
                SubOpCA2();
            }
        }

        controlled (ctl, ...) {
            let w = One;

            if (w == One) {
                SubOpCA3();
                SubOpCA1();
            }
        }

        controlled adjoint self;
    }
}