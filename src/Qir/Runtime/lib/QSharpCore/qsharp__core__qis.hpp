#pragma once

#include "CoreTypes.hpp" // QUBIT, PauliId, RESULT

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

struct QirArray;

struct QirRTuple
{
    PauliId pauli;
    double angle;
    QUBIT* target;
};

struct QirExpTuple // NOLINT
{
    QirArray* paulis;
    double angle;
    QirArray* targets;
};

/*
    Methods from __quantum__qis namespace are specific to the target. When QIR is generated it might limit or extend
    the set of intrinsics, supported by the target (known to QIR generator at compile time). This provides the
    implementation of the QSharp.Core intrinsics that redirect to IQuantumGateSet.
*/
extern "C"
{
    // Q# Gate Set
    QIR_SHARED_API void __quantum__qis__exp__body(QirArray*, double, QirArray*); // NOLINT
    QIR_SHARED_API void __quantum__qis__exp__adj(QirArray*, double, QirArray*);  // NOLINT
    QIR_SHARED_API void __quantum__qis__exp__ctl(QirArray*, QirExpTuple*);       // NOLINT
    QIR_SHARED_API void __quantum__qis__exp__ctladj(QirArray*, QirExpTuple*);    // NOLINT
    QIR_SHARED_API void __quantum__qis__h__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__h__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_SHARED_API RESULT* __quantum__qis__measure__body(QirArray*, QirArray*);  // NOLINT
    QIR_SHARED_API void __quantum__qis__r__body(PauliId, double, QUBIT*);        // NOLINT
    QIR_SHARED_API void __quantum__qis__r__adj(PauliId, double, QUBIT*);         // NOLINT
    QIR_SHARED_API void __quantum__qis__r__ctl(QirArray*, QirRTuple*);           // NOLINT
    QIR_SHARED_API void __quantum__qis__r__ctladj(QirArray*, QirRTuple*);        // NOLINT
    QIR_SHARED_API void __quantum__qis__s__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__s__adj(QUBIT*);                          // NOLINT
    QIR_SHARED_API void __quantum__qis__s__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_SHARED_API void __quantum__qis__s__ctladj(QirArray*, QUBIT*);            // NOLINT
    QIR_SHARED_API void __quantum__qis__t__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__t__adj(QUBIT*);                          // NOLINT
    QIR_SHARED_API void __quantum__qis__t__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_SHARED_API void __quantum__qis__t__ctladj(QirArray*, QUBIT*);            // NOLINT
    QIR_SHARED_API void __quantum__qis__x__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__x__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_SHARED_API void __quantum__qis__y__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__y__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_SHARED_API void __quantum__qis__z__body(QUBIT*);                         // NOLINT
    QIR_SHARED_API void __quantum__qis__z__ctl(QirArray*, QUBIT*);               // NOLINT

    // Q# Dump:
    // Note: The param `location` must be `const void*`,
    // but it is called from .ll, where `const void*` is not supported.
    QIR_SHARED_API void __quantum__qis__dumpmachine__body(uint8_t* location);                          // NOLINT
    QIR_SHARED_API void __quantum__qis__dumpregister__body(uint8_t* location, const QirArray* qubits); // NOLINT
}
