// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <stdexcept>

#include "quantum__qis.hpp"

#include "QirTypes.hpp"
#include "quantum__rt.hpp"

static void ApplyWithFunctor(bool isControlled, bool isAdjoint, QirArray* ctls, QirCallable* clb)
{
    auto tupleSize = isControlled ? sizeof(void*) : 0;
    PTuple argsTuple = quantum__rt__tuple_create(tupleSize);

    QirCallable* clbFunc =
        (isAdjoint || isControlled) ? quantum__rt__callable_copy(clb, true /*force new instance*/) : clb;

    if (isAdjoint)
    {
        quantum__rt__callable_make_adjoint(clbFunc);
    }
    if (isControlled)
    {
        quantum__rt__callable_make_controlled(clbFunc);
        *reinterpret_cast<QirArray**>(argsTuple) = ctls;
    }

    quantum__rt__callable_invoke(clbFunc, argsTuple /*args*/, nullptr /*result*/);

    if (clb != clbFunc)
    {
        quantum__rt__callable_update_reference_count(clbFunc, -1);
    }
    quantum__rt__tuple_update_reference_count(argsTuple, -1);
}

static bool ArraysContainEqualResults(QirArray* rs1, QirArray* rs2)
{
    assert(rs1 != nullptr && rs2 != nullptr && rs1->count == rs2->count);
    assert(rs1->itemSizeInBytes == sizeof(void*)); // the array should contain pointers to RESULT
    assert(rs2->itemSizeInBytes == sizeof(void*)); // the array should contain pointers to RESULT

    RESULT** results1 = reinterpret_cast<RESULT**>(rs1->buffer);
    RESULT** results2 = reinterpret_cast<RESULT**>(rs2->buffer);
    for (int64_t i = 0; i < rs1->count; i++)
    {
        if (!quantum__rt__result_equal(results1[i], results2[i]))
        {
            return false;
        }
    }
    return true;
}

extern "C"
{
    void unexpected_conditional()
    {
        throw std::logic_error(
            "This conditional callback should have been lowered to a corresponding __body call in QIR");
    }

    void quantum__qis__applyifelseintrinsic__body(RESULT* r, QirCallable* clbOnZero, QirCallable* clbOnOne)
    {
        QirCallable* clbApply = quantum__rt__result_equal(r, quantum__rt__result_zero()) ? clbOnZero : clbOnOne;
        PTuple argsTuple = quantum__rt__tuple_create(0);
        quantum__rt__callable_invoke(clbApply, argsTuple /*args*/, nullptr /*result*/);
        quantum__rt__tuple_update_reference_count(argsTuple, -1);
    }

    void quantum__qis__applyconditionallyintrinsicca__body(
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clbApply = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        ApplyWithFunctor(false /*C*/, false /*A*/, nullptr, clbApply);
    }

    void quantum__qis__applyconditionallyintrinsicca__adj(
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clbApply = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        ApplyWithFunctor(false /*C*/, true /*A*/, nullptr, clbApply);
    }

    void quantum__qis__applyconditionallyintrinsicca__ctl(
        QirArray* ctls,
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clbApply = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        ApplyWithFunctor(true /*C*/, false /*A*/, ctls, clbApply);
    }

    void quantum__qis__applyconditionallyintrinsicca__ctladj(
        QirArray* ctls,
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clbApply = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        ApplyWithFunctor(true /*C*/, true /*A*/, ctls, clbApply);
    }
}