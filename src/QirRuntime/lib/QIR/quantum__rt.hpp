// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cstdint>
#include <stdarg.h> // for va_list

#include "CoreTypes.hpp"
#include "qirTypes.hpp"

struct QirArray;
struct QirCallable;
struct QirString;
struct QirBigInt;

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

extern "C"
{
    struct QirRange
    {
        int64_t start;
        int64_t step;
        int64_t end;
    };

    // ------------------------------------------------------------------------
    // Qubits
    // ------------------------------------------------------------------------

    // Allocates a single qubit.
    QIR_SHARED_API QUBIT* quantum__rt__qubit_allocate(); // NOLINT

    // Allocates an array of qubits.
    QIR_SHARED_API QirArray* quantum__rt__qubit_allocate_array(int64_t count); // NOLINT

    // Release a single qubit.
    QIR_SHARED_API void quantum__rt__qubit_release(QUBIT*); // NOLINT

    // Release qubits, owned by the array. The array itself still needs to be released.
    QIR_SHARED_API void quantum__rt__qubit_release_array(QirArray*); // NOLINT

    // Borrow a single qubit.
    // TODO QIR_SHARED_API QUBIT* quantum__rt__qubit_borrow(); // NOLINT

    // Borrow an array of qubits.
    // TODO QIR_SHARED_API QirArray* quantum__rt__qubit_borrow_array(int64_t count); // NOLINT

    // Return a borrowed qubit.
    // TODO QIR_SHARED_API void quantum__rt__qubit_return(QUBIT*); // NOLINT

    // Return an array of borrowed qubits.
    // TODO QIR_SHARED_API void quantum__rt__qubit_return_array(QirArray*); // NOLINT

    // ------------------------------------------------------------------------
    // Utils
    // ------------------------------------------------------------------------

    // Allocate a block of memory on the heap.
    QIR_SHARED_API char* quantum__rt__heap_alloc(int size); // NOLINT

    // Release a block of allocated heap memory.
    QIR_SHARED_API void quantum__rt__heap_free(char* buffer); // NOLINT

    // Fail the computation with the given error message.
    QIR_SHARED_API void quantum__rt__fail(QirString* msg); // NOLINT

    // Include the given message in the computation's execution log or equivalent.
    QIR_SHARED_API void quantum__rt__message(QirString* msg); // NOLINT

    // ------------------------------------------------------------------------
    // Results
    // ------------------------------------------------------------------------

    // Returns true if the two results are the same, and false if they are different.
    QIR_SHARED_API bool quantum__rt__result_equal(RESULT*, RESULT*); // NOLINT

    // Increments the reference count of a Result pointer.
    QIR_SHARED_API void quantum__rt__result_reference(RESULT*); // NOLINT

    // Decrements the reference count of a Result pointer and releases the result if appropriate.
    QIR_SHARED_API void quantum__rt__result_unreference(RESULT*); // NOLINT

    // ------------------------------------------------------------------------
    // Tuples
    // ------------------------------------------------------------------------

    // Allocates space for a tuple requiring the given number of bytes and sets the reference count to 1.
    QIR_SHARED_API PTuple quantum__rt__tuple_create(int64_t); // NOLINT

    // Indicates that a new reference has been added.
    QIR_SHARED_API void quantum__rt__tuple_reference(PTuple); // NOLINT

    // Indicates that an existing reference has been removed and potentially releases the tuple.
    QIR_SHARED_API void quantum__rt__tuple_unreference(PTuple); // NOLINT

    // Increases the current user count by one.
    QIR_SHARED_API void quantum__rt__tuple_add_user(PTuple); // NOLINT

    // Decreases the current user count by one, fails if the user count becomes negative.
    QIR_SHARED_API void quantum__rt__tuple_remove_user(PTuple); // NOLINT

    // Creates a shallow copy of the tuple if the user count is larger than 0 or the second argument is `true`.
    QIR_SHARED_API PTuple quantum__rt__tuple_copy(PTuple, bool force); // NOLINT

    // ------------------------------------------------------------------------
    // Arrrays
    // ------------------------------------------------------------------------

    // Creates a new 1-dimensional array. The int is the size of each element in bytes. The int64_t is the length
    // of the array. The bytes of the new array should be set to zero.
    QIR_SHARED_API QirArray* quantum__rt__array_create_1d(int32_t, int64_t); // NOLINT

    // Indicates that a new reference has been added.
    QIR_SHARED_API void quantum__rt__array_reference(QirArray*); // NOLINT

    // Indicates that an existing reference has been removed and potentially releases the array.
    QIR_SHARED_API void quantum__rt__array_unreference(QirArray*); // NOLINT

    // Increases the current user count by one.
    QIR_SHARED_API void quantum__rt__array_add_access(QirArray*); // NOLINT

    // Decreases the current user count by one, fails if the user count becomes negative.
    QIR_SHARED_API void quantum__rt__array_remove_access(QirArray*); // NOLINT

    // Returns a new array which is a copy of the passed-in QirArray*.
    QIR_SHARED_API QirArray* quantum__rt__array_copy(QirArray*, bool); // NOLINT

    // Returns a new array which is the concatenation of the two passed-in arrays.
    QIR_SHARED_API QirArray* quantum__rt__array_concatenate(QirArray*, QirArray*); // NOLINT

    // Returns the length of a dimension of the array. The int is the zero-based dimension to return the length of; it
    // must be 0 for a 1-dimensional array.
    QIR_SHARED_API int64_t quantum__rt__array_get_length(QirArray*, int32_t); // NOLINT

    // Returns a pointer to the element of the array at the zero-based index given by the int64_t.
    QIR_SHARED_API char* quantum__rt__array_get_element_ptr_1d(QirArray*, int64_t); // NOLINT

    // Creates a new array. The first int is the size of each element in bytes. The second int is the dimension count.
    // The variable arguments should be a sequence of int64_ts contains the length of each dimension. The bytes of the
    // new array should be set to zero.
    QIR_SHARED_API QirArray* quantum__rt__array_create(int, int, ...); // NOLINT
    QIR_SHARED_API QirArray* quantum__rt__array_create_nonvariadic(    // NOLINT
        int itemSizeInBytes,
        int countDimensions,
        va_list dims);

    // Returns the number of dimensions in the array.
    QIR_SHARED_API int32_t quantum__rt__array_get_dim(QirArray*); // NOLINT

    // Returns a pointer to the indicated element of the array. The variable arguments should be a sequence of int64_ts
    // that are the indices for each dimension.
    QIR_SHARED_API char* quantum__rt__array_get_element_ptr(QirArray*, ...);                      // NOLINT
    QIR_SHARED_API char* quantum__rt__array_get_element_ptr_nonvariadic(QirArray*, va_list dims); // NOLINT

    // Creates and returns an array that is a slice of an existing array. The int indicates which dimension
    // the slice is on. The %Range specifies the slice.
    QIR_SHARED_API QirArray* quantum__rt__array_slice(QirArray*, int32_t, const QirRange&); // NOLINT

    // Creates and returns an array that is a projection of an existing array. The int indicates which dimension the
    // projection is on, and the int64_t specifies the specific index value to project. The returned Array* will have
    // one fewer dimension than the existing array.
    QIR_SHARED_API QirArray* quantum__rt__array_project(QirArray*, int32_t, int64_t); // NOLINT

    // ------------------------------------------------------------------------
    // Callables
    // ------------------------------------------------------------------------

    // Initializes the callable with the provided function table and capture tuple. The capture tuple pointer
    // should be null if there is no capture.
    typedef void (*t_CallableEntry)(PTuple, PTuple, PTuple);                      // NOLINT
    QIR_SHARED_API QirCallable* quantum__rt__callable_create(t_CallableEntry*, PTuple); // NOLINT

    // Indicates that a new reference has been added.
    QIR_SHARED_API void quantum__rt__callable_reference(QirCallable*); // NOLINT

    // Indicates that an existing reference has been removed and potentially releases the callable value.
    QIR_SHARED_API void quantum__rt__callable_unreference(QirCallable*); // NOLINT

    // Initializes the first callable to be the same as the second callable.
    QIR_SHARED_API QirCallable* quantum__rt__callable_copy(QirCallable*); // NOLINT

    // Invokes the callable with the provided argument tuple and fills in the result tuple.
    QIR_SHARED_API void quantum__rt__callable_invoke(QirCallable*, PTuple, PTuple); // NOLINT

    // Updates the callable by applying the Adjoint functor.
    QIR_SHARED_API void quantum__rt__callable_make_adjoint(QirCallable*); // NOLINT

    // Updates the callable by applying the Controlled functor.
    QIR_SHARED_API void quantum__rt__callable_make_controlled(QirCallable*); // NOLINT

    // ------------------------------------------------------------------------
    // Strings
    // ------------------------------------------------------------------------

    // Creates a string from an array of UTF-8 bytes.
    // TODO the provided constructor doesn't match the spec!
    // QIR_SHARED_API QirString* quantum__rt__string_create(int, char*); // NOLINT
    QIR_SHARED_API QirString* quantum__rt__string_create(const char*); // NOLINT

    // Indicates that a new reference has been added.
    QIR_SHARED_API void quantum__rt__string_reference(QirString*); // NOLINT

    // Indicates that an existing reference has been removed and potentially releases the string.
    QIR_SHARED_API void quantum__rt__string_unreference(QirString*); // NOLINT

    // Creates a new string that is the concatenation of the two argument strings.
    QIR_SHARED_API QirString* quantum__rt__string_concatenate(QirString*, QirString*); // NOLINT

    // Returns true if the two strings are equal, false otherwise.
    QIR_SHARED_API bool quantum__rt__string_equal(QirString*, QirString*); // NOLINT

    // Returns a string representation of the integer.
    QIR_SHARED_API QirString* quantum__rt__int_to_string(int64_t); // NOLINT

    // Returns a string representation of the double.
    QIR_SHARED_API QirString* quantum__rt__double_to_string(double); // NOLINT

    // Returns a string representation of the Boolean.
    QIR_SHARED_API QirString* quantum__rt__bool_to_string(bool); // NOLINT

    // Returns a string representation of the result.
    QIR_SHARED_API QirString* quantum__rt__result_to_string(RESULT*); // NOLINT

    // Returns a string representation of the Pauli.
    QIR_SHARED_API QirString* quantum__rt__pauli_to_string(PauliId); // NOLINT

    // Returns a string representation of the qubit.
    QIR_SHARED_API QirString* quantum__rt__qubit_to_string(QUBIT*); // NOLINT

    // Returns a string representation of the range.
    QIR_SHARED_API QirString* quantum__rt__range_to_string(const QirRange&); // NOLINT

    // Returns a string representation of the big integer.
    // TODO QIR_SHARED_API QirString* quantum__rt__bigint_to_string(QirBigInt*); // NOLINT

    // ------------------------------------------------------------------------
    // BigInts
    // ------------------------------------------------------------------------

    // Creates a big integer with the specified initial value.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_create_int64_t(int64_t); // NOLINT

    // Creates a big integer with the initial value specified by the i8 array. The 0-th element of the array is the
    // highest-order byte, followed by the first element, etc.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_create_array(int, char*); // NOLINT

    // Indicates that a new reference has been added.
    // TODO QIR_SHARED_API void quantum__rt__bigint_reference(QirBigInt*); // NOLINT

    // Indicates that an existing reference has been removed and potentially releases the big integer.
    // TODO QIR_SHARED_API void quantum__rt__bigint_unreference(QirBigInt*); // NOLINT

    // Returns the negative of the big integer.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_negate(QirBigInt*); // NOLINT

    // Adds two big integers and returns their sum.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_add(QirBigInt*, QirBigInt*); // NOLINT

    // Subtracts the second big integer from the first and returns their difference.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_subtract(QirBigInt*, QirBigInt*); // NOLINT

    // Multiplies two big integers and returns their product.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_multiply(QirBigInt*, QirBigInt*); // NOLINT

    // Divides the first big integer by the second and returns their quotient.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_divide(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the first big integer modulo the second.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_modulus(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the big integer raised to the integer power.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_power(QirBigInt*, int); // NOLINT

    // Returns the bitwise-AND of two big integers.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_bitand(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise-OR of two big integers.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_bitor(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise-XOR of two big integers.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_bitxor(QirBigInt*, QirBigInt*); // NOLINT

    // Returns the bitwise complement of the big integer.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_bitnot(QirBigInt*); // NOLINT

    // Returns the big integer arithmetically shifted left by the integer amount of bits.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_shiftleft(QirBigInt*, int64_t); // NOLINT

    // Returns the big integer arithmetically shifted right by the integer amount of bits.
    // TODO QIR_SHARED_API QirBigInt* quantum__rt__bigint_shiftright(QirBigInt*, int64_t); // NOLINT

    // Returns true if the two big integers are equal, false otherwise.
    // TODO QIR_SHARED_API bool quantum__rt__bigint_equal(QirBigInt*, QirBigInt*); // NOLINT

    // Returns true if the first big integer is greater than the second, false otherwise.
    // TODO QIR_SHARED_API bool quantum__rt__bigint_greater(QirBigInt*, QirBigInt*); // NOLINT

    // Returns true if the first big integer is greater than or equal to the second, false otherwise.
    // TODO QIR_SHARED_API bool quantum__rt__bigint_greater_eq(QirBigInt*, QirBigInt*); // NOLINT
}