// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#ifndef QIROUTPUTHANDLING_HPP
#define QIROUTPUTHANDLING_HPP

// QOH      QIR Output Handling.
// REC      Record.

#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif

#include "CoreDefines.h"
#include "CoreTypes.hpp"

// clang-format off
#define QOH_REC_TYPE "RESULT"
#define QOH_REC_COLUMN_DELIMITER "\t"
#define QOH_REC_PREFIX QOH_REC_TYPE QOH_REC_COLUMN_DELIMITER /* "RESULT" "\t" (== "RESULT\t") */
#define QOH_REC_DELIMITER "\n"

#define QOH_REC_VAL_TUPLE_START "TUPLE_START"
#define QOH_REC_VAL_TUPLE_END   "TUPLE_END"
#define QOH_REC_VAL_ARRAY_START "ARRAY_START"
#define QOH_REC_VAL_ARRAY_END   "ARRAY_END"
#define QOH_REC_VAL_RESULT_ZERO "0"
#define QOH_REC_VAL_RESULT_ONE  "1"
#define QOH_REC_VAL_FALSE       "false"
#define QOH_REC_VAL_TRUE        "true"

#define QOH_REC_TUPLE_START QOH_REC_PREFIX QOH_REC_VAL_TUPLE_START   /* "RESULT" "\t" "TUPLE_START" (== "RESULT\tTUPLE_START") */
#define QOH_REC_TUPLE_END   QOH_REC_PREFIX QOH_REC_VAL_TUPLE_END   
#define QOH_REC_ARRAY_START QOH_REC_PREFIX QOH_REC_VAL_ARRAY_START 
#define QOH_REC_ARRAY_END   QOH_REC_PREFIX QOH_REC_VAL_ARRAY_END   
#define QOH_REC_RESULT_ZERO QOH_REC_PREFIX QOH_REC_VAL_RESULT_ZERO 
#define QOH_REC_RESULT_ONE  QOH_REC_PREFIX QOH_REC_VAL_RESULT_ONE  
#define QOH_REC_FALSE       QOH_REC_PREFIX QOH_REC_VAL_FALSE       
#define QOH_REC_TRUE        QOH_REC_PREFIX QOH_REC_VAL_TRUE
// clang-format on


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
