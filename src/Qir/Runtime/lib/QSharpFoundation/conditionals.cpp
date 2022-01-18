// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <stdexcept>

#include "qsharp__foundation__qis.hpp"

#include "QirTypes.hpp"
#include "QirRuntime.hpp"

static bool ArraysContainEqualResults(QirArray* rs1, QirArray* rs2)
{
    assert(rs1 != nullptr && rs2 != nullptr &&
           __quantum__rt__array_get_size_1d(rs1) == __quantum__rt__array_get_size_1d(rs2));
    // assert(rs1->itemSizeInBytes == sizeof(void*)); // the array should contain pointers to RESULT
    // assert(rs2->itemSizeInBytes == sizeof(void*)); // the array should contain pointers to RESULT

    RESULT** results1 = reinterpret_cast<RESULT**>(__quantum__rt__array_get_element_ptr_1d(rs1, 0));
    RESULT** results2 = reinterpret_cast<RESULT**>(__quantum__rt__array_get_element_ptr_1d(rs2, 0));
    for (QirArray::TItemCount i = 0; i < __quantum__rt__array_get_size_1d(rs1); i++)
    {
        if (!__quantum__rt__result_equal(results1[i], results2[i]))
        {
            return false;
        }
    }
    return true;
}

extern "C"
{
    void __quantum__qis__applyifelseintrinsic__body(RESULT* r, QirCallable* clbOnZero, QirCallable* clbOnOne)
    {
        QirCallable* clb = __quantum__rt__result_equal(r, __quantum__rt__result_get_zero()) ? clbOnZero : clbOnOne;
        __quantum__rt__callable_invoke(clb, nullptr, nullptr);
    }

    void __quantum__qis__applyconditionallyintrinsic__body(QirArray* rs1, QirArray* rs2, QirCallable* clbOnAllEqual,
                                                           QirCallable* clbOnSomeDifferent)
    {
        QirCallable* clb = ArraysContainEqualResults(rs1, rs2) ? clbOnAllEqual : clbOnSomeDifferent;
        __quantum__rt__callable_invoke(clb, nullptr, nullptr);
    }
}
