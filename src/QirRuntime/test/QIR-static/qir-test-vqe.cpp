// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Implement vqe.qs so can compare the results of running it and the generated QIR against the full state
// simulator.
#include <bitset>
#include <iostream>
#include <vector>

#include "CoreTypes.hpp"
#include "quantum__qis.hpp"
#include "quantum__rt.hpp"
#include "qirTypes.hpp"

using namespace std;
using namespace Microsoft::Quantum;

extern "C"
{
    extern Result ResultOne;
    extern Result ResultZero;
}

double EstimateTermExpectation(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    int cOps,
    int8_t* ops,
    double coeff,
    int nSamples);

double EstimateFrequency(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    int cOps,
    int8_t* ops,
    int nSamples);

void PrepareTrialState(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    QirArray* qs,
    QirArray* aux);

/*
@EntryPoint()
operation EstimateTermExpectation(
    state1: Int[], state2 : Int[], phase : Double, ops : Pauli[], coeff : Double, nSamples : Int)
    : Double
{
    mutable jwTermEnergy = 0.;

    // Compute expectation value using the fast frequency estimator, add contribution to Jordan-Wigner term energy
    let termExpectation = EstimateFrequency (state1, state2, phase, ops, nSamples);
    set jwTermEnergy += (2.*termExpectation - 1.) * coeff;

    return jwTermEnergy;
}
*/
double EstimateTermExpectation(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    int cOps,
    int8_t* ops,
    double coeff,
    int nSamples)
{
    const double termExpectation =
        EstimateFrequency(cState1, state1, cState2, state2, phase, cOps, ops, nSamples);
    return (2. * termExpectation - 1.) * coeff;
}

/*
operation EstimateFrequency
    (state1: Int[], state2 : Int[], phase : Double, measurementOps : Pauli[],  nTrials : Int)
    : Double
{
    mutable nUp = 0; let nQubits = Length(measurementOps);

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
*/
double EstimateFrequency(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    int cOps,
    int8_t* ops,
    int nSamples)
{
    int nUp = 0;

    for (int idxMeasurement = 0; idxMeasurement < nSamples; idxMeasurement++)
    {
        QirArray* qs = quantum__rt__qubit_allocate_array(cOps);
        QirArray* aux = quantum__rt__qubit_allocate_array(cOps);

        QirArray* opsArray = quantum__rt__array_create_1d(sizeof(int8_t), cOps);
        opsArray->buffer = reinterpret_cast<char*>(ops);

        PrepareTrialState(cState1, state1, cState2, state2, phase, qs, aux);

        Result result = quantum__qis__measure(opsArray, qs);
        if (quantum__rt__result_equal(result, ResultZero))
        {
            nUp++;
        }

        for (int i = 0; i < cOps; i++)
        {
            Qubit q = qs->GetQubit(i);
            if (quantum__rt__result_equal(quantum__qis__mz(q), ResultOne))
            {
                quantum__qis__x(q);
            }
        }

        quantum__rt__qubit_release_array(qs);
        quantum__rt__qubit_release_array(aux);
    }
    return quantum__qis__intAsDouble(nUp) / quantum__qis__intAsDouble(nSamples);
}

/*
// Preps a simple trial state as an equal mix of two states parameterized by a given phase
operation PrepareTrialState(
    state1 : Int[], state2 : Int[], phase : Double, qubits : Qubit[], aux : Qubit[])
    : Unit
{
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
*/
void PrepareTrialState(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    QirArray* qs,
    QirArray* aux)
{
    Qubit aux0 = aux->GetQubit(0);
    Qubit aux1 = aux->GetQubit(1);

    quantum__qis__h(aux0);
    quantum__qis__rz(phase, aux0);
    quantum__qis__cnot(aux0, aux1);

    quantum__qis__x(aux0);
    quantum__qis__x(aux1);
    for (int i = 0; i < cState1; i++)
    {
        quantum__qis__x(qs->GetQubit(state1[i]));
    }
    quantum__qis__x(aux1);
    quantum__qis__x(aux0);

    for (int i = 0; i < cState2; i++)
    {
        quantum__qis__x(qs->GetQubit(state2[i]));
    }

    if (quantum__rt__result_equal(quantum__qis__mz(aux0), ResultOne))
    {
        quantum__qis__x(aux0);
    }
    if (quantum__rt__result_equal(quantum__qis__mz(aux1), ResultOne))
    {
        quantum__qis__x(aux1);
    }
}