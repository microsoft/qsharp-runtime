// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{    
    open Microsoft.Quantum.Intrinsic;    

    operation OneBitPrecisionEigenvalue (U : (Qubit => Unit is Adj + Ctl), P : (Qubit => Unit is Adj))
    : Bool {

        using ((control, eigenstate) = (Qubit(), Qubit())) {
            P(eigenstate);

            mutable (measuredZero, measuredOne) = (false, false); 
            mutable iter = 0;
            repeat {
                set iter += 1;

                H(control);
                Controlled U([control], eigenstate);
                H(control);

                let meas = M(control);
                if (meas == One) { X(control); }
                set (measuredZero, measuredOne) = (measuredZero or meas == Zero, measuredOne or meas == One);
            } 
            until (iter == 20 or measuredZero and measuredOne);

            Reset(eigenstate);
            return not measuredZero or not measuredOne;
        }

    }

    // testing

    operation RepeatUntilSuccessTest () : Unit {
        let evZ = OneBitPrecisionEigenvalue(Z,X);
        let evS = OneBitPrecisionEigenvalue(S,X);
        let evX = OneBitPrecisionEigenvalue(X,H);
        if (not evZ or not evX or evS) {
            fail "wrong result";		
        }
    }

}