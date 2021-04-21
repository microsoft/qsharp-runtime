#pragma once

#include "CoreTypes.hpp"    // QUBIT, PauliId, RESULT

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

struct QirArray;

/*
    Methods from __quantum__qis namespace are specific to the target. When QIR is generated it might limit or extend
    the set of intrinsics, supported by the target (known to QIR generator at compile time). This provides the 
    implementation of the QSharp.Core intrinsics that redirect to IQuantumGateSet.
*/
extern "C"
{
    // Q# Gate Set
    QIR_SHARED_API void quantum__qis__h__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API RESULT* quantum__qis__m__body(QUBIT*);                                   // NOLINT
    QIR_SHARED_API void quantum__qis__rx__body(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__ry__body(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__rz__body(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__s__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__s__adj(QUBIT*);                                       // NOLINT
    QIR_SHARED_API void quantum__qis__t__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__t__adj(QUBIT*);                                       // NOLINT
    QIR_SHARED_API void quantum__qis__x__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__x__ctl(QUBIT*, QUBIT*);                               // NOLINT
    QIR_SHARED_API void quantum__qis__y__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__z__body(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__z__ctl(QUBIT*, QUBIT*);                               // NOLINT
    QIR_SHARED_API void quantum__qis__reset__body(QUBIT*);                                  // NOLINT

    // Q# Dump:
    // Note: The param `location` must be `const void*`, but it is called from .ll, where `const void*` is not supported.
    QIR_SHARED_API void quantum__qis__dumpmachine__body(uint8_t* location);                 // NOLINT
    QIR_SHARED_API void quantum__qis__dumpregister__body(uint8_t* location, const QirArray* qubits);   // NOLINT
}
