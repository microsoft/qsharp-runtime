// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <string>
#include <vector>

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
    long refCount = 1;

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
    long refCount = 1;
    std::string str;

    QirString(std::string&& str);
};

/*==============================================================================
    The types and methods, expected by QIR for tuples:
    %TupleHeader = type { i32, i32 }
    declare %TupleHeader* @__quantum__rt__tuple_create(i64)

    Argument passed to __quantum__rt__tuple_create is the size (in bytes) of the tuple, including the header.
    For example:
    ; to calculate the size of a tuple pretend having an array of them and get
    ; offset to the first element
    %t1 = getelementptr { %TupleHeader, %Callable*, %Array* }, { %TupleHeader, %Callable*, %Array* }* null, i32 1
    ; convert the offset to int and call __quantum__rt__tuple_create
    %t2 = ptrtoint { %TupleHeader, %Callable*, %Array* }* %t1 to i64
    %0 = call %TupleHeader* @__quantum__rt__tuple_create(i62 %t2)

    Notice, that the TupleHeader is included into the Tuple's buffer.
==============================================================================*/
struct QirTupleHeader
{
    int refCount = 0;
    int tupleSize = 0; // when creating the tuple, must be set to: size of this header + size of the tuple's data buffer

    char* Data()
    {
        return reinterpret_cast<char*>(this) + sizeof(QirTupleHeader);
    }
};

/*==============================================================================
    Example of creating a callable

    ; Single entry of a callable
    ; (a callable might provide entries for body, controlled, adjoint and controlled-adjoint)
    define void @UpdateAnsatz-body(
        %TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) { ... }

    ; Definition of the callable
    @UpdateAnsatz =
        constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]
        [
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @UpdateAnsatz-body,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null,
            void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null
        ]

    %3 = call %Callable* @__quantum__rt__callable_create(
        [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @UpdateAnsatz,
        %TupleHeader* null)

==============================================================================*/
typedef void (*t_CallableEntry)(QirTupleHeader*, QirTupleHeader*, QirTupleHeader*);
struct QirCallable
{
    static int constexpr Adjoint = 1;
    static int constexpr Controlled = 1 << 1;

  private:
    static int constexpr TableSize = 4;
    static_assert(
        QirCallable::Adjoint + QirCallable::Controlled < QirCallable::TableSize,
        L"functor kind is used as index into the functionTable");

    long refCount = 1;

    // If the callable doesn't support Adjoint or Controlled functors, the corresponding entries in the table should be
    // set to nullptr.
    t_CallableEntry functionTable[QirCallable::TableSize] = {nullptr, nullptr, nullptr, nullptr};

    // The callable stores the capture, it's given at creation, and passes it to the functions from the function table,
    // but the runtime doesn't have any knowledge about what the tuple actually is.
    QirTupleHeader* const capture = nullptr;

    // By default the callable is neither adjoint nor controlled.
    int appliedFunctor = 0;
    
    // Per https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Callables.md, the callable must
    // unpack the nested controls from the input tuples. Because the tuples aren't typed, the callable will assume
    // that its input tuples are formed in a particular way and will extract the controls to match its tracked depth.
    int controlledDepth = 0;

    // Prevent stack allocations.
    ~QirCallable();

  public:
    QirCallable(const t_CallableEntry* ftEntries, QirTupleHeader* capture);
    QirCallable(const QirCallable& other);

    long AddRef();
    long Release();
    void Invoke(QirTupleHeader* args, QirTupleHeader* result);
    void ApplyFunctor(int functor);
};