// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <stdexcept>

#include "qsharp__foundation__qis.hpp"

#include "QirTypes.hpp"
#include "QirRuntime.hpp"

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
    void quantum__qis__applyifelseintrinsic__body(RESULT* r, QirCallable* clbOnZero, QirCallable* clbOnOne)
    {
        QirCallable* clb = quantum__rt__result_equal(r, quantum__rt__result_get_zero()) ? clbOnZero : clbOnOne;
        clb->Invoke();
    }

    void quantum__qis__applyconditionallyintrinsic__body(
        QirArray* rs1,
        QirArray* rs2,
        QirCallable* clbOnAllEqual,
        QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clb = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        clb->Invoke();
    }
}