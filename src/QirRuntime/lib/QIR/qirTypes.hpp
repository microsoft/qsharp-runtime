// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <atomic>
#include <string>
#include <vector>

class QUBIT;

/*======================================================================================================================
QIR deploys the same %Array type for arrays that own qubits and those that contain qubits but don't own them or
contain values of other types.

This is how allocating and using an array of qubits might look like:
  %Array = type opaque
  %qb = call %Array* @quantum__rt__qubit_allocate_array(i64 %n)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qb, i64 %i)
  %9 = bitcast i8* %8 to %QUBIT**
  %.qb = load %QUBIT*, %QUBIT** %9
  call void @quantum.qis.rx(double %.theta, %QUBIT* %.qb)
  call void @__quantum__rt__qubit_release_array(%Array* %qb)
Note, that there are no individual release_qubit calls -- the qubits will be released by the runtime when the array is
released. The spec isn't clear on what should happen if the array that owns qubits is involved into reference counting.
We'll allow that and will treat reference count dropping to zero the same as if __quantum__rt__qubit_release_array was
called.

When creating an array that doesn't own qubits (even if it's populated with qubit pointers), the client must provide
the count of elements and the size of each. The array is allocated with reference count equal 1 and will release its 
buffer on reference count going to zero:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i32 1, i64 %count)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = mul i64 %count, 8
  %3 = bitcast double* %ansatz to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* %3, i64 %2, i1 false)
  call void @__quantum__rt__array_unreference(%Array* %0)
Note, that in this case the client is responsible for releasing individual qubits (if they were stored into the array).
==============================================================================*/
struct QirArray
{
    int64_t count = 0; // overall size of the array across all dimensions
    const int itemSizeInBytes = 0;

    const int dimensions = 1;
    std::vector<int64_t> dimensionSizes; // not set for 1D arrays, as `count` is sufficient

    char* buffer = nullptr;

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
