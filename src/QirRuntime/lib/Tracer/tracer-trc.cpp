// Copyright (c) // NOLINT{} Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#include "CoreTypes.hpp"
#include "qirTypes.hpp"
#include "tracer.hpp"

extern thread_local std::shared_ptr<CTracer> tracer;

extern "C"
{
    void quantum__trc__on_operation_start(int64_t id) // NOLINT
    {
    }
    void quantum__trc__on_operation_end(int64_t id) // NOLINT
    {
    }

    void quantum__trc__hadamard(Qubit target) // NOLINT
    {
    }
    void quantum__trc__swap(Qubit q1, Qubit q2) // NOLINT
    {
    }

    void quantum__trc__single_qubit_op_0(int32_t duration, Qubit target) // NOLINT
    {
        tracer->TraceSingleQubitOp<0>(duration, target); // NOLINT
    }
    void quantum__trc__single_qubit_op_1(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_2(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_3(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_4(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_5(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_6(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_7(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_8(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_9(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_10(int32_t duration, Qubit target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_11(int32_t duration, Qubit target) // NOLINT
    {
    }

    void quantum__trc__single_qubit_op_ctl_0(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_1(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_2(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_3(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_4(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_5(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_6(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_7(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_8(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_9(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_10(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }
    void quantum__trc__single_qubit_op_ctl_11(int32_t duration, QirArray* controls, Qubit* target) // NOLINT
    {
    }

    void quantum__trc__global_barrier(const char* name) // NOLINT
    {
    }
}