#include <cstdint>
#include <sstream>
#include "QirOutputHandling.hpp"
#include "QirTypes.hpp"
#include "QirRuntime.hpp"

#define RECORD_TYPE "RESULT"
#define RECORD_COLUMN_DELIMITER "\t"
#define RECORD_PREFIX RECORD_TYPE RECORD_COLUMN_DELIMITER /* "RESULT" "\t" (== "RESULT\t") */


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
        PrintCStr(RECORD_PREFIX "TUPLE_START");
    }

    void __quantum__rt__tuple_end_record_output() // NOLINT
    {
        PrintCStr(RECORD_PREFIX "TUPLE_END");
    }


    // Array Type Records

    void __quantum__rt__array_start_record_output() // NOLINT
    {
        PrintCStr(RECORD_PREFIX "ARRAY_START");
    }

    void __quantum__rt__array_end_record_output() // NOLINT
    {
        PrintCStr(RECORD_PREFIX "ARRAY_END");
    }


    // Primitive Result Records

    void __quantum__rt__result_record_output(Result res) // NOLINT
    {
        if (!res)
        {
            PrintCStr(RECORD_PREFIX "0");
        }
        else
        {
            PrintCStr(RECORD_PREFIX "1");
        }
    }

    void __quantum__rt__bool_record_output(bool isTrue) // NOLINT
    {
        if (!isTrue)
        {
            PrintCStr(RECORD_PREFIX "false");
        }
        else
        {
            PrintCStr(RECORD_PREFIX "true");
        }
    }

    void __quantum__rt__integer_record_output(int64_t i64Val) // NOLINT
    {
        std::stringstream strStream;
        strStream << RECORD_PREFIX << i64Val;
        PrintCStr(strStream.str().c_str());
    }

    void __quantum__rt__double_record_output(double doubleVal) // NOLINT
    {
        std::stringstream strStream;
        strStream << RECORD_PREFIX << doubleVal;
        PrintCStr(strStream.str().c_str());
    }

} // extern "C"
