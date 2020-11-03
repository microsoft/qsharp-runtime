// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This is a stripped-down VQE example based on the VQE support in the
// Q# chemistry library.

namespace Sample.VQE
{
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation EstimateTermExpectation(state1: Int[], state2 : Int[], phase : Double, ops : Pauli[], coeff : Double, nSamples : Int) 
    : Double {
        mutable jwTermEnergy = 0.;

        // Compute expectation value using the fast frequency estimator, add contribution to Jordan-Wigner term energy
        let termExpectation = EstimateFrequency (state1, state2, phase, ops, nSamples);
        set jwTermEnergy += (2.*termExpectation - 1.) * coeff;

        return jwTermEnergy;
    }

    operation EstimateFrequency (state1: Int[], state2 : Int[], phase : Double, measurementOps : Pauli[],  nTrials : Int) 
    : Double {
        mutable nUp = 0;
        let nQubits = Length(measurementOps);

        for (idxMeasurement in 0 .. nTrials - 1) {
            using ((register, aux) = (Qubit[nQubits], Qubit[2])) {
                PrepareTrialState(state1, state2, phase, register, aux);
                let result = Measure(measurementOps, register);

                if (result == Zero) {
                    // NB!!!!! This reverses Zero and One to use conventions
                    //         common in the QCVV community. That is confusing
                    //         but is confusing with an actual purpose.
                    set nUp = nUp + 1;
                }

                // NB: We absolutely must reset here, since preparation
                //     can use randomness internally.
                for (r in register)
                {
                    if (Mz(r) == One)
                    {
                        X(r);
                    }
                }
            }
        }

        return IntAsDouble(nUp) / IntAsDouble(nTrials);
    }

    // Preps a simple trial state as an equal mix of two states parameterized by a given phase
    operation PrepareTrialState (state1: Int[], state2 : Int[], phase : Double, qubits : Qubit[], aux : Qubit[]) : Unit {
        H(aux[0]);
        Rz(phase, aux[0]);
        CNOT(aux[0], aux[1]);
        within
        {
            X(aux[0]);
            X(aux[1]);
        }
        apply
        {
            for (n in state1)
            {
                X(qubits[n]);
            }
        }
        for (n in state2)
        {
            X(qubits[n]);
        }
        for (a in aux)
        {
            if (Mz(a) == One)
            {
                X(a);
            }
        }
    }
}