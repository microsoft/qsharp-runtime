// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstdint>
#include <sstream>
#include "QirOutputHandling.hpp"
#include "QirTypes.hpp"
#include "QirRuntime.hpp"

static void PrintCStr(const char* cStr)
{
    QirString msg(cStr);
    __quantum__rt__message(&msg);
}


extern "C"
{
    // Tuple Type Records

    void __quantum__rt__tuple_start_record_output() // NOLINT
    {
        PrintCStr(QOH_REC_TUPLE_START);
    }

    void __quantum__rt__tuple_end_record_output() // NOLINT
    {
        PrintCStr(QOH_REC_TUPLE_END);
    }


    // Array Type Records

    void __quantum__rt__array_start_record_output() // NOLINT
    {
        PrintCStr(QOH_REC_ARRAY_START);
    }

    void __quantum__rt__array_end_record_output() // NOLINT
    {
        PrintCStr(QOH_REC_ARRAY_END);
    }


    // Primitive Result Records

    void __quantum__rt__result_record_output(Result res) // NOLINT
    {
        if (__quantum__rt__result_equal(res, __quantum__rt__result_get_zero()))
        {
            PrintCStr(QOH_REC_RESULT_ZERO);
        }
        else
        {
            PrintCStr(QOH_REC_RESULT_ONE);
        }
    }

    void __quantum__rt__bool_record_output(bool isTrue) // NOLINT
    {
        if (!isTrue)
        {
            PrintCStr(QOH_REC_FALSE);
        }
        else
        {
            PrintCStr(QOH_REC_TRUE);
        }
    }

    void __quantum__rt__integer_record_output(int64_t i64Val) // NOLINT
    {
        std::stringstream strStream;
        strStream << QOH_REC_PREFIX << i64Val;
        PrintCStr(strStream.str().c_str());
    }

    void __quantum__rt__double_record_output(double doubleVal) // NOLINT
    {
        std::stringstream strStream;
        strStream << QOH_REC_PREFIX << doubleVal;
        PrintCStr(strStream.str().c_str());
    }

} // extern "C"
