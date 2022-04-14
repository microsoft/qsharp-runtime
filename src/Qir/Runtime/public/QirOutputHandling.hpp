#ifndef QIROUTPUTHANDLING_HPP
#define QIROUTPUTHANDLING_HPP

#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif

#include "CoreDefines.h"
#include "CoreTypes.hpp"

#ifdef __cplusplus
extern "C"
{
#endif

    // Primitive Result Records

    /// Produces output records of exactly "RESULT\\t0" or "RESULT\\t1"
    QIR_SHARED_API void __quantum__rt__result_record_output(Result); // NOLINT

    /// Produces output records of exactly "RESULT\\tfalse" or "RESULT\\ttrue"
    QIR_SHARED_API void __quantum__rt__bool_record_output(bool); // NOLINT

    /// Produces output records of the format "RESULT\\tn" where n is the string representation of the integer value,
    /// such as "RESULT\\t42"
    QIR_SHARED_API void __quantum__rt__integer_record_output(int64_t); // NOLINT

    /// Produces output records of the format "RESULT\\td" where d is the string representation of the double value,
    /// such as "RESULT\\t3.14"
    QIR_SHARED_API void __quantum__rt__double_record_output(double); // NOLINT


    // Tuple Type Records

    /// Produces output records of exactly "RESULT\\tTUPLE_START"
    QIR_SHARED_API void __quantum__rt__tuple_start_record_output(); // NOLINT

    /// Produces output records of exactly "RESULT\\tTUPLE_END"
    QIR_SHARED_API void __quantum__rt__tuple_end_record_output(); // NOLINT


    // Array Type Records

    /// Produces output records of exactly "RESULT\\tARRAY_START"
    QIR_SHARED_API void __quantum__rt__array_start_record_output(); // NOLINT

    /// Produces output records of exactly "RESULT\\tARRAY_END"
    QIR_SHARED_API void __quantum__rt__array_end_record_output(); // NOLINT

#ifdef __cplusplus
} // extern "C"
#endif

#endif // #ifndef QIROUTPUTHANDLING_HPP
