// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <algorithm>
#include <cassert>
#include <cstring> // for memcpy
#include <memory>
#include <numeric>
#include <stdexcept>
#include <vector>

#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QirRuntime.hpp"

using namespace Microsoft::Quantum;

int QirArray::AddRef()
{
    if (GlobalContext() != nullptr)
    {
        GlobalContext()->OnAddRef(this);
    }

    assert(this->refCount != 0 && "Cannot resurrect released array!");
    return ++this->refCount;
}

// NB: Release doesn't trigger destruction of the QirArray itself to allow for it
// being used both on the stack and on the heap. The creator of the array
// should delete it, if allocated from the heap.
int QirArray::Release()
{
    if (GlobalContext() != nullptr)
    {
        GlobalContext()->OnRelease(this);
    }

    assert(this->refCount != 0 && "Cannot release already released array!");
    const int rc = --this->refCount;
    if (rc == 0)
    {
        if (ownsQubits)
        {
            delete[](reinterpret_cast<Qubit*>(this->buffer));
        }
        else
        {
            delete[] this->buffer;
        }
        this->buffer = nullptr;
    }
    return rc;
}

QirArray::QirArray(TItemCount qubitsCount)
    : count(qubitsCount)
    , itemSizeInBytes((TItemSize)sizeof(void*))
    , ownsQubits(true)
    , refCount(1)
{
    if (this->count > 0)
    {
        Qubit* qbuffer = new Qubit[count];
        for (TItemCount i = 0; i < count; i++)
        {
            qbuffer[i] = __quantum__rt__qubit_allocate();
        }
        this->buffer = reinterpret_cast<char*>(qbuffer);
    }
    else
    {
        this->buffer = nullptr;
    }
    this->dimensionSizes.push_back(this->count);

    if (GlobalContext() != nullptr)
    {
        GlobalContext()->OnAllocate(this);
    }
}

QirArray::QirArray(TItemCount countItems, TItemSize itemSizeBytes, TDimCount dimCount, TDimContainer&& dimSizes)
    : count(countItems)

    // Each array item needs to be properly aligned. Let's align them by correcting the `itemSizeInBytes`.
    , itemSizeInBytes(
          ((itemSizeBytes == 1) || (itemSizeBytes == 2) || (itemSizeBytes == 4) ||
           ((itemSizeBytes % sizeof(size_t)) == 0) // For built-in types or multiples of architecture alignment
           )
              ? itemSizeBytes // leave their natural alignment.
                              // Other types align on the architecture boundary `sizeof(size_t)`:
                              // 4 bytes on 32-bit arch, 8 on 64-bit arch.
              : itemSizeBytes + sizeof(size_t) - (itemSizeBytes % sizeof(size_t)))

    , dimensions(dimCount)
    , dimensionSizes(std::move(dimSizes))
    , ownsQubits(false)
    , refCount(1)
{
    assert(itemSizeBytes != 0);
    assert(dimCount > 0);

    if (GlobalContext() != nullptr)
    {
        GlobalContext()->OnAllocate(this);
    }

    if (dimCount == 1)
    {
        assert(this->dimensionSizes.empty() || this->dimensionSizes[0] == this->count);
        if (this->dimensionSizes.empty())
        {
            this->dimensionSizes.push_back(countItems);
        }
    }

    assert(this->count * (TBufSize)itemSizeInBytes < std::numeric_limits<TBufSize>::max());
    // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
    const TBufSize bufferSize = this->count * itemSizeInBytes;
    if (bufferSize > 0)
    {
        this->buffer = new char[bufferSize];
        assert(bufferSize <= std::numeric_limits<size_t>::max());
        memset(this->buffer, 0, (size_t)bufferSize);
    }
    else
    {
        this->buffer = nullptr;
    }
}

QirArray::QirArray(const QirArray& other)
    : count(other.count)
    , itemSizeInBytes(other.itemSizeInBytes)
    , dimensions(other.dimensions)
    , dimensionSizes(other.dimensionSizes)
    , ownsQubits(false)
    , refCount(1)
{
    if (GlobalContext() != nullptr)
    {
        GlobalContext()->OnAllocate(this);
    }

    assert((TBufSize)(this->count) * this->itemSizeInBytes < std::numeric_limits<TBufSize>::max());
    // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
    const TBufSize size = this->count * this->itemSizeInBytes;
    if (this->count > 0)
    {
        this->buffer = new char[size];
        assert(size <= std::numeric_limits<size_t>::max());
        memcpy(this->buffer, other.buffer, (size_t)size);
    }
    else
    {
        this->buffer = nullptr;
    }
}

QirArray::~QirArray()
{
    assert(this->buffer == nullptr);
}

char* QirArray::GetItemPointer(TItemCount index) const
{
    assert(index < this->count);
    return &this->buffer[index * this->itemSizeInBytes];
}

void QirArray::Append(const QirArray* other)
{
    assert(!this->ownsQubits); // cannot take ownership of the appended qubits, as they might be owned by somebody else
    assert(this->itemSizeInBytes == other->itemSizeInBytes);
    assert(this->dimensions == 1 && other->dimensions == 1);

    assert((TBufSize)(other->count) * other->itemSizeInBytes < std::numeric_limits<TBufSize>::max());
    // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
    const TBufSize otherSize = other->count * other->itemSizeInBytes;

    if (otherSize == 0)
    {
        return;
    }

    assert((TBufSize)(this->count) * this->itemSizeInBytes < std::numeric_limits<TBufSize>::max());
    // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
    const TBufSize thisSize = this->count * this->itemSizeInBytes;

    char* newBuffer = new char[thisSize + otherSize];
    if (thisSize)
    {
        memcpy(newBuffer, this->buffer, thisSize);
    }
    memcpy(&newBuffer[thisSize], other->buffer, otherSize);

    delete[] this->buffer;
    this->buffer = newBuffer;
    this->count += other->count;
    this->dimensionSizes[0] = this->count;
}

// We are using "row-major" layout so the linearized index into the multi-dimensional array where indexes into
// each dimension (dim_0, ... , dim_(n-1)) are i_0, i_1, ..., i_(n-1) as:
// i_0*dim_1*...*dim_(n-1) + i_1*dim_2*...*dim_(n-1) + ... + i_(n-2)*dim_(n-1) + i_(n-1)
//
// For example, 3D array with dims [5, 3, 4]:
// 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [0 - 11]
// 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [12 - 23]
// ...                                                    [24 - 35]
// ...                                                    [36 - 47]
// 400 401 402 403 | 410 411 412 413 | 420 421 422 423 -- [48 - 59]
// index[112] ~ linear index 18 = 1*3*4 + 1*4 + 2
static QirArray::TItemCount GetLinearIndex(const QirArray::TDimContainer& dimensionSizes,
                                           const QirArray::TDimContainer& indexes)
{
    const size_t dimensions          = dimensionSizes.size();
    QirArray::TItemCount linearIndex = 0;
    QirArray::TItemCount layerSize   = 1;
    for (size_t i = dimensions; i > 0;)
    {
        --i;
        linearIndex += indexes[i] * layerSize;
        layerSize *= dimensionSizes[i];
    }
    return linearIndex;
}

// Calculate the length of the linear run, where the index in given `dimension` doesn't change.
// It's equal to the product of the dimension sizes in higher dimensions.
static QirArray::TItemCount RunCount(const QirArray::TDimContainer& dimensionSizes, QirArray::TDimCount dimension)
{
    assert((0 <= dimension) && ((size_t)dimension < dimensionSizes.size()));
    return std::accumulate(dimensionSizes.begin() + dimension + 1, dimensionSizes.end(), (QirArray::TDimCount)1,
                           std::multiplies<QirArray::TItemCount>());
}

/*==============================================================================
    Implementation of __quantum__rt__* methods for arrays
==============================================================================*/
extern "C"
{
    QirArray* __quantum__rt__qubit_allocate_array(int64_t count) // TODO: Use `QirArray::TItemCount count`
    {                                                            // (breaking change).
        return new QirArray((QirArray::TItemCount)count);
    }

    QirArray* __quantum__rt__qubit_borrow_array(int64_t count)
    {
        // Currently we implement borrowing as allocation.
        return __quantum__rt__qubit_allocate_array(count);
    }

    void __quantum__rt__qubit_release_array(QirArray* qa)
    {
        if (qa == nullptr)
        {
            return;
        }

        assert(qa->ownsQubits);
        if (qa->ownsQubits)
        {
            Qubit* qubits = reinterpret_cast<Qubit*>(qa->buffer);
            for (QirArray::TItemCount i = 0; i < qa->count; i++)
            {
                __quantum__rt__qubit_release(qubits[i]);
            }
        }

        __quantum__rt__array_update_reference_count(qa, -1);
    }

    void __quantum__rt__qubit_return_array(QirArray* qa)
    {
        // Currently we implement borrowing as allocation.
        __quantum__rt__qubit_release_array(qa);
    }

    QirArray* __quantum__rt__array_create_1d(int32_t itemSizeInBytes, int64_t countItems)
    {
        assert(itemSizeInBytes > 0);
        return new QirArray((QirArray::TItemCount)countItems, (QirArray::TItemSize)itemSizeInBytes);
    }

    // Bucketing of addref/release is non-standard so for now we'll keep the more traditional addref/release semantics
    // in the native types. Should reconsider, if the perf of the loops becomes an issue.
    void __quantum__rt__array_update_reference_count(QirArray* array, int32_t increment)
    {
        if (array == nullptr || increment == 0)
        {
            return;
        }
        else if (increment > 0)
        {
            for (int i = 0; i < increment; i++)
            {
                array->AddRef();
            }
        }
        else
        {
            for (int i = increment; i < 0; i++)
            {
                const long refCount = array->Release();
                if (refCount == 0)
                {
                    delete array;
                    assert(i == -1 && "Attempting to decrement reference count below zero!");
                    break;
                }
            }
        }
    }

    void __quantum__rt__array_update_alias_count(QirArray* array, int32_t increment)
    {
        if (array == nullptr || increment == 0)
        {
            return;
        }
        array->aliasCount += increment;
        if (array->aliasCount < 0)
        {
            __quantum__rt__fail(__quantum__rt__string_create("Alias count cannot be negative!"));
        }
    }

    // TODO: Use `QirArray::TItemCount index` (breaking change):
    char* __quantum__rt__array_get_element_ptr_1d(QirArray* array, int64_t index)
    {
        assert(array != nullptr);
        return array->GetItemPointer((QirArray::TItemCount)index);
    }

    // Returns the number of dimensions in the array.
    int32_t __quantum__rt__array_get_dim(QirArray* array) // TODO: Return `QirArray::TDimCount` (breaking change).
    {
        assert(array != nullptr);
        return array->dimensions;
    }

    // TODO: Use `QirArray::TDimCount dim`, return `QirArray::TItemCount` (breaking change):
    int64_t __quantum__rt__array_get_size(QirArray* array, int32_t dim)
    {
        assert(array != nullptr);
        assert(dim < array->dimensions);

        return array->dimensionSizes[(size_t)dim];
    }

    int64_t __quantum__rt__array_get_size_1d(QirArray* array)
    {
        return __quantum__rt__array_get_size(array, 0);
    }

    QirArray* __quantum__rt__array_copy(QirArray* array, bool forceNewInstance)
    {
        if (array == nullptr)
        {
            return nullptr;
        }
        if (forceNewInstance || array->aliasCount > 0)
        {
            return new QirArray(*array);
        }
        (void)array->AddRef();
        return array;
    }

    QirArray* __quantum__rt__array_concatenate(QirArray* head, QirArray* tail)
    {
        assert(head != nullptr && tail != nullptr);
        assert(head->dimensions == 1 && tail->dimensions == 1);

        QirArray* concatenated = new QirArray(*head);
        concatenated->Append(tail);
        return concatenated;
    }

    // Creates a new array. The first int is the size of each element in bytes. The second int is the dimension count.
    // The variable arguments should be a sequence of int64_ts contains the length of each dimension. The bytes of the
    // new array should be set to zero.
    // TODO: Use unsigned types (breaking change):
    QirArray* __quantum__rt__array_create_nonvariadic(int itemSizeInBytes, int countDimensions, va_list dims)
    {
        QirArray::TDimContainer dimSizes;
        dimSizes.reserve((size_t)countDimensions);
        QirArray::TItemCount totalCount = 1;

        for (int i = 0; i < countDimensions; i++)
        {
            const QirArray::TItemCount dimSize = (QirArray::TItemCount)va_arg(dims, int64_t);
            // TODO: Use `va_arg(dims, QirArray::TItemCount)`.
            dimSizes.push_back(dimSize);
            totalCount *= dimSize;
        }

        assert(countDimensions < std::numeric_limits<QirArray::TDimCount>::max());
        // Using `<` rather than `<=` to calm down the compiler in case `countDimensions` becomes
        // `QirArray::TDimCount`.
        return new QirArray(totalCount, (QirArray::TItemSize)itemSizeInBytes, (QirArray::TDimCount)countDimensions,
                            std::move(dimSizes));
    }

    QirArray* __quantum__rt__array_create(int itemSizeInBytes, int countDimensions, ...) // NOLINT
    {
        va_list args;
        va_start(args, countDimensions);
        QirArray* array = __quantum__rt__array_create_nonvariadic(itemSizeInBytes, countDimensions, args);
        va_end(args);

        return array;
    }

    char* __quantum__rt__array_get_element_ptr_nonvariadic(QirArray* array, va_list args) // NOLINT
    {
        assert(array != nullptr);

        QirArray::TDimContainer indexes;
        indexes.reserve(array->dimensions);

        for (QirArray::TDimCount i = 0; i < array->dimensions; i++)
        {
            indexes.push_back((QirArray::TItemCount)va_arg(args, int64_t));
            // TODO: Use `va_arg(args, QirArray::TItemCount)`.
            assert(indexes.back() < array->dimensionSizes[i]);
        }

        const QirArray::TItemCount linearIndex = GetLinearIndex(array->dimensionSizes, indexes);
        return array->GetItemPointer(linearIndex);
    }

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wvarargs"
    // Returns a pointer to the indicated element of the array. The variable arguments should be a sequence of int64_ts
    // that are the indices for each dimension.
    char* __quantum__rt__array_get_element_ptr(QirArray* array, ...) // NOLINT
    {
        assert(array != nullptr);

        va_list args;
        va_start(args, array->dimensions); // TODO: (Bug or hack?) Replace `array->dimensions` with `array`.
        char* ptr = __quantum__rt__array_get_element_ptr_nonvariadic(array, args);
        va_end(args);

        return ptr;
    }
#pragma GCC diagnostic pop

    struct CheckedRange
    {
        int64_t start; // inclusive
        int64_t step;  // cannot be zero
        int64_t end;   // EXclusive (as opposed to `QirRange`)
        int64_t width; // number of items in the range

        CheckedRange(const QirRange& r, int64_t upperBound /*exclusive*/) // lower bound assumed to be 0 (inclusive)
        {
            this->start = r.start;
            this->step  = r.step;

            if (r.step == 0)
            {
                throw std::runtime_error("invalid range");
            }
            else if ((r.step > 0 && r.end < r.start)     // Positive step and negative range.
                     || (r.step < 0 && r.start < r.end)) // Negative step and positive range.
            {
                // the QirRange generates empty sequence, normalize it
                this->start = 0;
                this->step  = 1;
                this->end   = 0;
                this->width = 0;
            }
            else if (r.step > 0) // Positive step and non-negative range.
            {
                this->width = (r.end - r.start + 1) / r.step                   // Number of full periods.
                              + ((r.end - r.start + 1) % r.step != 0 ? 1 : 0); // Every item is in the beginning of its
                                                                               // period (also true for the last item in
                                                                               // incomplete period at the end).
                assert(this->width > 0);

                const int64_t lastSequenceItem = r.start + (this->width - 1) * r.step;
                if (lastSequenceItem >= upperBound || r.start < 0)
                {
                    throw std::runtime_error("range out of bounds");
                }

                this->end = lastSequenceItem + r.step; // `this->end` is EXclusive (as opposed to `QirRange`).
                                                       // `this->end` can also be `lastSequenceItem + 1`.
            }
            else // Negative step and non-positive range.
            {    // Range{10, -3, 1} == { 10, 7, 4, 1 }
                // (B) Range{1, -5 , 0} = { 1 }
                // (C) Range{4, -2, 0} = {4, 2, 0}
                this->width = (r.end - r.start - 1) / r.step // (1 - 10 - 1) / (-3) == (-10) / (-3) == 3.
                                                             // (B) (0 - 1 - 1) / (-5) == -2 / -5 == 0.
                              + ((r.end - r.start - 1) % r.step != 0 ? 1 : 0); // (-10) % (-3) == -1; (-1) ? 1 : 0 == 1.
                                                                               // (B) -2 % -5 = -2; -2 ? 1 : 0 == 1.
                                                                               // Total: 4.
                                                                               // (B) Total: 1.
                assert(this->width > 0);

                const int64_t lastSequenceItem =
                    r.start + (this->width - 1) * r.step; // 10 + (4 - 1) * (-3) = 1.
                                                          // (B) 1 + (1 - 1)*(-5) = 1 + 0*5 = 1.
                if (lastSequenceItem < 0 || r.start >= upperBound)
                {
                    throw std::runtime_error("range out of bounds");
                }

                this->end = lastSequenceItem + r.step; // (B) 1 + (-5) = -4.
                                                       // `this->end` is EXclusive (as opposed to `QirRange`).
                                                       // `this->end` can also be `lastSequenceItem - 1`.
            }

            // normalize the range of width 1, as the step doesn't matter for it
            if (this->width == 1)
            {
                this->step = 1;
                this->end  = this->start + 1;
            }
        }

        bool IsEmpty() const
        {
            return this->width == 0;
        }
    };

    // Creates and returns an array that is a slice of an existing array. The int indicates which dimension the slice is
    // on. The %Range specifies the slice. Both ends of the range are inclusive. Negative step means the the order of
    // elements should be reversed.
    // TODO: Use `QirArray::TDimCount dim` (breaking change):
    QirArray* quantum__rt__array_slice( // NOLINT
        QirArray* array, int32_t dim, const QirRange& qirRange,
        bool /*ignored: forceNewInstance*/) // https://github.com/microsoft/qsharp-language/issues/102
                                            // https://github.com/microsoft/qsharp-runtime/pull/830#issuecomment-925435170
    {
        assert(array != nullptr);
        assert(dim >= 0 && dim < array->dimensions);

        const QirArray::TItemSize itemSizeInBytes = array->itemSizeInBytes;
        const QirArray::TDimCount dimensions      = array->dimensions;

        const CheckedRange range(qirRange, array->dimensionSizes[(size_t)dim]);

        // If the range is empty, return an empty array of the same type but 0 items in dim dimension.
        if (range.IsEmpty())
        {
            QirArray::TDimContainer dims = array->dimensionSizes;
            dims[(size_t)dim]            = 0;
            return new QirArray(0, itemSizeInBytes, dimensions, std::move(dims));
        }

        // When range covers the whole dimension, can return a copy of the array without doing any math.
        if (range.step == 1 && range.start == 0 && range.end == array->dimensionSizes[(size_t)dim])
        {
            return __quantum__rt__array_copy(array, true /*force*/);
        }

        // Create slice array of appropriate size.
        QirArray::TDimContainer sliceDims          = array->dimensionSizes;
        sliceDims[(size_t)dim]                     = (QirArray::TItemCount)(range.width);
        const QirArray::TItemCount sliceItemsCount = std::accumulate(
            sliceDims.begin(), sliceDims.end(), (QirArray::TItemCount)1, std::multiplies<QirArray::TItemCount>());
        QirArray* slice = new QirArray(sliceItemsCount, itemSizeInBytes, dimensions, std::move(sliceDims));
        if (nullptr == slice->buffer)
        {
            return slice;
        }
        const QirArray::TItemCount singleIndexRunCount = RunCount(array->dimensionSizes, (QirArray::TDimCount)dim);
        const QirArray::TItemCount rowCount            = singleIndexRunCount * array->dimensionSizes[(size_t)dim];

        // When range is continuous, can copy data in larger chunks. For example, if the slice is on dim = 0,
        // we will copy exactly once.
        if (range.step == 1)
        {
            const QirArray::TItemCount rangeRunCount =
                (QirArray::TItemCount)(singleIndexRunCount * (range.end - range.start));

            assert((QirArray::TBufSize)rangeRunCount * itemSizeInBytes <
                   std::numeric_limits<QirArray::TBufSize>::max());
            // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
            const QirArray::TBufSize rangeChunkSize = rangeRunCount * itemSizeInBytes;

            QirArray::TItemCount dst = 0;
            QirArray::TItemCount src = (QirArray::TItemCount)(singleIndexRunCount * range.start);
            while (src < array->count)
            {
                assert(dst < slice->count);
                memcpy(&slice->buffer[dst * itemSizeInBytes], &array->buffer[src * itemSizeInBytes], rangeChunkSize);
                src += rowCount;
                dst += rangeRunCount;
            }
            return slice;
        }

        // In case of disconnected or reversed range have to copy the data one run at a time.
        assert((QirArray::TBufSize)singleIndexRunCount * itemSizeInBytes <
               std::numeric_limits<QirArray::TBufSize>::max());
        // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.
        const QirArray::TBufSize chunkSize = singleIndexRunCount * itemSizeInBytes;
        QirArray::TItemCount dst           = 0;
        QirArray::TItemCount src           = (QirArray::TItemCount)(singleIndexRunCount * range.start);
        while (src < array->count)
        {
            assert(dst < slice->count);

            int64_t srcInner = src; // The `srcInner` can go negative in the end of the last iteration.
            for (int64_t index = range.start; index != range.end; index += range.step)
            {
                assert((dst * itemSizeInBytes + chunkSize) <= (slice->count * slice->itemSizeInBytes));
                assert((srcInner * (int64_t)itemSizeInBytes + (int64_t)chunkSize) <=
                       (array->count * array->itemSizeInBytes));
                assert(srcInner >= 0);

                memcpy(&slice->buffer[dst * itemSizeInBytes], &array->buffer[srcInner * itemSizeInBytes], chunkSize);
                srcInner += (singleIndexRunCount * range.step);
                dst += singleIndexRunCount;
            }
            src += rowCount;
        }
        return slice;
    }

    // Creates and returns an array that is a projection of an existing array. The int indicates which dimension the
    // projection is on, and the int64_t specifies the specific index value to project. The returned Array* will have
    // one fewer dimension than the existing array.
    // TODO: Use `QirArray::TDimCount dim, QirArray::TItemCount index` (breaking change):
    QirArray* __quantum__rt__array_project(QirArray* array, int dim, int64_t index) // NOLINT
    {
        assert(array != nullptr);
        assert(dim >= 0 && dim < array->dimensions);
        assert(array->dimensions > 1); // cannot project from 1D array into an array
        assert(index >= 0 && index < array->dimensionSizes[(size_t)dim]);

        const QirArray::TItemSize itemSizeInBytes = array->itemSizeInBytes;
        const QirArray::TDimCount dimensions      = array->dimensions;

        // Create projected array of appropriate size.
        QirArray::TDimContainer projectDims = array->dimensionSizes;
        projectDims.erase(projectDims.begin() + dim);

        const QirArray::TItemCount projectItemsCount = std::accumulate(
            projectDims.begin(), projectDims.end(), (QirArray::TItemCount)1, std::multiplies<QirArray::TItemCount>());
        QirArray* project = new QirArray(projectItemsCount, itemSizeInBytes, dimensions - 1, std::move(projectDims));
        if (nullptr == project->buffer)
        {
            return project;
        }

        const QirArray::TItemCount singleIndexRunCount = RunCount(array->dimensionSizes, (QirArray::TDimCount)dim);
        const QirArray::TItemCount rowCount            = singleIndexRunCount * array->dimensionSizes[(size_t)dim];

        assert((QirArray::TBufSize)singleIndexRunCount * itemSizeInBytes <
               std::numeric_limits<QirArray::TBufSize>::max());
        // Using `<` rather than `<=` to calm down the compiler on 32-bit arch.

        const QirArray::TBufSize chunkSize = singleIndexRunCount * itemSizeInBytes;

        QirArray::TItemCount dst = 0;
        QirArray::TItemCount src = (QirArray::TItemCount)(singleIndexRunCount * index);
        while (src < array->count)
        {
            assert(dst < project->count);
            memcpy(&project->buffer[dst * itemSizeInBytes], &array->buffer[src * itemSizeInBytes], chunkSize);
            src += rowCount;
            dst += singleIndexRunCount;
        }
        return project;
    }
}
