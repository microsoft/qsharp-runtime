// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>

#include "CoreTypes.hpp"
#include "QirTypes.hpp"
#include "tracer.hpp"

namespace Microsoft
{
namespace Quantum
{
    extern thread_local std::shared_ptr<CTracer> tracer;
}
} // namespace Microsoft

using namespace Microsoft::Quantum;
extern "C"
{
    void quantum__qis__on_operation_start(int64_t id) // NOLINT
    {
    }
    void quantum__qis__on_operation_end(int64_t id) // NOLINT
    {
    }

    void quantum__qis__swap(Qubit q1, Qubit q2) // NOLINT
    {
    }

    void quantum__qis__single_qubit_op(int32_t id, int32_t duration, Qubit target) // NOLINT
    {
        (void)tracer->TraceSingleQubitOp(id, duration, target);
    }
    void quantum__qis__single_qubit_op_ctl(int32_t id, int32_t duration, QirArray* ctls, Qubit target) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(id, duration, ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), 1, &target);
    }
    void quantum__qis__multi_qubit_op(int32_t id, int32_t duration, QirArray* targets) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(
            id, duration, 0, nullptr, targets->count, reinterpret_cast<Qubit*>(targets->buffer));
    }
    void quantum__qis__multi_qubit_op_ctl(int32_t id, int32_t duration, QirArray* ctls, QirArray* targets) // NOLINT
    {
        (void)tracer->TraceMultiQubitOp(
            id, duration, ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), targets->count,
            reinterpret_cast<Qubit*>(targets->buffer));
    }

    void quantum__qis__inject_barrier(int32_t id, int32_t duration) // NOLINT
    {
        (void)tracer->InjectGlobalBarrier(id, duration);
    }

    RESULT* quantum__qis__single_qubit_measure(int32_t id, int32_t duration, QUBIT* q) // NOLINT
    {
        return tracer->TraceSingleQubitMeasurement(id, duration, q);
    }

    RESULT* quantum__qis__joint_measure(int32_t id, int32_t duration, QirArray* qs) // NOLINT
    {
        return tracer->TraceMultiQubitMeasurement(id, duration, qs->count, reinterpret_cast<Qubit*>(qs->buffer));
    }

    void quantum__qis__apply_conditionally( // NOLINT
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        CTracer::FenceScope sf(
            tracer.get(), rs1->count, reinterpret_cast<Result*>(rs1->buffer), rs2->count,
            reinterpret_cast<Result*>(rs2->buffer));

        clbOnAllEqual->Invoke();
        clbOnSomeDifferent->Invoke();
    }
}