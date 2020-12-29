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
======================================================================================================================*/
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

/*======================================================================================================================
    QirString is just a wrapper around std::string
======================================================================================================================*/
struct QirString
{
    long refCount = 1;
    std::string str;

    QirString(std::string&& str);
};

/*======================================================================================================================
    Tuples are opaque to the runtime and the type of the data contained in them isn't (generally) known, thus, we use
    char* to represent the tuples QIR operates with. However, we need to manage tuples' lifetime and in case of nested
    controlled callables we also need to peek into the tuple's content. To do this we associate with each tuple's buffer
    a header that contains the relevant data. The header immediately precedes the tuple's buffer in memeory when the
    tuple is created.
======================================================================================================================*/
struct QirTupleHeader
{
    int refCount = 0;
    int tupleSize = 0; // when creating the tuple, must be set to the size of the tuple's data buffer

    char* AsTuple()
    {
        return reinterpret_cast<char*>(this) + sizeof(QirTupleHeader);
    }

    int AddRef()
    {
        assert(refCount > 0);
        return ++refCount;
    }

    int Release()
    {
        --refCount;
        if (refCount == 0)
        {
            char* buffer = reinterpret_cast<char*>(this);
            delete[] buffer;
        }
        return refCount;
    }

    static QirTupleHeader* CreateWithCopiedData(QirTupleHeader* other)
    {
        const int size = other->tupleSize;
        char* buffer = new char[sizeof(QirTupleHeader) + size];

        QirTupleHeader* th = reinterpret_cast<QirTupleHeader*>(buffer);
        th->refCount = 1;
        th->tupleSize = size;
        memcpy(th->AsTuple(), other->AsTuple(), size);

        return th;
    }

    static QirTupleHeader* GetHeader(char* tuple)
    {
        return reinterpret_cast<QirTupleHeader*>(tuple - sizeof(QirTupleHeader));
    }
};

/*======================================================================================================================
    A helper type for unpacking tuples used by multi-level controlled callables
======================================================================================================================*/
struct TupleWithControls
{
    QirArray* controls;
    TupleWithControls* innerTuple;

    char* AsTuple()
    {
        return reinterpret_cast<char*>(this);
    }

    static TupleWithControls* FromTuple(char* tuple)
    {
        return reinterpret_cast<TupleWithControls*>(tuple);
    }

    static TupleWithControls* FromTupleHeader(QirTupleHeader* th)
    {
        return FromTuple(th->AsTuple());
    }

    QirTupleHeader* GetHeader()
    {
        return QirTupleHeader::GetHeader(reinterpret_cast<char*>(this));
    }
};
static_assert(
    sizeof(TupleWithControls) == 2 * sizeof(void*),
    L"TupleWithControls must be tightly packed for FlattenControlArrays to be correct");

/*======================================================================================================================
    Example of creating a callable

    ; Single entry of a callable
    ; (a callable might provide entries for body, controlled, adjoint and controlled-adjoint)
    define void @callable-body(
        %Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) { ... }

    ; Definition of the callable that doesn't support any functors
    @callable =
        constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*]
        [
            void (%Tuple*, %Tuple*, %Tuple*)* @collable-body,
            void (%Tuple*, %Tuple*, %Tuple*)* null,
            void (%Tuple*, %Tuple*, %Tuple*)* null,
            void (%Tuple*, %Tuple*, %Tuple*)* null
        ]

    %3 = call %Callable* @__quantum__rt__callable_create(
        [4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @callable, %Tuple* null)

======================================================================================================================*/
typedef void (*t_CallableEntry)(char*, char*, char*);
struct QirCallable
{
    static int constexpr Adjoint = 1;
    static int constexpr Controlled = 1 << 1;

  private:
    static int constexpr TableSize = 4;
    static_assert(
        QirCallable::Adjoint + QirCallable::Controlled < QirCallable::TableSize,
        L"functor kind is used as index into the functionTable");

    int refCount = 1;

    // If the callable doesn't support Adjoint or Controlled functors, the corresponding entries in the table should be
    // set to nullptr.
    t_CallableEntry functionTable[QirCallable::TableSize] = {nullptr, nullptr, nullptr, nullptr};

    // The callable stores the capture, it's given at creation, and passes it to the functions from the function table,
    // but the runtime doesn't have any knowledge about what the tuple actually is.
    char* const capture = nullptr;

    // By default the callable is neither adjoint nor controlled.
    int appliedFunctor = 0;

    // Per https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Callables.md, the callable must
    // unpack the nested controls from the input tuples. Because the tuples aren't typed, the callable will assume
    // that its input tuples are formed in a particular way and will extract the controls to match its tracked depth.
    int controlledDepth = 0;

    // Prevent stack allocations.
    ~QirCallable();

  public:
    QirCallable(const t_CallableEntry* ftEntries, char* capture);
    QirCallable(const QirCallable& other);

    int AddRef();
    int Release();

    void Invoke(char* args, char* result);
    void ApplyFunctor(int functor);
};