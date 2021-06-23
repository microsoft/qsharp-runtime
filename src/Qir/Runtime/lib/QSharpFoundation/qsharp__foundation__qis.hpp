#pragma once

#include <cstdint>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

struct QirArray;
struct QirCallable;

/*
    Methods from __quantum__qis namespace are specific to the target. When QIR is generated it might limit or extend
    the set of intrinsics, supported by the target (known to QIR generator at compile time). As part of the runtime
    we provide _optional_ implementation of the common intrinsics that redirects to IQuantumGateSet.
*/
extern "C"
{
    // Q# Math:
    QIR_SHARED_API bool quantum__qis__isnan__body(double d);               // NOLINT
    QIR_SHARED_API double quantum__qis__infinity__body();                  // NOLINT
    QIR_SHARED_API bool quantum__qis__isinf__body(double d);               // NOLINT
    QIR_SHARED_API double quantum__qis__arctan2__body(double y, double x); // NOLINT
    QIR_SHARED_API double quantum__qis__sinh__body(double theta);          // NOLINT
    QIR_SHARED_API double quantum__qis__cosh__body(double theta);          // NOLINT
    QIR_SHARED_API double quantum__qis__arcsin__body(double theta);        // NOLINT
    QIR_SHARED_API double quantum__qis__arccos__body(double theta);        // NOLINT
    QIR_SHARED_API double quantum__qis__arctan__body(double theta);        // NOLINT

    QIR_SHARED_API double quantum__qis__ieeeremainder__body(double x, double y);                // NOLINT
    QIR_SHARED_API int64_t quantum__qis__drawrandomint__body(int64_t minimum, int64_t maximum); // NOLINT
    QIR_SHARED_API double quantum__qis__drawrandomdouble__body(double minimum, double maximum); // NOLINT

    // Q# ApplyIf:
    QIR_SHARED_API void quantum__qis__applyifelseintrinsic__body(RESULT*, QirCallable*, QirCallable*); // NOLINT
    QIR_SHARED_API void quantum__qis__applyconditionallyintrinsic__body( // NOLINT
        QirArray*,
        QirArray*,
        QirCallable*,
        QirCallable*);

    // Q# Assert Measurement:
    QIR_SHARED_API void quantum__qis__assertmeasurementprobability__body(   // NOLINT
        QirArray* bases, QirArray* qubits, RESULT* result, double prob, QirString* msg, double tol);

} // extern "C"
