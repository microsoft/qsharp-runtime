// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


#include <cstdint>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"

extern "C"
{
    QIR_SHARED_API void __quantum__qis__on_operation_start(int64_t /* id */); // NOLINT
    QIR_SHARED_API void __quantum__qis__on_operation_end(int64_t /* id */);   // NOLINT
    QIR_SHARED_API void __quantum__qis__swap(Qubit /*q1*/, Qubit /*q2*/);     // NOLINT

    QIR_SHARED_API void __quantum__qis__single_qubit_op(int32_t id, int32_t duration, Qubit target); // NOLINT
    QIR_SHARED_API void __quantum__qis__single_qubit_op_ctl(                                         // NOLINT
        int32_t id, int32_t duration, QirArray* ctls, Qubit target);
    QIR_SHARED_API void __quantum__qis__multi_qubit_op(int32_t id, int32_t duration, QirArray* targets); // NOLINT
    QIR_SHARED_API void __quantum__qis__multi_qubit_op_ctl(                                              // NOLINT
        int32_t id, int32_t duration, QirArray* ctls, QirArray* targets);

    QIR_SHARED_API void __quantum__qis__inject_barrier(int32_t id, int32_t duration);                    // NOLINT
    QIR_SHARED_API RESULT* __quantum__qis__single_qubit_measure(int32_t id, int32_t duration, QUBIT* q); // NOLINT

    QIR_SHARED_API RESULT* __quantum__qis__joint_measure(int32_t id, int32_t duration, QirArray* qs); // NOLINT

    QIR_SHARED_API void __quantum__qis__apply_conditionally( // NOLINT
        QirArray* rs1, QirArray* rs2, QirCallable* clbOnAllEqual, QirCallable* clbOnSomeDifferent);

} // extern "C"
