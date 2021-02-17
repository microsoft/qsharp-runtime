// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "catch.hpp"

#include <algorithm>
#include <memory>
#include <string.h> // for memcpy
#include <unordered_map>
#include <vector>

#include "qirTypes.hpp"
#include "quantum__qis.hpp"
#include "quantum__rt.hpp"

#include "BitStates.hpp"
#include "SimulatorStub.hpp"
#include "context.hpp"

using namespace Microsoft::Quantum;

struct ResultsReferenceCountingTestQAPI : public SimulatorStub
{
    int lastId = 1;
    const int maxResults;
    BitStates allocated;

    static int GetResultId(Result r)
    {
        return static_cast<int>(reinterpret_cast<int64_t>(r));
    }

    ResultsReferenceCountingTestQAPI(int maxResults)
        : maxResults(maxResults + 2)
    {
        allocated.ExtendToInclude(maxResults);
    }

    Result M(Qubit) override
    {
        assert(this->lastId < this->maxResults);
        this->lastId++;
        this->allocated.SetBitAt(this->lastId);
        return reinterpret_cast<Result>(this->lastId);
    }
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }
    void ReleaseResult(Result result) override
    {
        const int id = GetResultId(result);
        INFO(id);
        REQUIRE(this->allocated.IsBitSetAt(id));
        this->allocated.FlipBitAt(id);
    }
    bool AreEqualResults(Result r1, Result r2) override
    {
        return (r1 == r2);
    }

    bool HaveResultsInFlight() const
    {
        return this->allocated.IsAny();
    }
};
TEST_CASE("Results: comparison and reference counting", "[qir_support]")
{
    std::unique_ptr<ResultsReferenceCountingTestQAPI> qapi = std::make_unique<ResultsReferenceCountingTestQAPI>(3);
    QirContextScope qirctx(qapi.get());

    Result r1 = qapi->M(nullptr); // we don't need real qubits for this test
    Result r2 = qapi->M(nullptr);
    REQUIRE(quantum__rt__result_equal(r1, r1));
    REQUIRE(!quantum__rt__result_equal(r1, r2));

    // release result that has never been shared, the test QAPI will verify double release
    quantum__rt__result_update_reference_count(r2, -1);

    // share a result a few times
    quantum__rt__result_update_reference_count(r1, 2);

    Result r3 = qapi->M(nullptr);

    // release shared result, the test QAPI will verify double release
    quantum__rt__result_update_reference_count(r1, -3); // one release for shared and for the original allocation

    REQUIRE(qapi->HaveResultsInFlight()); // r3 should be still alive
    quantum__rt__result_update_reference_count(r3, -1);

    REQUIRE(!qapi->HaveResultsInFlight()); // no leaks
}

TEST_CASE("Arrays: one dimensional", "[qir_support]")
{
    QirContextScope qirctx(nullptr);
    QirArray* a = quantum__rt__array_create_1d(sizeof(char), 5);

    memcpy(a->buffer, "Hello", 5);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(a, 4) == 'o');
    REQUIRE(quantum__rt__array_get_dim(a) == 1);
    REQUIRE(quantum__rt__array_get_size(a, 0) == 5);

    QirArray* b = new QirArray(1, sizeof(char));
    *quantum__rt__array_get_element_ptr_1d(b, 0) = '!';

    QirArray* ab = quantum__rt__array_concatenate(a, b);
    REQUIRE(quantum__rt__array_get_size(ab, 0) == 6);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(ab, 4) == 'o');
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(ab, 5) == '!');

    quantum__rt__array_update_reference_count(a, -1);
    quantum__rt__array_update_reference_count(b, -1);
    quantum__rt__array_update_reference_count(ab, -1);
}

TEST_CASE("Arrays: multiple dimensions", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int64_t count = 5 * 3 * 4; // 60
    QirArray* a = quantum__rt__array_create(sizeof(int), 3, (int64_t)5, (int64_t)3, (int64_t)4);
    REQUIRE(quantum__rt__array_get_dim(a) == 3);
    REQUIRE(quantum__rt__array_get_size(a, 0) == 5);
    REQUIRE(quantum__rt__array_get_size(a, 1) == 3);
    REQUIRE(quantum__rt__array_get_size(a, 2) == 4);

    std::vector<int> data(count, 0);
    for (int i = 0; i < count; i++)
    {
        data[i] = i;
    }
    // 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [0 - 11]
    // 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [12 - 23]
    // ...                                                    [24 - 35]
    // ...                                                    [36 - 47]
    // 400 401 402 403 | 410 411 412 413 | 420 421 422 423 -- [48 - 59]
    memcpy(a->buffer, reinterpret_cast<char*>(data.data()), count * sizeof(int));
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 0, 0, 1))) == 1);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 0, 1, 0))) == 4);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 1, 0, 0))) == 12);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 4, 2, 3))) == 59);

    QirArray* b = quantum__rt__array_copy(a, true /*force*/);
    *(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(b, 1, 2, 3))) = 42;
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 1, 2, 3))) == 23);

    quantum__rt__array_update_reference_count(a, -1);
    quantum__rt__array_update_reference_count(b, -1);
}

TEST_CASE("Arrays: copy elision", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    QirArray* copy = quantum__rt__array_copy(nullptr, true /*force*/);
    CHECK(copy == nullptr);

    QirArray* a = quantum__rt__array_create_1d(sizeof(char), 5);
    // the `a` array contains garbage but for this test we don't care

    // no aliases for the array, copy should be elided unless enforced
    copy = quantum__rt__array_copy(a, false /*force*/);
    CHECK(a == copy);
    quantum__rt__array_update_reference_count(copy, -1);

    // single alias for the array, but copy enforced
    copy = quantum__rt__array_copy(a, true /*force*/);
    CHECK(a != copy);
    quantum__rt__array_update_reference_count(copy, -1);

    // existing aliases for the array -- cannot elide copy
    quantum__rt__array_update_alias_count(a, 1);
    copy = quantum__rt__array_copy(a, false /*force*/);
    CHECK(a != copy);
    quantum__rt__array_update_reference_count(copy, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: empty", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    QirArray* b = quantum__rt__array_create(sizeof(int), 3, (int64_t)4, (int64_t)0, (int64_t)3);
    REQUIRE(quantum__rt__array_get_dim(b) == 3);
    REQUIRE(quantum__rt__array_get_size(b, 0) == 4);
    REQUIRE(quantum__rt__array_get_size(b, 1) == 0);
    REQUIRE(quantum__rt__array_get_size(b, 2) == 3);
    REQUIRE(b->buffer == nullptr);
    quantum__rt__array_update_reference_count(b, -1);

    QirArray* a = quantum__rt__array_create_1d(sizeof(char), 0);
    REQUIRE(quantum__rt__array_get_dim(a) == 1);
    REQUIRE(quantum__rt__array_get_size(a, 0) == 0);
    REQUIRE(a->buffer == nullptr);

    QirArray* a1 = quantum__rt__array_copy(a, true /*force*/);
    REQUIRE(quantum__rt__array_get_dim(a1) == 1);
    REQUIRE(quantum__rt__array_get_size(a1, 0) == 0);
    REQUIRE(a1->buffer == nullptr);
    quantum__rt__array_update_reference_count(a1, -1);

    QirArray* c = quantum__rt__array_create_1d(sizeof(char), 5);
    memcpy(c->buffer, "hello", 5);
    QirArray* ac = quantum__rt__array_concatenate(a, c);
    REQUIRE(quantum__rt__array_get_size(ac, 0) == 5);
    QirArray* ca = quantum__rt__array_concatenate(c, a);
    REQUIRE(quantum__rt__array_get_size(ca, 0) == 5);

    quantum__rt__array_update_reference_count(a, -1);
    quantum__rt__array_update_reference_count(ac, -1);
    quantum__rt__array_update_reference_count(ca, -1);
}

TEST_CASE("Arrays: check the slice range", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int64_t dim0 = 5;
    const int64_t dim1 = 6;
    QirArray* a = quantum__rt__array_create(sizeof(int), 2, dim0, dim1);
    QirArray* slice = nullptr;

    // invalid range
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {0, 0, 0}));

    // violated bounds
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0, 1, dim0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 1, {0, 1, dim1}));
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {-1, 1, dim0 - 1}));

    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0, -1, dim0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 1, {dim1, -1, 0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0 - 1, -1, -1}));

    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0, 3, dim0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 1, {0, 3, dim1 + 2}));
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {-1, 3, dim0 - 1}));

    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0, -3, dim0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 1, {dim1, -3, 0}));
    CHECK_THROWS(quantum__rt__array_slice(a, 0, {dim0 - 1, -3, -3}));

    // empty range should produce empty array
    slice = quantum__rt__array_slice(a, 0, {dim0 - 1, 1, 0});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    quantum__rt__array_update_reference_count(slice, -1);

    slice = quantum__rt__array_slice(a, 1, {0, -1, dim0 - 1});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == 0);
    quantum__rt__array_update_reference_count(slice, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: slice of 1D array", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int64_t dim = 5;
    QirArray* a = quantum__rt__array_create_1d(sizeof(char), dim);
    memcpy(a->buffer, "01234", 5);
    QirArray* slice = nullptr;

    // even if slice results in a single value, it's still an array
    slice = quantum__rt__array_slice(a, 0, {1, 2 * dim, dim});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 1);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 0) == '1');
    quantum__rt__array_update_reference_count(slice, -1);

    // if the range covers the whole array, it's effectively a copy
    slice = quantum__rt__array_slice(a, 0, {0, 1, dim - 1});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 0) == '0');
    REQUIRE(*quantum__rt__array_get_element_ptr(slice, 4) == '4');
    quantum__rt__array_update_reference_count(slice, -1);

    // disconnected slice (also check that the end of range can be above bounds as long as the generated sequence is
    // within them)
    slice = quantum__rt__array_slice(a, 0, {0, 4, dim + 1});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 2);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 0) == '0');
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 1) == '4');
    quantum__rt__array_update_reference_count(slice, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: reversed slice of 1D array", "[qir_support]")
{
    QirContextScope qirctx(nullptr);
    const int64_t dim = 5;
    QirArray* a = quantum__rt__array_create_1d(sizeof(char), dim);
    memcpy(a->buffer, "01234", 5);
    QirArray* slice = nullptr;

    // even if slice results in a single value, it's still an array
    slice = quantum__rt__array_slice(a, 0, {1, -dim, 0});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 1);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 0) == '1');
    quantum__rt__array_update_reference_count(slice, -1);

    // reversed slices are alwayes disconnected
    slice = quantum__rt__array_slice(a, 0, {dim - 1, -2, 0});
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 3);
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 0) == '4');
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 1) == '2');
    REQUIRE(*quantum__rt__array_get_element_ptr_1d(slice, 2) == '0');
    quantum__rt__array_update_reference_count(slice, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: slice of 3D array", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int32_t dims = 3;
    const int64_t dim0 = 5;
    const int64_t dim1 = 3;
    const int64_t dim2 = 4;

    QirArray* a = quantum__rt__array_create(sizeof(int), dims, dim0, dim1, dim2);
    QirArray* slice = nullptr;

    const int64_t count = dim0 * dim1 * dim2; // 60
    std::vector<int> data(count, 0);
    for (int i = 0; i < count; i++)
    {
        data[i] = i;
    }
    // indexes                                             -- values
    // 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [0 - 11]
    // 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [12 - 23]
    // ...                                                    [24 - 35]
    // ...                                                    [36 - 47]
    // 400 401 402 403 | 410 411 412 413 | 420 421 422 423 -- [48 - 59]
    memcpy(a->buffer, reinterpret_cast<char*>(data.data()), count * sizeof(int));
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 1, 0, 0))) == 12);
    REQUIRE(
        *(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, dim0 - 1, dim1 - 1, dim2 - 1))) == count - 1);

    // if the range covers the whole dimension, it's effectively a copy
    slice = quantum__rt__array_slice(a, 1, {0, 1, dim1 - 1});
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 1, 0, 0))) == 12);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 2, 3))) == 59);
    quantum__rt__array_update_reference_count(slice, -1);

    // if the range consists of a single point, the slice still has the same dimensions
    slice = quantum__rt__array_slice(a, 1, {1, 2 * dim1, dim1}); // items with second index = 1
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == 1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 4);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 0, 3))) == 55);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on 0 dimension
    slice = quantum__rt__array_slice(a, 0, {1, 1, 3}); // items with first index = 1, 2 or 3
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 3);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 12);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 2, 2, 3))) == 47);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on last dimension, expected result:
    // indexes                                             -- values
    // 000 001 | 010 011 | 020 021 -- [ 1  2 |  5  6 |  9 10]
    // 100 101 | 110 111 | 120 121 -- [13 14 | 17 18 | 21 22]
    // ...                            [25 ...               ]
    // ...                            [37 ...               ]
    // 400 401 | 410 411 | 420 421 -- [49 50 | 53 54 | 57 58]
    slice = quantum__rt__array_slice(a, 2, {1, 1, 2}); // items with last index = 1 or 2
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == 2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 1);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 2, 1))) == 10);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 1, 1, 1))) == 18);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 2, 1))) == 58);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on sparse range in 0 dimension (also check that the end of range can be above bounds as long as the
    // generated sequence is within them)
    slice = quantum__rt__array_slice(a, 0, {0, 3, dim0}); // items with first index = 0 or 3
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 2);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 0);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 1, 2, 3))) == 47);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on sparse range in the middle dimension
    slice = quantum__rt__array_slice(a, 1, {0, 2, 2}); // items with second index = 0 or 2
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == 2);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 0);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 1, 3))) == 59);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on sparse range in the last dimension
    // indexes                                             -- values
    // 000 001 | 010 011 | 020 021 -- [01 03 | 05 07 | 09 11]
    // 100 101 | 110 111 | 120 121 -- [13 15 | 17 19 | 21 23]
    // ...                         -- [25 ...               ]
    // ...                         -- [37 ...               ]
    // 400 401 | 410 411 | 420 421 -- [49 51 | 53 55 | 57 59]
    slice = quantum__rt__array_slice(a, 2, {1, 2, 3}); // items with last index = 1 or 3 (all odd numbers)
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == 2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 1);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 2, 1))) == 11);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 1, 1, 0))) == 17);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 2, 1))) == 59);
    quantum__rt__array_update_reference_count(slice, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: reversed slice of 3D array", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int32_t dims = 3;
    const int64_t dim0 = 5;
    const int64_t dim1 = 3;
    const int64_t dim2 = 4;

    QirArray* a = quantum__rt__array_create(sizeof(int), dims, dim0, dim1, dim2);
    QirArray* slice = nullptr;

    const int64_t count = dim0 * dim1 * dim2; // 60
    std::vector<int> data(count, 0);
    for (int i = 0; i < count; i++)
    {
        data[i] = i;
    }
    // indexes                                             -- values
    // 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [0 - 11]
    // 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [12 - 23]
    // ...                                                    [24 - 35]
    // ...                                                    [36 - 47]
    // 400 401 402 403 | 410 411 412 413 | 420 421 422 423 -- [48 - 59]
    memcpy(a->buffer, reinterpret_cast<char*>(data.data()), count * sizeof(int));
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 1, 0, 0))) == 12);
    REQUIRE(
        *(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, dim0 - 1, dim1 - 1, dim2 - 1))) == count - 1);

    // if the range consists of a single point, the slice still has the same dimensions
    slice = quantum__rt__array_slice(a, 1, {1, -dim1, 0}); // items with second index = 1
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == 1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 4);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 0, 3))) == 55);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on dim0, expect the result to look like:
    // indexes                                             -- values
    // 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [36 - 47]
    // 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [24 - 35]
    // 200 201 202 203 | 210 211 212 213 | 220 221 222 223 -- [12 - 23]
    slice = quantum__rt__array_slice(a, 0, {dim0 - 2, -1, 1});
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == 3);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 36);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 2, 2, 3))) == 23);
    quantum__rt__array_update_reference_count(slice, -1);

    // slice on last dimension, expect the result to look like:
    // indexes                                             -- values
    // 000 001 | 010 011 | 020 021 -- [03 01 | 07 05 | 11 09]
    // 100 101 | 110 111 | 120 121 -- [15 13 | 19 17 | 23 21]
    // ...                         -- [27 ...               ]
    // ...                         -- [39 ...               ]
    // 400 401 | 410 411 | 420 421 -- [51 49 | 55 53 | 59 57]
    slice = quantum__rt__array_slice(a, 2, {dim2 - 1, -2, 0}); // items with last index 3, 1 (all odd numbers)
    REQUIRE(quantum__rt__array_get_dim(slice) == dims);
    REQUIRE(quantum__rt__array_get_size(slice, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(slice, 1) == dim1);
    REQUIRE(quantum__rt__array_get_size(slice, 2) == 2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 0, 0))) == 3);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 0, 2, 1))) == 9);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 1, 1, 0))) == 19);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(slice, 4, 2, 1))) == 57);
    quantum__rt__array_update_reference_count(slice, -1);
}

TEST_CASE("Arrays: project of 3D array", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    const int32_t dims = 3;
    const int64_t dim0 = 5;
    const int64_t dim1 = 3;
    const int64_t dim2 = 4;

    QirArray* a = quantum__rt__array_create(sizeof(int), dims, dim0, dim1, dim2);
    QirArray* project = nullptr;

    const int64_t count = dim0 * dim1 * dim2; // 60
    std::vector<int> data(count, 0);
    for (int i = 0; i < count; i++)
    {
        data[i] = i;
    }
    // indexes                                             -- values
    // 000 001 002 003 | 010 011 012 013 | 020 021 022 023 -- [0 - 11]
    // 100 101 102 103 | 110 111 112 113 | 120 121 122 123 -- [12 - 23]
    // ...                                                    [24 - 35]
    // ...                                                    [36 - 47]
    // 400 401 402 403 | 410 411 412 413 | 420 421 422 423 -- [48 - 59]
    memcpy(a->buffer, reinterpret_cast<char*>(data.data()), count * sizeof(int));
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, 1, 0, 0))) == 12);
    REQUIRE(
        *(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(a, dim0 - 1, dim1 - 1, dim2 - 1))) == count - 1);

    // project on 0 dimension, expected result:
    // indexes                                 -- values
    // 00 01 02 03 | 10 11 12 13 | 20 21 22 23 -- [12 - 23]
    project = quantum__rt__array_project(a, 0, 1); // items with first index = 1
    REQUIRE(quantum__rt__array_get_dim(project) == dims - 1);
    REQUIRE(quantum__rt__array_get_size(project, 0) == dim1);
    REQUIRE(quantum__rt__array_get_size(project, 1) == dim2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 0, 0))) == 12);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 1, 1))) == 17);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 2, 3))) == 23);
    quantum__rt__array_update_reference_count(project, -1);

    // project on last dimension, expected result:
    // indexes         -- values
    // 00 | 01 | 02 -- [02 06 10]
    // 10 | 11 | 12 -- [14 18 22]
    // ...          -- [26 30 34]
    // ...          -- [38 42 46]
    // 40 | 41 | 42 -- [50 54 58]
    project = quantum__rt__array_project(a, 2, 2); // items with last index = 2
    REQUIRE(quantum__rt__array_get_dim(project) == dims - 1);
    REQUIRE(quantum__rt__array_get_size(project, 0) == dim0);
    REQUIRE(quantum__rt__array_get_size(project, 1) == dim1);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 0, 0, 0))) == 2);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 1, 1, 2))) == 18);
    REQUIRE(*(reinterpret_cast<int*>(quantum__rt__array_get_element_ptr(project, 4, 2, 2))) == 58);
    quantum__rt__array_update_reference_count(project, -1);

    quantum__rt__array_update_reference_count(a, -1);
}

std::unordered_map<std::string, QirString*>& AllocatedStrings();
TEST_CASE("Strings: reuse", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    QirString* a = quantum__rt__string_create("abc");
    QirString* b = quantum__rt__string_create("abc");
    QirString* c = quantum__rt__string_create("xyz");

    REQUIRE(a == b);
    REQUIRE(a->refCount == 2);
    REQUIRE(a != c);
    REQUIRE(c->refCount == 1);

    quantum__rt__string_update_reference_count(a, -1);
    REQUIRE(b->str.compare("abc") == 0);

    quantum__rt__string_update_reference_count(b, -1);
    quantum__rt__string_update_reference_count(c, -1);

    REQUIRE(AllocatedStrings().empty());
}

TEST_CASE("Strings: concatenate", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    QirString* a = quantum__rt__string_create("abc");
    QirString* b = quantum__rt__string_create("xyz");
    QirString* abExpected = quantum__rt__string_create("abcxyz");

    QirString* ab = quantum__rt__string_concatenate(a, b);
    REQUIRE(ab == abExpected);

    QirString* aa = quantum__rt__string_concatenate(a, a);
    REQUIRE(aa->str.compare("abcabc") == 0);

    quantum__rt__string_update_reference_count(a, -1);
    quantum__rt__string_update_reference_count(b, -1);
    quantum__rt__string_update_reference_count(abExpected, -1);
    quantum__rt__string_update_reference_count(ab, -1);
    quantum__rt__string_update_reference_count(aa, -1);

    REQUIRE(AllocatedStrings().empty());
}

TEST_CASE("Strings: conversions from built-in types", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    std::vector<QirString*> strings;

    strings.push_back(quantum__rt__int_to_string(0));
    REQUIRE(strings.back()->str == std::string("0"));

    strings.push_back(quantum__rt__int_to_string(42));
    REQUIRE(strings.back()->str == std::string("42"));

    strings.push_back(quantum__rt__int_to_string(-42));
    REQUIRE(strings.back()->str == std::string("-42"));

    strings.push_back(quantum__rt__double_to_string(4.2));
    REQUIRE(strings.back()->str == std::string("4.20000000000000018")); // platform dependent?

    strings.push_back(quantum__rt__double_to_string(42.0));
    REQUIRE(strings.back()->str == std::string("42.0"));

    strings.push_back(quantum__rt__double_to_string(1e-9));
    REQUIRE(strings.back()->str == std::string("0.000000001"));

    strings.push_back(quantum__rt__double_to_string(0.0));
    REQUIRE(strings.back()->str == std::string("0.0"));

    strings.push_back(quantum__rt__double_to_string(-42.0));
    REQUIRE(strings.back()->str == std::string("-42.0"));

    strings.push_back(quantum__rt__double_to_string(-0.0));
    REQUIRE(strings.back()->str == std::string("-0.0"));

    strings.push_back(quantum__rt__bool_to_string(false));
    REQUIRE(strings.back()->str == std::string("false"));

    strings.push_back(quantum__rt__bool_to_string(true));
    REQUIRE(strings.back()->str == std::string("true"));

    // strings, created by conversions are reused for each type
    strings.push_back(quantum__rt__int_to_string(0));
    REQUIRE(std::count(strings.begin(), strings.end(), strings.back()) == 2);

    strings.push_back(quantum__rt__double_to_string(42.0));
    REQUIRE(std::count(strings.begin(), strings.end(), strings.back()) == 2);

    strings.push_back(quantum__rt__bool_to_string(1));
    REQUIRE(std::count(strings.begin(), strings.end(), strings.back()) == 2);

    for (QirString* qstr : strings)
    {
        quantum__rt__string_update_reference_count(qstr, -1);
    }

    REQUIRE(AllocatedStrings().empty());
}

TEST_CASE("Strings: conversions from custom qir types", "[qir_support]")
{
    QirContextScope qirctx(nullptr);

    QirString* qstr1 = quantum__rt__range_to_string({0, 1, 42});
    REQUIRE(qstr1->str == std::string("0..42"));

    QirString* qstr2 = quantum__rt__range_to_string({0, 3, 42});
    REQUIRE(qstr2->str == std::string("0..3..42"));

    quantum__rt__string_update_reference_count(qstr1, -1);
    quantum__rt__string_update_reference_count(qstr2, -1);

    REQUIRE(AllocatedStrings().empty());
}

struct QubitTestQAPI : public SimulatorStub
{
    int lastId = -1;
    const int maxQubits;
    BitStates allocated;

    static int GetQubitId(Qubit q)
    {
        return static_cast<int>(reinterpret_cast<int64_t>(q));
    }

    QubitTestQAPI(int maxQubits)
        : maxQubits(maxQubits)
    {
        allocated.ExtendToInclude(maxQubits);
    }
    Qubit AllocateQubit() override
    {
        assert(this->lastId < this->maxQubits);
        this->lastId++;
        this->allocated.SetBitAt(this->lastId);
        return reinterpret_cast<Qubit>(this->lastId);
    }
    void ReleaseQubit(Qubit qubit) override
    {
        const int id = GetQubitId(qubit);
        INFO(id);
        REQUIRE(this->allocated.IsBitSetAt(id));
        this->allocated.FlipBitAt(id);
    }
    std::string QubitToString(Qubit qubit) override
    {
        const int id = GetQubitId(qubit);
        return std::to_string(id);
    }
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }

    bool HaveQubitsInFlight() const
    {
        return this->allocated.IsAny();
    }
};
TEST_CASE("Qubits: allocate, release, dump", "[qir_support]")
{
    std::unique_ptr<QubitTestQAPI> qapi = std::make_unique<QubitTestQAPI>(3);
    QirContextScope qirctx(qapi.get());
    QirString* qstr = nullptr;

    Qubit q = quantum__rt__qubit_allocate();
    qstr = quantum__rt__qubit_to_string(q);
    REQUIRE(qstr->str == std::string("0"));
    quantum__rt__string_update_reference_count(qstr, -1);
    quantum__rt__qubit_release(q);
    REQUIRE(!qapi->HaveQubitsInFlight());

    QirArray* qs = quantum__rt__qubit_allocate_array(3);
    REQUIRE(qs->ownsQubits);
    REQUIRE(qs->count == 3);
    REQUIRE(qs->itemSizeInBytes == sizeof(void*));

    Qubit last = *reinterpret_cast<Qubit*>(quantum__rt__array_get_element_ptr_1d(qs, 2));
    qstr = quantum__rt__qubit_to_string(last);
    REQUIRE(qstr->str == std::string("3"));
    quantum__rt__string_update_reference_count(qstr, -1);

    QirArray* copy = quantum__rt__array_copy(qs, true /*force*/);
    REQUIRE(!copy->ownsQubits);

    quantum__rt__qubit_release_array(qs);
    REQUIRE(!qapi->HaveQubitsInFlight());

    // both arrays now contain dangling pointers to qubits, but we still must release them
    quantum__rt__array_update_reference_count(qs, -1);
    quantum__rt__array_update_reference_count(copy, -1);
}

QirTupleHeader* FlattenControlArrays(QirTupleHeader* nestedTuple, int depth);
struct ControlledCallablesTestSimulator : public SimulatorStub
{
    int lastId = -1;
    Qubit AllocateQubit() override
    {
        return reinterpret_cast<Qubit>(++this->lastId);
    }
    void ReleaseQubit(Qubit qubit) override {}
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }
};
TEST_CASE("Unpacking input tuples of nested callables (case2)", "[qir_support]")
{
    std::unique_ptr<ControlledCallablesTestSimulator> qapi = std::make_unique<ControlledCallablesTestSimulator>();
    QirContextScope qirctx(qapi.get());

    Qubit target = quantum__rt__qubit_allocate();
    QirArray* controlsInner = quantum__rt__qubit_allocate_array(3);
    QirArray* controlsOuter = quantum__rt__qubit_allocate_array(2);

    PTuple inner = quantum__rt__tuple_create(sizeof(/*QirArrray*/ void*) + sizeof(/*Qubit*/ void*));
    TupleWithControls* innerWithControls = TupleWithControls::FromTuple(inner);
    innerWithControls->controls = controlsInner;
    *reinterpret_cast<Qubit*>(innerWithControls->AsTuple() + sizeof(/*QirArrray*/ void*)) = target;

    PTuple outer = quantum__rt__tuple_create(sizeof(/*QirArrray*/ void*) + sizeof(/*QirTupleHeader*/ void*));
    TupleWithControls* outerWithControls = TupleWithControls::FromTuple(outer);
    outerWithControls->controls = controlsOuter;
    outerWithControls->innerTuple = innerWithControls;

    QirTupleHeader* unpacked = FlattenControlArrays(outerWithControls->GetHeader(), 2 /*depth*/);
    QirArray* combined = *(reinterpret_cast<QirArray**>(unpacked->AsTuple()));
    REQUIRE(5 == combined->count);
    REQUIRE(!combined->ownsQubits);
    REQUIRE(target == *reinterpret_cast<Qubit*>(unpacked->AsTuple() + sizeof(/*QirArrray*/ void*)));

    unpacked->Release();
    quantum__rt__array_update_reference_count(combined, -1);
    quantum__rt__tuple_update_reference_count(outer, -1);
    quantum__rt__tuple_update_reference_count(inner, -1);

    // release the original resources
    quantum__rt__qubit_release_array(controlsOuter);
    quantum__rt__array_update_reference_count(controlsOuter, -1);
    quantum__rt__qubit_release_array(controlsInner);
    quantum__rt__array_update_reference_count(controlsInner, -1);
    quantum__rt__qubit_release(target);
}

TEST_CASE("Unpacking input tuples of nested callables (case1)", "[qir_support]")
{
    std::unique_ptr<ControlledCallablesTestSimulator> qapi = std::make_unique<ControlledCallablesTestSimulator>();
    QirContextScope qirctx(qapi.get());

    Qubit target = quantum__rt__qubit_allocate();
    QirArray* controlsInner = quantum__rt__qubit_allocate_array(3);
    QirArray* controlsOuter = quantum__rt__qubit_allocate_array(2);

    PTuple args = quantum__rt__tuple_create(+sizeof(/*Qubit*/ void*) + sizeof(int));
    *reinterpret_cast<Qubit*>(args) = target;
    *reinterpret_cast<int*>(args + sizeof(/*Qubit*/ void*)) = 42;

    PTuple inner = quantum__rt__tuple_create(sizeof(/*QirArrray*/ void*) + sizeof(/*Tuple*/ void*));
    TupleWithControls* innerWithControls = TupleWithControls::FromTuple(inner);
    innerWithControls->controls = controlsInner;
    *reinterpret_cast<PTuple*>(innerWithControls->AsTuple() + sizeof(/*QirArrray*/ void*)) = args;

    PTuple outer = quantum__rt__tuple_create(sizeof(/*QirArrray*/ void*) + sizeof(/*QirTupleHeader*/ void*));
    TupleWithControls* outerWithControls = TupleWithControls::FromTuple(outer);
    outerWithControls->controls = controlsOuter;
    outerWithControls->innerTuple = innerWithControls;

    QirTupleHeader* unpacked = FlattenControlArrays(outerWithControls->GetHeader(), 2 /*depth*/);
    QirArray* combined = *(reinterpret_cast<QirArray**>(unpacked->AsTuple()));
    REQUIRE(5 == combined->count);
    REQUIRE(!combined->ownsQubits);

    QirTupleHeader* unpackedArgs =
        QirTupleHeader::GetHeader(*reinterpret_cast<PTuple*>(unpacked->AsTuple() + sizeof(/*QirArrray*/ void*)));
    REQUIRE(target == *reinterpret_cast<Qubit*>(unpackedArgs->AsTuple()));
    REQUIRE(42 == *reinterpret_cast<int*>(unpackedArgs->AsTuple() + sizeof(/*Qubit*/ void*)));

    unpacked->Release();
    quantum__rt__array_update_reference_count(combined, -1);
    quantum__rt__tuple_update_reference_count(outer, -1);
    quantum__rt__tuple_update_reference_count(inner, -1);
    quantum__rt__tuple_update_reference_count(args, -1);

    // release the original resources
    quantum__rt__qubit_release_array(controlsOuter);
    quantum__rt__array_update_reference_count(controlsOuter, -1);
    quantum__rt__qubit_release_array(controlsInner);
    quantum__rt__array_update_reference_count(controlsInner, -1);
    quantum__rt__qubit_release(target);
}

TEST_CASE("Allocation tracking for arrays", "[qir_support]")
{
    InitializeQirContext(nullptr /*don't need a simulator*/, true /*track allocations*/);

    QirArray* bounce = quantum__rt__array_create_1d(1, 1);
    quantum__rt__array_update_reference_count(bounce, -1);
    CHECK_THROWS(quantum__rt__array_update_reference_count(bounce, 1));

    QirArray* releaseTwice = quantum__rt__array_create_1d(1, 1);
    quantum__rt__array_update_reference_count(releaseTwice, -1);
    CHECK_THROWS(quantum__rt__array_update_reference_count(releaseTwice, -1));

    QirArray* maybeLeaked = quantum__rt__array_create_1d(1, 1);
    CHECK_THROWS(ReleaseQirContext());

    quantum__rt__array_update_reference_count(maybeLeaked, -1);
    CHECK_NOTHROW(ReleaseQirContext());
}

TEST_CASE("Allocation tracking for tuples", "[qir_support]")
{
    InitializeQirContext(nullptr /*don't need a simulator*/, true /*track allocations*/);

    PTuple bounce = quantum__rt__tuple_create(1);
    quantum__rt__tuple_update_reference_count(bounce, -1);
    CHECK_THROWS(quantum__rt__tuple_update_reference_count(bounce, 1));

    PTuple releaseTwice = quantum__rt__tuple_create(1);
    quantum__rt__tuple_update_reference_count(releaseTwice, -1);
    CHECK_THROWS(quantum__rt__tuple_update_reference_count(releaseTwice, -1));

    PTuple maybeLeaked = quantum__rt__tuple_create(1);
    CHECK_THROWS(ReleaseQirContext());

    quantum__rt__tuple_update_reference_count(maybeLeaked, -1);
    CHECK_NOTHROW(ReleaseQirContext());
}

static void NoopCallableEntry(PTuple, PTuple, PTuple) {}
TEST_CASE("Allocation tracking for callables", "[qir_support]")
{
    t_CallableEntry entries[4] = {NoopCallableEntry, nullptr, nullptr, nullptr};

    InitializeQirContext(nullptr /*don't need a simulator*/, true /*track allocations*/);

    QirCallable* bounce =
        quantum__rt__callable_create(entries, nullptr /*capture callbacks*/, nullptr /*capture tuple*/);
    quantum__rt__callable_update_reference_count(bounce, -1);
    CHECK_THROWS(quantum__rt__callable_update_reference_count(bounce, 1));

    QirCallable* releaseTwice =
        quantum__rt__callable_create(entries, nullptr /*capture callbacks*/, nullptr /*capture tuple*/);
    quantum__rt__callable_update_reference_count(releaseTwice, -1);
    CHECK_THROWS(quantum__rt__callable_update_reference_count(releaseTwice, -1));

    QirCallable* maybeLeaked =
        quantum__rt__callable_create(entries, nullptr /*capture callbacks*/, nullptr /*capture tuple*/);
    CHECK_THROWS(ReleaseQirContext());

    quantum__rt__callable_update_reference_count(maybeLeaked, -1);
    CHECK_NOTHROW(ReleaseQirContext());
}

TEST_CASE("Callables: copy elision", "[qir_support]")
{
    QirContextScope qirctx(nullptr, true);
    t_CallableEntry entries[4] = {NoopCallableEntry, nullptr, nullptr, nullptr};

    QirCallable* original =
        quantum__rt__callable_create(entries, nullptr /*capture callbacks*/, nullptr /*capture tuple*/);

    QirCallable* self = quantum__rt__callable_copy(original, false);
    CHECK(self == original);

    QirCallable* other1 = quantum__rt__callable_copy(original, true);
    CHECK(other1 != original);

    quantum__rt__callable_update_alias_count(original, 1);
    QirCallable* other2 = quantum__rt__callable_copy(original, false);
    CHECK(other2 != original);
    quantum__rt__callable_update_alias_count(original, -1);

    quantum__rt__callable_update_reference_count(original, -1);
    quantum__rt__callable_update_reference_count(self, -1);
    quantum__rt__callable_update_reference_count(other1, -1);
    quantum__rt__callable_update_reference_count(other2, -1);
}

TEST_CASE("Tuples: copy elision", "[qir_support]")
{
    PTuple original = quantum__rt__tuple_create(1 /*size in bytes*/);

    PTuple self = quantum__rt__tuple_copy(original, false);
    CHECK(self == original);

    PTuple other1 = quantum__rt__tuple_copy(original, true);
    CHECK(other1 != original);

    quantum__rt__tuple_update_alias_count(original, 1);
    PTuple other2 = quantum__rt__tuple_copy(original, false);
    CHECK(other2 != original);
    quantum__rt__tuple_update_alias_count(original, -1);

    quantum__rt__tuple_update_reference_count(original, -1);
    quantum__rt__tuple_update_reference_count(self, -1);
    quantum__rt__tuple_update_reference_count(other1, -1);
    quantum__rt__tuple_update_reference_count(other2, -1);
}

// Adjoints for R and Exp are implemented by qis, so let's check they at least do the angle invertion in adjoints.
struct AdjointsTestSimulator : public SimulatorStub
{
    int lastId = -1;
    double rotationAngle = 0.0;
    double exponentAngle = 0.0;

    Qubit AllocateQubit() override
    {
        return reinterpret_cast<Qubit>(++this->lastId);
    }
    void ReleaseQubit(Qubit qubit) override {}
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }

    void R(PauliId, Qubit, double theta) override
    {
        this->rotationAngle += theta;
    }
    void Exp(long count, PauliId* paulis, Qubit*, double theta) override
    {
        this->exponentAngle += theta;

        // check that paulis were unpacked correctly (this assumes that the tests always invoke with the same axes)
        REQUIRE(count == 2);
        CHECK(paulis[0] == PauliId_Z);
        CHECK(paulis[1] == PauliId_Y);
    }
    void ControlledR(long, Qubit*, PauliId, Qubit, double theta) override
    {
        this->rotationAngle += theta;
    }
    void ControlledExp(long, Qubit*, long count, PauliId* paulis, Qubit*, double theta) override
    {
        this->exponentAngle += theta;

        // check that paulis were unpacked correctly (this assumes that the tests always invoke with the same axes)
        REQUIRE(count == 2);
        CHECK(paulis[0] == PauliId_Z);
        CHECK(paulis[1] == PauliId_Y);
    }
};
TEST_CASE("Adjoints of R should use inverse of the angle", "[qir_support]")
{
    std::unique_ptr<AdjointsTestSimulator> qapi = std::make_unique<AdjointsTestSimulator>();
    QirContextScope qirctx(qapi.get());

    const double angle = 0.42;

    Qubit target = quantum__rt__qubit_allocate();
    QirArray* ctrls = quantum__rt__qubit_allocate_array(2);

    quantum__qis__r__body(PauliId_Y, angle, target);
    quantum__qis__r__adj(PauliId_Y, angle, target);
    quantum__qis__r__ctl(ctrls, PauliId_X, angle, target);
    quantum__qis__r__ctladj(ctrls, PauliId_X, angle, target);

    quantum__rt__qubit_release_array(ctrls);
    quantum__rt__array_update_reference_count(ctrls, -1);
    quantum__rt__qubit_release(target);

    REQUIRE(qapi->rotationAngle == Approx(0).epsilon(0.0001));
}

TEST_CASE("Adjoints of Exp should use inverse of the angle", "[qir_support]")
{
    std::unique_ptr<AdjointsTestSimulator> qapi = std::make_unique<AdjointsTestSimulator>();
    QirContextScope qirctx(qapi.get());

    const double angle = 0.42;

    QirArray* targets = quantum__rt__qubit_allocate_array(2);
    QirArray* ctrls = quantum__rt__qubit_allocate_array(2);
    QirArray* axes = quantum__rt__array_create_1d(1 /*element size*/, 2 /*count*/);
    axes->buffer[0] = 2;
    axes->buffer[1] = 3;

    quantum__qis__exp__body(axes, angle, targets);
    quantum__qis__exp__adj(axes, angle, targets);
    quantum__qis__exp__ctl(ctrls, axes, angle, targets);
    quantum__qis__exp__ctladj(ctrls, axes, angle, targets);

    quantum__rt__qubit_release_array(ctrls);
    quantum__rt__array_update_reference_count(ctrls, -1);
    quantum__rt__qubit_release_array(targets);
    quantum__rt__array_update_reference_count(targets, -1);

    REQUIRE(qapi->exponentAngle == Approx(0).epsilon(0.0001));
}
