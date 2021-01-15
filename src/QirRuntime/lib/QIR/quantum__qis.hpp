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
    QIR_SHARED_API double quantum__qis__intAsDouble(long);                            // NOLINT
    QIR_SHARED_API void quantum__qis__cnot(QUBIT*, QUBIT*);                           // NOLINT
    QIR_SHARED_API void quantum__qis__h(QUBIT*);                                      // NOLINT
    QIR_SHARED_API RESULT* quantum__qis__mz(QUBIT*);                                  // NOLINT
    QIR_SHARED_API RESULT* quantum__qis__measure(QirArray* paulis, QirArray* qubits); // NOLINT
    QIR_SHARED_API void quantum__qis__rx(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__ry(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__rz(double, QUBIT*);                             // NOLINT
    QIR_SHARED_API void quantum__qis__s(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__t(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__x(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__y(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__z(QUBIT*);                                      // NOLINT
    QIR_SHARED_API void quantum__qis__crx(QirArray*, double, QUBIT*);                 // NOLINT
    QIR_SHARED_API void quantum__qis__crz(QirArray*, double, QUBIT*);                 // NOLINT
}