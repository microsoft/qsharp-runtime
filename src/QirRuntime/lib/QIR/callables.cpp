// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <atomic>
#include <memory>
#include <stdexcept>
#include <string.h> // for memcpy
#include <vector>

#include "qirTypes.hpp"
#include "quantum__rt.hpp"

extern "C"
{
    QirTupleHeader* quantum__rt__tuple_create(int64_t size)
    {
        assert(size >= sizeof(QirTupleHeader));
        char* buffer = new char[size];

        // at the beginning of the buffer place QirTupleHeader
        QirTupleHeader* th = reinterpret_cast<QirTupleHeader*>(buffer);
        th->refCount = 1;
        th->tupleSize = size;

        return th;
    }

    void quantum__rt__tuple_reference(QirTupleHeader* th)
    {
        if (th == nullptr)
        {
            return;
        }
        assert(th->refCount > 0); // no resurrection of deleted tuples
        ++th->refCount;
    }

    void quantum__rt__tuple_unreference(QirTupleHeader* th)
    {
        if (th == nullptr)
        {
            return;
        }

        const long ref = --th->refCount;
        assert(ref >= 0);

        if (ref == 0)
        {
            char* buffer = reinterpret_cast<char*>(th);
            delete[] buffer;
        }
        th = nullptr;
    }

    void quantum__rt__callable_reference(QirCallable* callable)
    {
        if (callable == nullptr)
        {
            return;
        }
        callable->AddRef();
    }

    void quantum__rt__callable_unreference(QirCallable* callable)
    {
        if (callable == nullptr)
        {
            return;
        }
        const long ref = callable->Release();
        assert(ref >= 0);
    }

    QirCallable* quantum__rt__callable_create(t_CallableEntry* entries, QirTupleHeader* capture)
    {
        assert(entries != nullptr);
        return new QirCallable(entries, capture);
    }

    void quantum__rt__callable_invoke(QirCallable* callable, QirTupleHeader* args, QirTupleHeader* result)
    {
        assert(callable != nullptr);
        callable->Invoke(args, result);
    }

    QirCallable* quantum__rt__callable_copy(QirCallable* other)
    {
        if (other == nullptr)
        {
            return nullptr;
        }
        return new QirCallable(*other);
    }

    void quantum__rt__callable_make_adjoint(QirCallable* callable)
    {
        assert(callable != nullptr);
        callable->ApplyFunctor(QirCallable::Adjoint);
    }

    void quantum__rt__callable_make_controlled(QirCallable* callable)
    {
        assert(callable != nullptr);
        callable->ApplyFunctor(QirCallable::Controlled);
    }
}

/*==============================================================================
    Implementation of QirCallable
==============================================================================*/
QirCallable::~QirCallable()
{
    assert(refCount == 0);
}

QirCallable::QirCallable(const t_CallableEntry* ftEntries, QirTupleHeader* capture)
    : refCount(1)
    , capture(capture)
    , appliedFunctor(0)
    , controlledDepth(0)
{
    memcpy(this->functionTable, ftEntries, QirCallable::TableSize * sizeof(void*));
    assert(this->functionTable[0] != nullptr); // base must be always defined
}

QirCallable::QirCallable(const QirCallable& other)
    : refCount(1)
    , capture(other.capture)
    , appliedFunctor(other.appliedFunctor)
    , controlledDepth(other.controlledDepth)
{
    memcpy(this->functionTable, other.functionTable, QirCallable::TableSize * sizeof(void*));
}

long QirCallable::AddRef()
{
    long rc = ++this->refCount;
    assert(rc != 1); // not allowed to resurrect!
    return rc;
}

long QirCallable::Release()
{
    assert(this->refCount > 0);

    long rc = --this->refCount;
    if (rc == 0)
    {
        delete this;
    }
    return rc;
}

// The function _assumes_ a particular structure of the passed in tuple (see
// https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Callables.md) and recurses into it upto
// the given depth to create a new tuple with a combined array of controls.
//
// For example, `src` tuple header might point to a tuple with the following structure (depth = 2):
// { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, i64, %Qubit* }* }* }
// or it might point to a tuple where the inner type isn't a tuple itself (depth = 2):
// { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }
// The function will create a new tuple, where the array contains elements of all nested arrays, respectively for the
// two cases: 
// { %TupleHeader, %Array*, { %TupleHeader, i64, %Qubit* }* } 
// { %TupleHeader, %Array*, %Qubit* } 
// The caller is responsible for releasing both the returned tuple and the array it contains.
// The order of the elements in the array is unspecified.
QirTupleHeader* FlattenControlArrays(QirTupleHeader* tuple, int depth)
{
    assert(depth > 1); // no need to unpack at depth 1, and should avoid allocating unnecessary tuples

    const size_t qubitSize = sizeof(/*Qubit*/ void*);
    const size_t arrayPtrSize = sizeof(/*QirArrray*/ void*);

    // Discover, how many controls there are in total so can allocate a correctly sized array for them.
    int cControls = 0;
    QirTupleHeader* current = tuple;
    for (int i = 0; i < depth; i++)
    {
        QirArray** inner = reinterpret_cast<QirArray**>(current->Data());
        assert((*inner)->itemSizeInBytes == qubitSize);
        cControls += (*inner)->count;
        current = *(reinterpret_cast<QirTupleHeader**>(current->Data() + arrayPtrSize));
    }

    // Copy the controls into the new array. This array doesn't own the qubits so must use the generic constructor.
    QirArray* combinedControls = new QirArray(cControls, qubitSize);
    char* dst = combinedControls->buffer;
    const char* dstEnd = dst + qubitSize * cControls;
    current = tuple;
    QirTupleHeader* last = nullptr;
    for (int i = 0; i < depth; i++)
    {
        if (i == depth - 1)
        {
            last = current;
        }

        QirArray** inner = reinterpret_cast<QirArray**>(current->Data());
        const size_t blockSize = qubitSize * (*inner)->count;
        assert(dst + blockSize <= dstEnd);
        memcpy(dst, (*inner)->buffer, blockSize);
        dst += blockSize;
        current = *(reinterpret_cast<QirTupleHeader**>(current->Data() + arrayPtrSize));
    }

    // Create the new tuple with the flattened controls array.
    QirTupleHeader* flatTuple = quantum__rt__tuple_create(last->tupleSize);
    memcpy(flatTuple->Data(), last->Data(), last->tupleSize - sizeof(QirTupleHeader));
    QirArray** arr = reinterpret_cast<QirArray**>(flatTuple->Data());
    *arr = combinedControls;

    return flatTuple;
}

void QirCallable::Invoke(QirTupleHeader* args, QirTupleHeader* result)
{
    assert(this->appliedFunctor < QirCallable::TableSize);
    if (this->controlledDepth < 2)
    {
        // For uncontrolled or singly-controlled callables, the `args` tuple is "flat" and can be passed directly to the
        // implementing function.
        this->functionTable[this->appliedFunctor](capture, args, result);
    }
    else
    {
        // Must unpack the `args` tuple into a new tuple with flattened controls.
        QirTupleHeader* flat = FlattenControlArrays(args, this->controlledDepth);
        QirArray* controls = *reinterpret_cast<QirArray**>(flat->Data());

        this->functionTable[this->appliedFunctor](capture, flat, result);

        quantum__rt__tuple_unreference(flat);
        quantum__rt__array_unreference(controls);
    }
}

// A + A = I; A + C = C + A = CA; C + C = C; CA + A = C; CA + C = CA
void QirCallable::ApplyFunctor(int functor)
{
    assert(functor == QirCallable::Adjoint || functor == QirCallable::Controlled);

    if (functor == QirCallable::Adjoint)
    {
        this->appliedFunctor ^= QirCallable::Adjoint;
        if (this->functionTable[this->appliedFunctor] == nullptr)
        {
            this->appliedFunctor ^= QirCallable::Adjoint;
            quantum__rt__fail(quantum__rt__string_create("The callable doesn't provide adjoint operation"));
        }
    }
    else if (functor == QirCallable::Controlled)
    {
        this->appliedFunctor |= QirCallable::Controlled;
        if (this->functionTable[this->appliedFunctor] == nullptr)
        {
            if (this->controlledDepth == 0)
            {
                this->appliedFunctor ^= QirCallable::Controlled;
            }
            quantum__rt__fail(quantum__rt__string_create("The callable doesn't provide controlled operation"));
        }
        this->controlledDepth++;
    }
}