// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <cstddef>
#include <string>
#include <vector>
#include <cstdint>

#include "CoreTypes.hpp"

/*======================================================================================================================
    QirArray
======================================================================================================================*/
struct QIR_SHARED_API QirArray
{
    using TItemCount = uint32_t; // Data type of number of items (potentially can be increased to `uint64_t`).
    using TItemSize  = uint32_t; // Data type of item size.
    using TBufSize   = size_t;   // Size of the buffer pointed to by `buffer`
                                 // (32 bit on 32-bit arch, 64 bit on 64-bit arch).
};

/*======================================================================================================================
    QirString is just a wrapper around std::string
======================================================================================================================*/
struct QIR_SHARED_API QirString
{
};

/*======================================================================================================================
    Tuples are opaque to the runtime and the type of the data contained in them isn't (generally) known, thus, we use
    char* to represent the tuples QIR operates with. However, we need to manage tuples' lifetime and in case of nested
    controlled callables we also need to peek into the tuple's content. To do this we associate with each tuple's buffer
    a header that contains the relevant data. The header immediately precedes the tuple's buffer in memory when the
    tuple is created.
======================================================================================================================*/
// TODO (rokuzmin): Move these types to inside of `QirTupleHeader`.
using PTuplePointedType = uint8_t;
using PTuple = PTuplePointedType*; // TODO(rokuzmin): consider replacing `uint8_t*` with `void*` in order to block
                                   //       the accidental {dereferencing and pointer arithmetic}.
                                   //       Much pointer arithmetic in tests. GetHeader() uses the pointer arithmetic.
struct QIR_SHARED_API QirTupleHeader
{
    using TBufSize = size_t; // Type of the buffer size.
};

/*======================================================================================================================
    QirCallable
======================================================================================================================*/
typedef void (*t_CallableEntry)(PTuple, PTuple, PTuple); // TODO(rokuzmin): Move to `QirCallable::t_CallableEntry`.
typedef void (*t_CaptureCallback)(PTuple, int32_t);      // TODO(rokuzmin): Move to `QirCallable::t_CaptureCallback`.
struct QIR_SHARED_API QirCallable
{
};

extern "C"
{
    // https://docs.microsoft.com/azure/quantum/user-guide/language/expressions/valueliterals#range-literals
    struct QirRange
    {
        int64_t start; // Inclusive.
        int64_t step;
        int64_t end; // Inclusive.
    };
}
