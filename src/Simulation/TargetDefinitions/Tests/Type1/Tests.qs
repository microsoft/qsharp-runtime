namespace DecompositionTests.Type1 {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    // These tests validate the Type1 specific decompositions for internal gate application operations.

    @Test("SparseSimulator")
    operation Rzz() : Unit {
        let angle = PI() / 7.0;
        Reference.AssertOperationsEqualReferenced(2, qs => ApplyUncontrolledRzz(angle, qs[0], qs[1]),
            qs => Reference.Rzz(angle, qs[0], qs[1]));
    }

    @Test("SparseSimulator")
    operation Rx() : Unit {
        let angle = PI() / 7.0;
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledRx(angle, qs[0]),
            qs => Reference.R(PauliX, angle, qs[0]));
    }

    @Test("SparseSimulator")
    operation Rz() : Unit {
        let angle = PI() / 7.0;
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledRz(angle, qs[0]),
            qs => Reference.R(PauliZ, angle, qs[0]));
    }

    @Test("SparseSimulator")
    operation CZ() : Unit {
        Reference.AssertOperationsEqualReferenced(2, qs => ApplyControlledZ(qs[0], qs[1]),
            qs => Controlled Reference.Z([qs[0]], qs[1]));
    }

    @Test("SparseSimulator")
    operation CX() : Unit {
        Reference.AssertOperationsEqualReferenced(2, qs => ApplyControlledX(qs[0], qs[1]),
            qs => Controlled Reference.X([qs[0]], qs[1]));
    }

    @Test("SparseSimulator")
    operation H() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledH(qs[0]),
            qs => Reference.H(qs[0]));
    }

    @Test("SparseSimulator")
    operation S() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledS(qs[0]),
            qs => Reference.S(qs[0]));
    }

    @Test("SparseSimulator")
    operation SAdj() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledSAdj(qs[0]),
            qs => Adjoint Reference.S(qs[0]));
    }

    @Test("SparseSimulator")
    operation T() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledT(qs[0]),
            qs => Reference.T(qs[0]));
    }

    @Test("SparseSimulator")
    operation TAdj() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledTAdj(qs[0]),
            qs => Adjoint Reference.T(qs[0]));
    }

    @Test("SparseSimulator")
    operation X() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledX(qs[0]),
            qs => Reference.X(qs[0]));
    }

    @Test("SparseSimulator")
    operation Y() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledY(qs[0]),
            qs => Reference.Y(qs[0]));
    }

    @Test("SparseSimulator")
    operation Z() : Unit {
        Reference.AssertOperationsEqualReferenced(1, qs => ApplyUncontrolledZ(qs[0]),
            qs => Reference.Z(qs[0]));
    }

}