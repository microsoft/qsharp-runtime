// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <algorithm>
#include <assert.h>
#include <memory>
#include <numeric>
#include <stdexcept>
#include <string.h> // for memcpy
#include <vector>

#include "qirTypes.hpp"
#include "quantum__rt.hpp"

#include "CoreTypes.hpp"

int QirArray::AddRef()
{
    assert(this->refCount != 0 && "Cannot resurrect released array!");
    return ++this->refCount;
}

// NB: Release doesn't trigger destruction of the QirArray itself to allow for it
// being used both on the stack and on the heap. The creator of the array
// should delete it, if allocated from the heap.
int QirArray::Release()
{
    assert(this->refCount != 0 && "Cannot release already released array!");
    const int rc = --this->refCount;
    if (rc == 0)
    {
        delete[] this->buffer;
        this->buffer = nullptr;
    }
    return rc;
}

void QirArray::AddUser()
{
    ++this->userCount;
}

void QirArray::RemoveUser()
{
    if (this->userCount == 0)
    {
        quantum__rt__fail(quantum__rt__string_create("User count cannot be negative"));
    }
    --this->userCount;
}

QirArray::QirArray(int64_t qubits_count)
    : count(qubits_count)
    , itemSizeInBytes(sizeof(void*))
    , ownsQubits(true)
    , refCount(1)
{
    if (this->count > 0)
    {
        QUBIT** qbuffer = new QUBIT*[count];
        for (long i = 0; i < count; i++)
        {
            qbuffer[i] = quantum__rt__qubit_allocate();
        }
        this->buffer = reinterpret_cast<char*>(qbuffer);
    }
    else
    {
        this->buffer = nullptr;
    }
    this->dimensionSizes.push_back(this->count);
}

QirArray::QirArray(int64_t count_items, int item_size_bytes, int dimCount, std::vector<int64_t>&& dimSizes)
    : count(count_items)
    , itemSizeInBytes(item_size_bytes)
    , dimensions(dimCount)
    , dimensionSizes(std::move(dimSizes))
    , ownsQubits(false)
    , refCount(1)
{
    assert(dimCount > 0);
    if (dimCount == 1)
    {
        assert(this->dimensionSizes.empty() || this->dimensionSizes[0] == this->count);
        if (this->dimensionSizes.empty())
        {
            this->dimensionSizes.push_back(count_items);
        }
    }

    const int64_t buffer_size = this->count * itemSizeInBytes;
    if (buffer_size > 0)
    {
        this->buffer = new char[buffer_size];
        memset(this->buffer, 0, buffer_size);
    }
    else
    {
        this->buffer = nullptr;
    }
}

QirArray::QirArray(const QirArray* other)
    : count(other->count)
    , itemSizeInBytes(other->itemSizeInBytes)
    , dimensions(other->dimensions)
    , dimensionSizes(other->dimensionSizes)
    , ownsQubits(false)
    , refCount(1)
{
    const int64_t size = this->count * this->itemSizeInBytes;
    if (this->count > 0)
    {
        this->buffer = new char[size];
        memcpy(this->buffer, other->buffer, size);
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

char* QirArray::GetItemPointer(int64_t index)
{
    assert(index >= 0);
    assert(index < this->count);
    return &this->buffer[index * this->itemSizeInBytes];
}

void QirArray::Append(const QirArray* other)
{
    assert(!this->ownsQubits); // cannot take ownership of the appended qubits, as they might be owned by somebody else
    assert(this->itemSizeInBytes == other->itemSizeInBytes);
    assert(this->dimensions == 1 && other->dimensions == 1);

    if (other->count == 0)
    {
        return;
    }

    const int64_t this_size = this->count * this->itemSizeInBytes;
    const int64_t other_size = other->count * other->itemSizeInBytes;
    char* new_buffer = new char[this_size + other_size];
    memcpy(new_buffer, this->buffer, this_size);
    memcpy(&new_buffer[this_size], other->buffer, other_size);

    delete[] this->buffer;
    this->buffer = new_buffer;
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
static int64_t GetLinearIndex(const std::vector<int64_t>& dimensionSizes, const std::vector<int64_t>& indexes)
{
    const int dimensions = dimensionSizes.size();
    int64_t linearIndex = 0;
    int64_t layerSize = 1;
    for (int i = dimensions - 1; i >= 0; i--)
    {
        linearIndex += indexes[i] * layerSize;
        layerSize *= dimensionSizes[i];
    }
    return linearIndex;
}

// Calculate the length of the linear run, where the index in given `dimension` doesn't change.
// It's equal to the product of the dimension sizes in higher dimensions.
static int64_t RunCount(const std::vector<int64_t>& dimensionSizes, int dimension)
{
    assert(dimension < dimensionSizes.size());
    return std::accumulate(dimensionSizes.begin() + dimension + 1, dimensionSizes.end(), 1, std::multiplies<int64_t>());
}

/*==============================================================================
    We don't expect the clients to create many arrays so we'll start with
    allocating the QirArray objects on the heap. If later it proves being a problem,
    can add some kind of QirArray Manager that will store QirArrays in a more efficient
    maner.

    Re null handling: because the quantum__rt__* methods aren't expected to be
    invoked directly by the clients, we assume that qir generation ensures null safety.
==============================================================================*/

extern "C"
{
    QirArray* quantum__rt__qubit_allocate_array(int64_t count)
    {
        return new QirArray(count);
    }

    void quantum__rt__qubit_release_array(QirArray* qa)
    {
        if (qa == nullptr)
        {
            return;
        }

        assert(qa->ownsQubits);
        if (qa->ownsQubits)
        {
            QUBIT** qubits = reinterpret_cast<QUBIT**>(qa->buffer);
            for (long i = 0; i < qa->count; i++)
            {
                quantum__rt__qubit_release(qubits[i]);
            }
        }
    }

    QirArray* quantum__rt__array_create_1d(int32_t itemSizeInBytes, int64_t count_items)
    {
        assert(itemSizeInBytes > 0);
        return new QirArray(count_items, itemSizeInBytes);
    }

    void quantum__rt__array_reference(QirArray* array)
    {
        if (array == nullptr)
        {
            return;
        }
        array->AddRef();
    }

    void quantum__rt__array_unreference(QirArray* array)
    {
        if (array == nullptr)
        {
            return;
        }
        const long refCount = array->Release();
        if (refCount == 0)
        {
            delete array;
        };
    }

    void quantum__rt__array_add_access(QirArray* array)
    {
        if (array == nullptr)
        {
            return;
        }
        array->AddUser();
    }

    void quantum__rt__array_remove_access(QirArray* array)
    {
        if (array == nullptr)
        {
            return;
        }
        array->RemoveUser();
    }

    char* quantum__rt__array_get_element_ptr_1d(QirArray* array, int64_t index)
    {
        assert(array != nullptr);
        return array->GetItemPointer(index);
    }

    // Returns the number of dimensions in the array.
    int32_t quantum__rt__array_get_dim(QirArray* array)
    {
        assert(array != nullptr);
        return array->dimensions;
    }

    int64_t quantum__rt__array_get_length(QirArray* array, int32_t dim)
    {
        assert(array != nullptr);
        assert(dim < array->dimensions);

        return array->dimensionSizes[dim];
    }

    QirArray* quantum__rt__array_copy(QirArray* array, bool force)
    {
        if (array == nullptr)
        {
            return nullptr;
        }
        if (force || array->userCount > 0)
        {
            return new QirArray(array);
        }
        (void)array->AddRef();
        return array;
    }

    QirArray* quantum__rt__array_concatenate(QirArray* head, QirArray* tail)
    {
        assert(head != nullptr && tail != nullptr);
        assert(head->dimensions == 1 && tail->dimensions == 1);

        QirArray* concatenated = new QirArray(head);
        concatenated->Append(tail);
        return concatenated;
    }

    // Creates a new array. The first int is the size of each element in bytes. The second int is the dimension count.
    // The variable arguments should be a sequence of int64_ts contains the length of each dimension. The bytes of the
    // new array should be set to zero.
    QirArray* quantum__rt__array_create_nonvariadic(int itemSizeInBytes, int countDimensions, va_list dims)
    {
        std::vector<int64_t> dimSizes;
        dimSizes.reserve(countDimensions);
        int64_t totalCount = 1;

        for (int i = 0; i < countDimensions; i++)
        {
            const int64_t dimSize = va_arg(dims, int64_t);
            dimSizes.push_back(dimSize);
            totalCount *= dimSize;
        }

        return new QirArray(totalCount, itemSizeInBytes, countDimensions, std::move(dimSizes));
    }

    QirArray* quantum__rt__array_create(int itemSizeInBytes, int countDimensions, ...) // NOLINT
    {
        va_list args;
        va_start(args, countDimensions);
        QirArray* array = quantum__rt__array_create_nonvariadic(itemSizeInBytes, countDimensions, args);
        va_end(args);

        return array;
    }

    char* quantum__rt__array_get_element_ptr_nonvariadic(QirArray* array, va_list args) // NOLINT
    {
        assert(array != nullptr);

        std::vector<int64_t> indexes;
        indexes.reserve(array->dimensions);

        for (int i = 0; i < array->dimensions; i++)
        {
            indexes.push_back(va_arg(args, int64_t));
            assert(indexes.back() < array->dimensionSizes[i]);
        }

        const int64_t linearIndex = GetLinearIndex(array->dimensionSizes, indexes);
        return array->GetItemPointer(linearIndex);
    }

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wvarargs"
    // Returns a pointer to the indicated element of the array. The variable arguments should be a sequence of int64_ts
    // that are the indices for each dimension.
    char* quantum__rt__array_get_element_ptr(QirArray* array, ...) // NOLINT
    {
        assert(array != nullptr);

        va_list args;
        va_start(args, array->dimensions);
        char* ptr = quantum__rt__array_get_element_ptr_nonvariadic(array, args);
        va_end(args);

        return ptr;
    }
#pragma GCC diagnostic pop

    struct CheckedRange
    {
        int64_t start; // inclusive
        int64_t step;  // cannot be zero
        int64_t end;   // exclusive
        int64_t width; // number of items in the range

        CheckedRange(const QirRange& r, int64_t upperBound) // lower bound assumed to be 0
        {
            this->start = r.start;
            this->step = r.step;

            if (r.step == 0)
            {
                throw std::runtime_error("invalid range");
            }
            else if ((r.step > 0 && r.end < r.start) || (r.step < 0 && r.start < r.end))
            {
                // the QirRange generates empty sequence, normalize it
                this->start = 0;
                this->step = 1;
                this->end = 0;
                this->width = 0;
            }
            else if (r.step > 0)
            {
                this->width = (r.end - r.start + 1) / r.step + ((r.end - r.start + 1) % r.step != 0 ? 1 : 0);
                assert(this->width > 0);

                const int64_t lastSequenceItem = r.start + (this->width - 1) * r.step;
                if (lastSequenceItem >= upperBound || r.start < 0)
                {
                    throw std::runtime_error("range out of bounds");
                }

                this->end = lastSequenceItem + r.step;
            }
            else
            {
                this->width = (r.end - r.start - 1) / r.step + ((r.end - r.start - 1) % r.step != 0 ? 1 : 0);
                assert(this->width > 0);

                const int64_t lastSequenceItem = r.start + (this->width - 1) * r.step;
                if (lastSequenceItem < 0 || r.start >= upperBound)
                {
                    throw std::runtime_error("range out of bounds");
                }

                this->end = lastSequenceItem + r.step;
            }

            // normalize the range of width 1, as the step doesn't matter for it
            if (this->width == 1)
            {
                this->step = 1;
                this->end = this->start + 1;
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
    QirArray* quantum__rt__array_slice(QirArray* array, int32_t dim, const QirRange& qirRange) // NOLINT
    {
        assert(array != nullptr);
        assert(dim >= 0 && dim < array->dimensions);

        const int itemSizeInBytes = array->itemSizeInBytes;
        const int dimensions = array->dimensions;

        const CheckedRange range(qirRange, array->dimensionSizes[dim]);

        // If the range is empty, return an empty array of the same type but 0 items in dim dimension.
        if (range.IsEmpty())
        {
            std::vector<int64_t> dims = array->dimensionSizes;
            dims[dim] = 0;
            return new QirArray(0, itemSizeInBytes, dimensions, std::move(dims));
        }

        // When range covers the whole dimension, can return a copy of the array without doing any math.
        if (range.step == 1 && range.start == 0 && range.end == array->dimensionSizes[dim])
        {
            return quantum__rt__array_copy(array, true /*force*/);
        }

        // Create slice array of appropriate size.
        std::vector<int64_t> sliceDims = array->dimensionSizes;
        sliceDims[dim] = range.width;
        const int64_t sliceItemsCount =
            std::accumulate(sliceDims.begin(), sliceDims.end(), 1, std::multiplies<int64_t>());
        QirArray* slice = new QirArray(sliceItemsCount, itemSizeInBytes, dimensions, std::move(sliceDims));

        const int64_t singleIndexRunCount = RunCount(array->dimensionSizes, dim);
        const int64_t rowCount = singleIndexRunCount * array->dimensionSizes[dim];

        // When range is continuous, can copy data in larger chunks. For example, if the slice is on dim = 0,
        // we will copy exactly once.
        if (range.step == 1)
        {
            const int64_t rangeRunCount = singleIndexRunCount * (range.end - range.start);
            const int64_t rangeChunkSize = rangeRunCount * itemSizeInBytes;

            int64_t dst = 0;
            int64_t src = singleIndexRunCount * range.start;
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
        const int64_t chunkSize = singleIndexRunCount * itemSizeInBytes;
        int64_t dst = 0;
        int64_t src = singleIndexRunCount * range.start;
        while (src < array->count)
        {
            assert(dst < slice->count);

            int64_t srcInner = src;
            for (long index = range.start; index != range.end; index += range.step)
            {
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
    QirArray* quantum__rt__array_project(QirArray* array, int dim, int64_t index) // NOLINT
    {
        assert(array != nullptr);
        assert(dim >= 0 && dim < array->dimensions);
        assert(array->dimensions > 1); // cannot project from 1D array into an array
        assert(index >= 0 && index < array->dimensionSizes[dim]);

        const int itemSizeInBytes = array->itemSizeInBytes;
        const int dimensions = array->dimensions;

        // Create projected array of appropriate size.
        std::vector<int64_t> projectDims = array->dimensionSizes;
        projectDims.erase(projectDims.begin() + dim);

        const int64_t projectItemsCount =
            std::accumulate(projectDims.begin(), projectDims.end(), 1, std::multiplies<int64_t>());
        QirArray* project = new QirArray(projectItemsCount, itemSizeInBytes, dimensions - 1, std::move(projectDims));

        const int64_t singleIndexRunCount = RunCount(array->dimensionSizes, dim);
        const int64_t rowCount = singleIndexRunCount * array->dimensionSizes[dim];
        const int64_t chunkSize = singleIndexRunCount * itemSizeInBytes;

        int64_t dst = 0;
        int64_t src = singleIndexRunCount * index;
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
