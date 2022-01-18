// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"
#include "QirRuntime.hpp"
#include "tracer.hpp"
#include "tracer-qis.hpp"
#include "TracerInternal.hpp"


using namespace Microsoft::Quantum;
extern "C"
{
    void __quantum__qis__on_operation_start(int64_t /* id */) // NOLINT
    {
    }
    void __quantum__qis__on_operation_end(int64_t /* id */) // NOLINT
    {
    }

    void __quantum__qis__swap(QUBIT* /*q1*/, QUBIT* /*q2*/) // NOLINT
    {
    }

    void __quantum__qis__single_qubit_op(int32_t id, int32_t duration, QUBIT* target) // NOLINT
    {
        (void)tracer->TraceSingleQubitOp(id, duration, reinterpret_cast<QubitIdType>(target));
    }
    void __quantum__qis__single_qubit_op_ctl(int32_t id, int32_t duration, QirArray* ctls, QUBIT* target) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(
            id, duration, (long)(__quantum__rt__array_get_size_1d(ctls)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)), 1,
            reinterpret_cast<QubitIdType*>(&target));
    }
    void __quantum__qis__multi_qubit_op(int32_t id, int32_t duration, QirArray* targets) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(
            id, duration, 0, nullptr, (long)(__quantum__rt__array_get_size_1d(targets)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(targets, 0)));
    }
    void __quantum__qis__multi_qubit_op_ctl(int32_t id, int32_t duration, QirArray* ctls, QirArray* targets) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(
            id, duration, (long)(__quantum__rt__array_get_size_1d(ctls)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
            (long)(__quantum__rt__array_get_size_1d(targets)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(targets, 0)));
    }

    void __quantum__qis__inject_barrier(int32_t id, int32_t duration) // NOLINT
    {
        (void)tracer->InjectGlobalBarrier(id, duration);
    }

    RESULT* __quantum__qis__single_qubit_measure(int32_t id, int32_t duration, QUBIT* q) // NOLINT
    {
        return tracer->TraceSingleQubitMeasurement(id, duration, reinterpret_cast<QubitIdType>(q));
    }

    RESULT* __quantum__qis__joint_measure(int32_t id, int32_t duration, QirArray* qs) // NOLINT
    {
        return tracer->TraceMultiQubitMeasurement(
            id, duration, (long)(__quantum__rt__array_get_size_1d(qs)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qs, 0)));
    }

    void __quantum__qis__apply_conditionally( // NOLINT
        QirArray* rs1, QirArray* rs2, QirCallable* clbOnAllEqual, QirCallable* clbOnSomeDifferent)
    {
        CTracer::FenceScope sf(tracer.get(), (long)(__quantum__rt__array_get_size_1d(rs1)),
                               reinterpret_cast<Result*>(__quantum__rt__array_get_element_ptr_1d(rs1, 0)),
                               (long)(__quantum__rt__array_get_size_1d(rs2)),
                               reinterpret_cast<Result*>(__quantum__rt__array_get_element_ptr_1d(rs2, 0)));

        __quantum__rt__callable_invoke(clbOnAllEqual, nullptr, nullptr);
        __quantum__rt__callable_invoke(clbOnSomeDifferent, nullptr, nullptr);
    }
}
