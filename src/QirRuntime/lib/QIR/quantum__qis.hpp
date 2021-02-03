#pragma once

#include <cstdint>

#include "CoreTypes.hpp"

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

struct QirArray;
struct QirCallable;
struct QirString;
struct QirBigInt;

namespace Microsoft
{
namespace Quantum
{
    struct IQuantumGateSet;
}
} // namespace Microsoft

/*
    Methods from __quantum__qis namespace are specific to the target. When QIR is generated it might limit or extend
    the set of intrinsics, supported by the target (known to QIR generator at compile time). As part of the runtime
    we provide _optional_ implementation of the common intrinsics that redirects to IQuantumGateSet.
*/
extern "C"
{
    // Q# Gate Set
    QIR_SHARED_API void quantum__qis__exp__body(QirArray*, double, QirArray*);              // NOLINT
    QIR_SHARED_API void quantum__qis__exp__adj(QirArray*, double, QirArray*);               // NOLINT
    QIR_SHARED_API void quantum__qis__exp__ctl(QirArray*, QirArray*, double, QirArray*);    // NOLINT
    QIR_SHARED_API void quantum__qis__exp__ctladj(QirArray*, QirArray*, double, QirArray*); // NOLINT
    QIR_SHARED_API void quantum__qis__h__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__h__ctl(QirArray*, QUBIT*);                            // NOLINT
    QIR_SHARED_API RESULT* quantum__qis__measure__body(QirArray*, QirArray*);               // NOLINT
    QIR_SHARED_API void quantum__qis__r__body(PauliId, double, QUBIT*);                     // NOLINT
    QIR_SHARED_API void quantum__qis__r__adj(PauliId, double, QUBIT*);                      // NOLINT
    QIR_SHARED_API void quantum__qis__r__ctl(QirArray*, PauliId, double, QUBIT*);           // NOLINT
    QIR_SHARED_API void quantum__qis__r__ctladj(QirArray*, PauliId, double, QUBIT*);        // NOLINT
    QIR_SHARED_API void quantum__qis__s__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__s__adj(QUBIT*);                                       // NOLINT
    QIR_SHARED_API void quantum__qis__s__ctl(QirArray*, QUBIT*);                            // NOLINT
    QIR_SHARED_API void quantum__qis__s__ctladj(QirArray*, QUBIT*);                         // NOLINT
    QIR_SHARED_API void quantum__qis__t__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__t__adj(QUBIT*);                                       // NOLINT
    QIR_SHARED_API void quantum__qis__t__ctl(QirArray*, QUBIT*);                            // NOLINT
    QIR_SHARED_API void quantum__qis__t__ctladj(QirArray*, QUBIT*);                         // NOLINT
    QIR_SHARED_API void quantum__qis__x__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__x__ctl(QirArray*, QUBIT*);                            // NOLINT
    QIR_SHARED_API void quantum__qis__y__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__y__ctl(QirArray*, QUBIT*);                            // NOLINT
    QIR_SHARED_API void quantum__qis__z__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__z__ctl(QirArray*, QUBIT*);                            // NOLINT
}