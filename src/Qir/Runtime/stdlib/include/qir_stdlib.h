// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once
#ifndef QIR_STDLIB_H
#define QIR_STDLIB_H

#include <cstdint>

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    struct QirString;
    struct QirArray;
    struct QirCallable;
    struct QirTuple;
    struct QirBigInt;

    // Type aliases with the same name are added for ease of use in C code.
    typedef struct QirString QirString;
    typedef struct QirArray QirArray;
    typedef struct QirCallable QirCallable;
    typedef struct QirTuple QirTuple;
    typedef struct QirBigInt QirBigInt;

    enum PauliId : int8_t
    {
        PauliId_I = 0,
        PauliId_X = 1,
        PauliId_Z = 2,
        PauliId_Y = 3,
    };

    typedef void (*t_CallableEntry)(QirTuple*, QirTuple*, QirTuple*);
    typedef void (*t_CaptureCallback)(QirTuple*, int32_t);

    // Returns a pointer to the malloc-allocated block.
    QIR_SHARED_API void* __quantum__rt__memory_allocate(uint64_t size); // NOLINT

    // Fail the computation with the given error message.
    [[noreturn]] QIR_SHARED_API void __quantum__rt__fail(QirString* msg); // NOLINT

    // Include the given message in the computation's execution log or equivalent.
    QIR_SHARED_API void __quantum__rt__message(QirString* msg); // NOLINT

    // Creates a new 1-dimensional array. The int is the size of each element in bytes. The int64_t is the length
    // of the array. The bytes of the new array should be set to zero.
    QIR_SHARED_API QirArray* __quantum__rt__array_create_1d(int32_t, int64_t); // NOLINT

    // Adds the given integer value to the reference count for the array. Deallocates the array if the reference count
    // becomes 0. The behavior is undefined if the reference count becomes negative.
    QIR_SHARED_API void __quantum__rt__array_update_reference_count(QirArray*, int32_t); // NOLINT

    // Adds the given integer value to the alias count for the array. Fails if the count becomes negative.
    QIR_SHARED_API void __quantum__rt__array_update_alias_count(QirArray*, int32_t); // NOLINT

    // Creates a shallow copy of the array if the user count is larger than 0 or the second argument is `true`.
    QIR_SHARED_API QirArray* __quantum__rt__array_copy(QirArray*, bool); // NOLINT

    // Returns a new array which is the concatenation of the two passed-in arrays.
    QIR_SHARED_API QirArray* __quantum__rt__array_concatenate(QirArray*, QirArray*); // NOLINT

    // Returns the length of a dimension of the array. The int is the zero-based dimension to return the length of; it
    // must be 0 for a 1-dimensional array.
    QIR_SHARED_API int64_t __quantum__rt__array_get_size_1d(QirArray*); // NOLINT

    // Returns a pointer to the element of the array at the zero-based index given by the int64_t.
    QIR_SHARED_API char* __quantum__rt__array_get_element_ptr_1d(QirArray*, int64_t); // NOLINT

    // Initializes the callable with the provided function table and capture tuple. The capture tuple pointer
    // should be null if there is no capture.
    QIR_SHARED_API QirCallable* __quantum__rt__callable_create( // NOLINT
        t_CallableEntry*, t_CaptureCallback*, QirTuple*);

    // Adds the given integer value to the reference count for the callable. Deallocates the callable if the reference
    // count becomes 0. The behavior is undefined if the reference count becomes negative.
    QIR_SHARED_API void __quantum__rt__callable_update_reference_count(QirCallable*, int32_t); // NOLINT

    // Adds the given integer value to the alias count for the callable. Fails if the count becomes negative.
    QIR_SHARED_API void __quantum__rt__callable_update_alias_count(QirCallable*, int32_t); // NOLINT

    // Creates a shallow copy of the callable if the alias count is larger than 0 or the second argument is `true`.
    // Returns the given callable pointer otherwise, after increasing its reference count by 1.
    QIR_SHARED_API QirCallable* __quantum__rt__callable_copy(QirCallable*, bool); // NOLINT

    // Invokes the callable with the provided argument tuple and fills in the result tuple.
    QIR_SHARED_API void __quantum__rt__callable_invoke(QirCallable*, QirTuple*, QirTuple*); // NOLINT

    // Updates the callable by applying the Adjoint functor.
    QIR_SHARED_API void __quantum__rt__callable_make_adjoint(QirCallable*); // NOLINT

    // Updates the callable by applying the Controlled functor.
    QIR_SHARED_API void __quantum__rt__callable_make_controlled(QirCallable*); // NOLINT

    // Invokes the function in the corresponding index in the memory management table of the callable with the capture
    // tuple and the given 32-bit integer. Does nothing if  the memory management table pointer or the function pointer
    // at that index is null.
    QIR_SHARED_API void __quantum__rt__capture_update_reference_count(QirCallable*, int32_t); // NOLINT
    QIR_SHARED_API void __quantum__rt__capture_update_alias_count(QirCallable*, int32_t);     // NOLINT

    // Creates a string from an array of UTF-8 bytes.
    QIR_SHARED_API QirString* __quantum__rt__string_create(const char*); // NOLINT

    // Adds the given integer value to the reference count for the string. Deallocates the string if the reference count
    // becomes 0. The behavior is undefined if the reference count becomes negative.
    QIR_SHARED_API void __quantum__rt__string_update_reference_count(QirString*, int32_t); // NOLINT

    // Creates a new string that is the concatenation of the two argument strings.
    QIR_SHARED_API QirString* __quantum__rt__string_concatenate(QirString*, QirString*); // NOLINT

    // Returns true if the two strings are equal, false otherwise.
    QIR_SHARED_API bool __quantum__rt__string_equal(QirString*, QirString*); // NOLINT

    // Returns a string representation of the integer.
    QIR_SHARED_API QirString* __quantum__rt__int_to_string(int64_t); // NOLINT

    // Returns a string representation of the double.
    QIR_SHARED_API QirString* __quantum__rt__double_to_string(double); // NOLINT

    // Returns a string representation of the Boolean.
    QIR_SHARED_API QirString* __quantum__rt__bool_to_string(bool); // NOLINT

    // Returns a string representation of the Pauli.
    QIR_SHARED_API QirString* __quantum__rt__pauli_to_string(PauliId); // NOLINT

    // Returns a pointer to an array that contains a null-terminated sequence of characters
    // (i.e., a C-string) representing the current value of the string object.
    QIR_SHARED_API const char* __quantum__rt__string_get_data(QirString* str); // NOLINT

    // Returns the length of the string, in terms of bytes.
    // http://www.cplusplus.com/reference/string/string/size/
    QIR_SHARED_API uint32_t __quantum__rt__string_get_length(QirString* str); // NOLINT

    // Allocates space for a tuple requiring the given number of bytes and sets the reference count to 1.
    QIR_SHARED_API QirTuple* __quantum__rt__tuple_create(int64_t); // NOLINT

    // Adds the given integer value to the reference count for the tuple. Deallocates the tuple if the reference count
    // becomes 0. The behavior is undefined if the reference count becomes negative.
    QIR_SHARED_API void __quantum__rt__tuple_update_reference_count(QirTuple*, int32_t); // NOLINT

    // Adds the given integer value to the alias count for the tuple. Fails if the count becomes negative.
    QIR_SHARED_API void __quantum__rt__tuple_update_alias_count(QirTuple*, int32_t); // NOLINT

    // Creates a shallow copy of the tuple if the user count is larger than 0 or the second argument is `true`.
    QIR_SHARED_API QirTuple* __quantum__rt__tuple_copy(QirTuple*, bool force); // NOLINT

    // Returns a string representation of the big integer.
    QIR_SHARED_API QirString* __quantum__rt__bigint_to_string(QirBigInt*); // NOLINT

    // Creates a big integer with the specified initial value.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_create_i64(int64_t); // NOLINT

    // Creates a big integer with the initial value specified by the i8 array. The 0-th element of the array is the
    // highest-order byte, followed by the first element, etc.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_create_array(int32_t, char*); // NOLINT

    // Adds the given integer value to the reference count for the big integer. Deallocates the big integer if the
    // reference count becomes 0. The behavior is undefined if the reference count becomes negative.
    QIR_SHARED_API void __quantum__rt__bigint_update_reference_count(QirBigInt*, int32_t); // NOLINT

    // Returns the negative of the big integer.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_negate(QirBigInt*); // NOLINT

    // Adds two big integers and returns their sum.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_add(QirBigInt*, QirBigInt*); // NOLINT

    // Subtracts the second big integer from the first and returns their difference.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_subtract(QirBigInt*, QirBigInt*); // NOLINT

    // Multiplies two big integers and returns their product.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_multiply(QirBigInt*, QirBigInt*); // NOLINT

    // Divides the first big integer by the second and returns their quotient.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_divide(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the first big integer modulo the second.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_modulus(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the big integer raised to the integer power.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_power(QirBigInt*, int32_t); // NOLINT

    // Returns the bitwise-AND of two big integers.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_bitand(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise-OR of two big integers.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_bitor(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise-XOR of two big integers.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_bitxor(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise complement of the big integer.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_bitnot(QirBigInt*); // NOLINT

    // Returns the big integer arithmetically shifted left by the (positive) integer amount of bits.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_shiftleft(QirBigInt*, int64_t); // NOLINT

    // Returns the big integer arithmetically shifted right by the (positive) integer amount of bits.
    QIR_SHARED_API QirBigInt* __quantum__rt__bigint_shiftright(QirBigInt*, int64_t); // NOLINT

    // Returns true if the two big integers are equal, false otherwise.
    QIR_SHARED_API bool __quantum__rt__bigint_equal(QirBigInt*, QirBigInt*); // NOLINT

    // Returns true if the first big integer is greater than the second, false otherwise.
    QIR_SHARED_API bool __quantum__rt__bigint_greater(QirBigInt*, QirBigInt*); // NOLINT

    // Returns true if the first big integer is greater than or equal to the second, false otherwise.
    QIR_SHARED_API bool __quantum__rt__bigint_greater_eq(QirBigInt*, QirBigInt*); // NOLINT

    // Q# Math:
    QIR_SHARED_API double __quantum__qis__nan__body();                                            // NOLINT
    QIR_SHARED_API bool __quantum__qis__isnan__body(double d);                                    // NOLINT
    QIR_SHARED_API double __quantum__qis__infinity__body();                                       // NOLINT
    QIR_SHARED_API bool __quantum__qis__isinf__body(double d);                                    // NOLINT
    QIR_SHARED_API bool __quantum__qis__isnegativeinfinity__body(double d);                       // NOLINT
    QIR_SHARED_API double __quantum__qis__sin__body(double d);                                    // NOLINT
    QIR_SHARED_API double __quantum__qis__cos__body(double d);                                    // NOLINT
    QIR_SHARED_API double __quantum__qis__tan__body(double d);                                    // NOLINT
    QIR_SHARED_API double __quantum__qis__arctan2__body(double y, double x);                      // NOLINT
    QIR_SHARED_API double __quantum__qis__sinh__body(double theta);                               // NOLINT
    QIR_SHARED_API double __quantum__qis__cosh__body(double theta);                               // NOLINT
    QIR_SHARED_API double __quantum__qis__tanh__body(double theta);                               // NOLINT
    QIR_SHARED_API double __quantum__qis__arcsin__body(double theta);                             // NOLINT
    QIR_SHARED_API double __quantum__qis__arccos__body(double theta);                             // NOLINT
    QIR_SHARED_API double __quantum__qis__arctan__body(double theta);                             // NOLINT
    QIR_SHARED_API double __quantum__qis__sqrt__body(double d);                                   // NOLINT
    QIR_SHARED_API double __quantum__qis__log__body(double d);                                    // NOLINT
    QIR_SHARED_API double __quantum__qis__ieeeremainder__body(double x, double y);                // NOLINT
    QIR_SHARED_API int64_t __quantum__qis__drawrandomint__body(int64_t minimum, int64_t maximum); // NOLINT
    QIR_SHARED_API double __quantum__qis__drawrandomdouble__body(double minimum, double maximum); // NOLINT

#ifdef __cplusplus
} // extern "C"
#endif

#endif
