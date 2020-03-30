namespace Microsoft.Quantum.Targeting.Decompositions.Utilities.Circuit {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Targeting.Decompositions.Utilities as Utils;

    /// Applies a unitary operation such that
    /// `SpreadZ(...); Exp([PauliZ],theta,[from]) ; Adjoint SpreadZ(...);` is equivalent to `Exp([PauliZ,..,PauliZ],theta,[from] + to)`
    internal operation SpreadZ(from : Qubit, to : Qubit[]) : Unit is Adj {
        if (Length(to) > 0) {
            CNOT(to[0], from);
            if (Length(to) > 1) {
                let half = Length(to) / 2;
                SpreadZ(to[0], to[half + 1 .. Length(to) - 1]);
                SpreadZ(from, to[1 .. half]);
            }
        }
    }

    /// Applies a unitary operation such that
    /// `MapPauli(...); R(from,...) ; Adjoint MapPauli(...);` is equivalent to `R(to,...)`
    internal operation MapPauli(qubit : Qubit, from : Pauli, to : Pauli) : Unit is Adj {
        if (from == to) {
        }
        elif ((from == PauliZ and to == PauliX) or (from == PauliX and to == PauliZ)) {
            H(qubit);
        }
        elif (from == PauliZ and to == PauliY) {
            H(qubit);
            S(qubit);
            H(qubit);
        }
        elif (from == PauliY and to == PauliZ) {
            H(qubit);
            Adjoint S(qubit);
            H(qubit);
        }
        elif (from == PauliY and to == PauliX) {
            S(qubit);
        }
        elif (from == PauliX and to == PauliY) {
            Adjoint S(qubit);
        }
        else {
            fail "Unsupported input";
        }
    }

    /// Given a multiply-controlled operation that requires k controls 
    /// applies it using ceiling(k/2) controls and using floor(k/2) temporary qubits
    /// almostCCX(c1,c2,t); U(c1,c2) must be equivalent to CCX(c1,c2,t) for some two-qubit unitary operation U(c1,c2) given target qubit starts 
    /// in zero state, ( for Adjoint it is asserted that target qubit is returned to zero state)
    internal operation ApplyWithLessControlsA<'T>(op : ((Qubit[],'T) => Unit is Adj), (controls : Qubit[], arg : 'T), almostCCX : ((Qubit,Qubit,Qubit) => Unit is Adj)) : Unit is Adj {
        let numControls = Length(controls);
        let numControlPairs = numControls / 2;
        using (temps = Qubit[numControlPairs]) {
            within {
                for (numPair in 0 .. numControlPairs - 1) { // constant depth
                    almostCCX(controls[2*numPair], controls[2*numPair + 1], temps[numPair]);
                }
            } apply {
                let newControls = numControls % 2 == 0 ? temps | temps + [controls[numControls - 1]];
                op(newControls, arg);
            }
        }
    }

    /// almostCCX(c1,c2,t); U(c1,c2) must be equivalent to CCX(c1,c2,t) for some two-qubit unitary operation U(c1,c2) given target qubit starts 
    /// in zero state, ( for Adjoint it is asserted that target qubit is returned to zero state)
    internal operation ApplyUsingSinglyControlledVersion<'T>(op : ('T => Unit is Adj), controlledOp : ((Qubit,'T) => Unit is Adj), arg : 'T , almostCCX : ((Qubit,Qubit,Qubit) => Unit is Adj)) : Unit is Adj + Ctl {
        body(...) {
            op(arg);
        }
        controlled(ctrls, ...) {
            let numControls = Length(ctrls);
            if (numControls == 0) { op(arg); }
            elif (numControls == 1) { controlledOp(ctrls[0], arg); }
            else {
                let inner = ApplyUsingSinglyControlledVersion(op, controlledOp, _, almostCCX);
                ApplyWithLessControlsA(Controlled inner, (ctrls, arg), almostCCX);
            }
        }
    }

    internal operation DispatchR1Frac(numerator : Int, power : Int, qubit : Qubit) : Unit is Adj + Ctl {
        if (power >= 0 ) { // when power is negative the operations is (1,exp(i pi*2^|n|*k)) and exp(i pi*2^|n|*k) = 1
            let (kModPositive,n) = Utils.ReducedDyadicFractionPeriodic(numerator,power); // k is odd, or (k,n) are both 0
            if (n == 0) { // kModPositive is 0,1
                if (kModPositive == 1) { Z(qubit); }
                elif (kModPositive == 0) {}
                else { fail "Something went wrong. This should be unreachable"; }
            } 
            elif (n == 1) { // period is 4, kModPositive is 1,3
                if (kModPositive == 1) { S(qubit); }
                elif (kModPositive == 3) { Adjoint S(qubit); }
                else { fail "Something went wrong. This should be unreachable"; }
            }
            elif (n == 2) { // period is 8, kModPositive is 1,3,5,7
                if (kModPositive == 1) { T(qubit); }
                elif (kModPositive == 3) { TS(qubit); }
                elif (kModPositive == 5) { Adjoint TS(qubit); }
                elif (kModPositive == 7) { Adjoint T(qubit); }
                else { fail "Something went wrong. This should be unreachable"; }
            }
            else {
                let phi = Utils.DyadicFractionAsDouble(kModPositive, n);
                R1(phi,qubit);
            }
        }
    }

    internal operation ApplyGlobalPhaseWithR1(theta : Double) : Unit is Adj + Ctl {
        body(...) {}
        controlled(ctrls, ... ) {
            let numControls =  Length(ctrls);
            if (numControls > 0) {
                Controlled R1(ctrls[1 .. numControls - 1], (theta, ctrls[0]));
            }
        }
    }

    internal operation ApplyGlobalPhaseFracWithR1Frac(numerator : Int, power : Int) : Unit is Adj + Ctl {
        body(...) {}
        controlled(ctrls, ... ) {
            let numControls =  Length(ctrls);
            if (numControls > 0 ) {
                Controlled R1Frac(ctrls[1 .. numControls - 1], (numerator, power, ctrls[0]));
            }
        }
    }

}