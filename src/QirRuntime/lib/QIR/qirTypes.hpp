// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <atomic>
#include <string>
#include <vector>

class QUBIT;

/*==============================================================================
    QIR deploys same %Array type for qubits and non-qubits with different memory
    semantics between the two. Non-qubit arrays are reference-counted and are
    released when ref-count (managed by the clients) goes to zero. QUBIT arrays
    aren't ref-counted and are explicitly released by the clients.

    This is how allocating and using an array of qubits might look like:
      %Array = type opaque
      %qb = call %Array* @quantum__rt__qubit_allocate_array(i64 %n)
      %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qb, i64 %i)
      %9 = bitcast i8* %8 to %QUBIT**
      %.qb = load %QUBIT*, %QUBIT** %9
      call void @quantum.qis.rx(double %.theta, %QUBIT* %.qb)
      call void @__quantum__rt__qubit_release_array(%Array* %qb)
    Note, that there are no individual release_qubit calls.

    The same %Array type is used for other kinds of arrays, in which case the
    client must provide the size of items and a destructor for them (and dimension
    of the array). For example, the snippet below copies data from an array of
    doubles (double* %ansatz of size %count):
      %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i32 1, i64 %count)
      %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
      %2 = mul i64 %count, 8
      %3 = bitcast double* %ansatz to i8*
      call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* %3, i64 %2, i1 false)
      call void @__quantum__rt__array_unreference(%Array* %0)

    Qubits are never placed into multidimentional arrays.
==============================================================================*/
struct QirArray
{
    int64_t count = 0; // overall size of the array across all dimensions
    const int itemSizeInBytes = 0;

    const int dimensions = 1;
    std::vector<int64_t> dimensionSizes; // not set for 1D arrays, as `count` is sufficient

    char* buffer = nullptr;

    // If the client allocates an array of qubits, using quantum__rt__qubit_allocate_array, the array owns the qubits
    // and will deallocate them on quantum__rt__qubit_release_array. Copies or other derivatives from such arrays don't
    // own the qubits and must follow the usual addref/release semantics.
    const bool ownsQubits = false;
    std::atomic<long> refCount;

    // NB: Release doesn't trigger destruction of the Array itself to allow for it
    // being used both on the stack and on the heap. The creator of the array
    // should delete it, if allocated from the heap.
    long AddRef();
    long Release();

    QirArray(int64_t cQubits);
    QirArray(int64_t cItems, int itemSizeInBytes, int dimCount = 1, std::vector<int64_t>&& dimSizes = {});
    QirArray(const QirArray* other);

    ~QirArray();

    char* GetItemPointer(int64_t index);
    QUBIT* GetQubit(int64_t index);
    void Append(const QirArray* other);
};


/*==============================================================================
    QirString is just a wrapper around std::string
==============================================================================*/
struct QirString
{
    std::atomic<long> refCount;
    std::string str;

    QirString(std::string&& str);
};
