#pragma once

#include <cstdint>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

struct QirArray;
struct QirCallable;

struct QirAssertMeasurementProbabilityTuple
{
    QirArray* bases;
    QirArray* qubits;
    RESULT* result;
    double prob;
    QirString* msg;
    double tol;
};

/*
    Methods from __quantum__qis namespace are specific to the target. When QIR is generated it might limit or extend
    the set of intrinsics, supported by the target (known to QIR generator at compile time). As part of the runtime
    we provide _optional_ implementation of the common intrinsics that redirects to IQuantumGateSet.
*/
extern "C"
{
    // Q# ApplyIf:
    QIR_SHARED_API void __quantum__qis__applyifelseintrinsic__body(RESULT*, QirCallable*, QirCallable*); // NOLINT
    QIR_SHARED_API void __quantum__qis__applyconditionallyintrinsic__body(                               // NOLINT
        QirArray*, QirArray*, QirCallable*, QirCallable*);

    // Q# Assert Measurement:
    QIR_SHARED_API void __quantum__qis__assertmeasurementprobability__body( // NOLINT
        QirArray* bases, QirArray* qubits, RESULT* result, double prob, QirString* msg, double tol);
    QIR_SHARED_API void __quantum__qis__assertmeasurementprobability__ctl( // NOLINT
        QirArray* ctls, QirAssertMeasurementProbabilityTuple* args);

} // extern "C"
