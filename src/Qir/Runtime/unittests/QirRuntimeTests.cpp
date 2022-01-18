// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "catch.hpp"

#include <algorithm>
#include <cstring> // for memcpy
#include <memory>
#include <unordered_map>
#include <vector>

#include "QirTypes.hpp"
#include "qsharp__foundation__qis.hpp"
#include "qsharp__core__qis.hpp"
#include "QirRuntime.hpp"

#include "QirContext.hpp"
#include "SimulatorStub.hpp"

using namespace Microsoft::Quantum;

static constexpr bool forceNewInstance = true;

struct ResultsReferenceCountingTestQAPI : public SimulatorStub
{
    int lastId = -1;
    const int maxResults; // TODO: Use unsigned type.
    std::vector<bool> allocated;

    static int GetResultId(Result r)
    {
        return static_cast<int>(reinterpret_cast<int64_t>(r));
    }

    ResultsReferenceCountingTestQAPI(int maxRes) : maxResults(maxRes), allocated((size_t)maxRes, false)
    {
    }

    Result Measure(long, PauliId[], long, QubitIdType[]) override
    {
        assert(this->lastId < this->maxResults);
        this->lastId++;
        this->allocated.at((size_t)(this->lastId)) = true;
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
        REQUIRE(this->allocated.at((size_t)id));
        this->allocated.at((size_t)id).flip();
    }
    bool AreEqualResults(Result r1, Result r2) override
    {
        return (r1 == r2);
    }

    bool HaveResultsInFlight() const
    {
        for (const auto b : this->allocated)
        {
            if (b)
            {
                return true;
            }
        }
        return false;
    }
};
TEST_CASE("Results: comparison and reference counting", "[qir_support]")
{
    std::unique_ptr<ResultsReferenceCountingTestQAPI> qapi = std::make_unique<ResultsReferenceCountingTestQAPI>(3);
    QirExecutionContext::Scoped qirctx(qapi.get());

    Result r1 = qapi->Measure(0, nullptr, 0, nullptr); // we don't need real qubits for this test
    Result r2 = qapi->Measure(0, nullptr, 0, nullptr);
    REQUIRE(__quantum__rt__result_equal(r1, r1));
    REQUIRE(!__quantum__rt__result_equal(r1, r2));

    // release result that has never been shared, the test QAPI will verify double release
    __quantum__rt__result_update_reference_count(r2, -1);

    // share a result a few times
    __quantum__rt__result_update_reference_count(r1, 2);

    Result r3 = qapi->Measure(0, nullptr, 0, nullptr);

    // release shared result, the test QAPI will verify double release
    __quantum__rt__result_update_reference_count(r1, -3); // one release for shared and for the original allocation

    REQUIRE(qapi->HaveResultsInFlight()); // r3 should be still alive
    __quantum__rt__result_update_reference_count(r3, -1);

    REQUIRE(!qapi->HaveResultsInFlight()); // no leaks
}

TEST_CASE("Arrays: one dimensional", "[qir_support]")
{
    QirArray* a = __quantum__rt__array_create_1d(sizeof(char), 5);

    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 0), "H", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 1), "e", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 2), "l", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 3), "l", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 4), "o", 1);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(a, 4) == 'o');
    REQUIRE(__quantum__rt__array_get_size_1d(a) == 5);

    QirArray* b                                    = __quantum__rt__array_create_1d(sizeof(char), 1);
    *__quantum__rt__array_get_element_ptr_1d(b, 0) = '!';

    QirArray* ab = __quantum__rt__array_concatenate(a, b);
    REQUIRE(__quantum__rt__array_get_size_1d(ab) == 6);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(ab, 4) == 'o');
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(ab, 5) == '!');

    __quantum__rt__array_update_reference_count(a, -1);
    __quantum__rt__array_update_reference_count(b, -1);
    __quantum__rt__array_update_reference_count(ab, -1);
}

TEST_CASE("Arrays: copy elision", "[qir_support]")
{
    QirArray* a = __quantum__rt__array_create_1d(sizeof(char), 5);
    // the `a` array contains garbage but for this test we don't care

    // no aliases for the array, copy should be elided unless enforced
    QirArray* copy = __quantum__rt__array_copy(a, false);
    CHECK(a == copy);
    __quantum__rt__array_update_reference_count(copy, -1);

    // single alias for the array, but copy enforced
    copy = __quantum__rt__array_copy(a, true);
    CHECK(a != copy);
    __quantum__rt__array_update_reference_count(copy, -1);

    // existing aliases for the array -- cannot elide copy
    __quantum__rt__array_update_alias_count(a, 1);
    copy = __quantum__rt__array_copy(a, false);
    CHECK(a != copy);
    __quantum__rt__array_update_reference_count(copy, -1);
    __quantum__rt__array_update_alias_count(a, -1);

    __quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: empty", "[qir_support]")
{
    QirArray* a = __quantum__rt__array_create_1d(sizeof(char), 0);
    REQUIRE(__quantum__rt__array_get_size_1d(a) == 0);

    QirArray* a1 = __quantum__rt__array_copy(a, true);
    REQUIRE(__quantum__rt__array_get_size_1d(a1) == 0);
    __quantum__rt__array_update_reference_count(a1, -1);

    QirArray* c = __quantum__rt__array_create_1d(sizeof(char), 5);
    memcpy(__quantum__rt__array_get_element_ptr_1d(c, 0), "h", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(c, 1), "e", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(c, 2), "l", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(c, 3), "l", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(c, 4), "o", 1);
    QirArray* ac = __quantum__rt__array_concatenate(a, c);
    REQUIRE(__quantum__rt__array_get_size_1d(ac) == 5);
    QirArray* ca = __quantum__rt__array_concatenate(c, a);
    REQUIRE(__quantum__rt__array_get_size_1d(ca) == 5);

    __quantum__rt__array_update_reference_count(a, -1);
    __quantum__rt__array_update_reference_count(ac, -1);
    __quantum__rt__array_update_reference_count(ca, -1);
    __quantum__rt__array_update_reference_count(c, -1);
}

TEST_CASE("Arrays: slice of 1D array", "[qir_support]")
{
    const int64_t dim = 5;
    QirArray* a       = __quantum__rt__array_create_1d(sizeof(char), dim);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 0), "0", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 1), "1", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 2), "2", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 3), "3", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 4), "4", 1);
    QirArray* slice = nullptr;

    // even if slice results in a single value, it's still an array
    slice = quantum__rt__array_slice_1d(a, {1, 2 * dim, dim}, forceNewInstance);
    REQUIRE(__quantum__rt__array_get_size_1d(slice) == 1);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 0) == '1');
    __quantum__rt__array_update_reference_count(slice, -1);

    // if the range covers the whole array, it's effectively a copy
    slice = quantum__rt__array_slice_1d(a, {0, 1, dim - 1}, forceNewInstance);
    REQUIRE(__quantum__rt__array_get_size_1d(slice) == dim);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 0) == '0');
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 4) == '4');
    __quantum__rt__array_update_reference_count(slice, -1);

    // disconnected slice (also check that the end of range can be above bounds as long as the generated sequence is
    // within them)
    slice = quantum__rt__array_slice_1d(a, {0, 4, dim + 1}, forceNewInstance);
    REQUIRE(__quantum__rt__array_get_size_1d(slice) == 2);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 0) == '0');
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 1) == '4');
    __quantum__rt__array_update_reference_count(slice, -1);

    __quantum__rt__array_update_reference_count(a, -1);
}

TEST_CASE("Arrays: reversed slice of 1D array", "[qir_support]")
{
    const int64_t dim = 5;
    QirArray* a       = __quantum__rt__array_create_1d(sizeof(char), dim);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 0), "0", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 1), "1", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 2), "2", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 3), "3", 1);
    memcpy(__quantum__rt__array_get_element_ptr_1d(a, 4), "4", 1);
    QirArray* slice = nullptr;

    // even if slice results in a single value, it's still an array
    slice = quantum__rt__array_slice_1d(a, {1, -dim, 0}, forceNewInstance);
    // Range{1, -dim, 0} == Range{1, -5, 0} == { 1 }.
    // slice == char[1] == { '1' }.
    REQUIRE(__quantum__rt__array_get_size_1d(slice) == 1);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 0) == '1');
    __quantum__rt__array_update_reference_count(slice, -1); // slice == dangling pointer.

    // reversed slices are alwayes disconnected
    slice = quantum__rt__array_slice_1d(a, {dim - 1, -2, 0}, forceNewInstance);
    // Range{dim - 1, -2, 0} == Range{4, -2, 0} == {4, 2, 0}.
    // slice == char[3] == {'4', '2', '0'}.
    REQUIRE(__quantum__rt__array_get_size_1d(slice) == 3);
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 0) == '4');
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 1) == '2');
    REQUIRE(*__quantum__rt__array_get_element_ptr_1d(slice, 2) == '0');
    __quantum__rt__array_update_reference_count(slice, -1);

    __quantum__rt__array_update_reference_count(a, -1);
}

std::unordered_map<std::string, QirString*>& AllocatedStrings();
TEST_CASE("Strings: reuse", "[qir_support]")
{
    QirString* a = __quantum__rt__string_create("abc");
    QirString* b = __quantum__rt__string_create("abc");
    QirString* c = __quantum__rt__string_create("xyz");

    REQUIRE(__quantum__rt__string_equal(a, b));
    REQUIRE(!__quantum__rt__string_equal(a, c));

    __quantum__rt__string_update_reference_count(a, -1);

    __quantum__rt__string_update_reference_count(b, -1);
    __quantum__rt__string_update_reference_count(c, -1);
}

TEST_CASE("Strings: concatenate", "[qir_support]")
{
    QirString* a          = __quantum__rt__string_create("abc");
    QirString* b          = __quantum__rt__string_create("xyz");
    QirString* abExpected = __quantum__rt__string_create("abcxyz");

    QirString* ab = __quantum__rt__string_concatenate(a, b);
    REQUIRE(__quantum__rt__string_equal(ab, abExpected));

    QirString* aa         = __quantum__rt__string_concatenate(a, a);
    QirString* aaExpected = __quantum__rt__string_create("abcabc");
    REQUIRE(__quantum__rt__string_equal(aa, aaExpected));

    __quantum__rt__string_update_reference_count(a, -1);
    __quantum__rt__string_update_reference_count(b, -1);
    __quantum__rt__string_update_reference_count(abExpected, -1);
    __quantum__rt__string_update_reference_count(ab, -1);
    __quantum__rt__string_update_reference_count(aa, -1);
    __quantum__rt__string_update_reference_count(aaExpected, -1);
}

TEST_CASE("Strings: conversions from built-in types", "[qir_support]")
{
    std::vector<QirString*> strings;

    strings.push_back(__quantum__rt__int_to_string(0));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("0"));

    strings.push_back(__quantum__rt__int_to_string(42));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("42"));

    strings.push_back(__quantum__rt__int_to_string(-42));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("-42"));

    strings.push_back(__quantum__rt__double_to_string(4.2));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("4.2")); // platform dependent?

    strings.push_back(__quantum__rt__double_to_string(42.0));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("42.0"));

    strings.push_back(__quantum__rt__double_to_string(1e-9));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("0.000000001"));

    strings.push_back(__quantum__rt__double_to_string(0.0));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("0.0"));

    strings.push_back(__quantum__rt__double_to_string(-42.0));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("-42.0"));

    strings.push_back(__quantum__rt__double_to_string(-0.0));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("-0.0"));

    strings.push_back(__quantum__rt__bool_to_string(false));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("false"));

    strings.push_back(__quantum__rt__bool_to_string(true));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("true"));

    strings.push_back(__quantum__rt__pauli_to_string(PauliId_I));
    REQUIRE(__quantum__rt__string_get_data(strings.back()) == std::string("PauliI"));

    for (QirString* qstr : strings)
    {
        __quantum__rt__string_update_reference_count(qstr, -1);
    }
}

TEST_CASE("Strings: conversions from custom qir types", "[qir_support]")
{
    QirString* qstr1 = quantum__rt__range_to_string({0, 1, 42});
    REQUIRE(__quantum__rt__string_get_data(qstr1) == std::string("0..42"));

    QirString* qstr2 = quantum__rt__range_to_string({0, 3, 42});
    REQUIRE(__quantum__rt__string_get_data(qstr2) == std::string("0..3..42"));

    __quantum__rt__string_update_reference_count(qstr1, -1);
    __quantum__rt__string_update_reference_count(qstr2, -1);
}

struct QubitTestQAPI : public SimulatorStub
{
    int lastId = -1;     // TODO: Use unsigned type.
    const int maxQubits; // TODO: Use unsigned type.
    std::vector<bool> allocated;

    static QubitIdType GetQubitId(QubitIdType q)
    {
        return q;
    }

    QubitTestQAPI(int maxQbits) : maxQubits(maxQbits), allocated((size_t)maxQbits, false)
    {
    }

    QubitIdType AllocateQubit() override
    {
        assert(this->lastId < this->maxQubits);
        this->lastId++;
        this->allocated.at((size_t)(this->lastId)) = true;
        return static_cast<QubitIdType>(this->lastId);
    }
    void ReleaseQubit(QubitIdType qubit) override
    {
        const QubitIdType id = GetQubitId(qubit);
        INFO(id);
        REQUIRE(this->allocated.at(static_cast<size_t>(id)));
        this->allocated.at(static_cast<size_t>(id)).flip();
    }
    std::string QubitToString(QubitIdType qubit) override
    {
        const QubitIdType id = GetQubitId(qubit);
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
        for (const auto b : this->allocated)
        {
            if (b)
            {
                return true;
            }
        }
        return false;
    }
};
TEST_CASE("Qubits: allocate, release, dump", "[qir_support]")
{
    std::unique_ptr<QubitTestQAPI> qapi = std::make_unique<QubitTestQAPI>(4);
    QirExecutionContext::Scoped qirctx(qapi.get());
    QirString* qstr = nullptr;

    QUBIT* q = __quantum__rt__qubit_allocate();
    qstr     = __quantum__rt__qubit_to_string(q);
    REQUIRE(__quantum__rt__string_get_data(qstr) == std::string("0"));
    __quantum__rt__string_update_reference_count(qstr, -1);
    __quantum__rt__qubit_release(q);
    REQUIRE(!qapi->HaveQubitsInFlight());

    QirArray* qs = __quantum__rt__qubit_allocate_array(3);

    QUBIT* last = *reinterpret_cast<QUBIT**>(__quantum__rt__array_get_element_ptr_1d(qs, 2));
    qstr        = __quantum__rt__qubit_to_string(last);
    REQUIRE(__quantum__rt__string_get_data(qstr) == std::string("3"));
    __quantum__rt__string_update_reference_count(qstr, -1);

    QirArray* copy = __quantum__rt__array_copy(qs, true);

    __quantum__rt__qubit_release_array(qs); // The `qs` is a dangling pointer from now on.
    REQUIRE(!qapi->HaveQubitsInFlight());

    __quantum__rt__array_update_reference_count(copy, -1);
}

QirTupleHeader* FlattenControlArrays(QirTupleHeader* nestedTuple, int depth);
struct ControlledCallablesTestSimulator : public SimulatorStub
{
    intptr_t lastId = -1;
    QubitIdType AllocateQubit() override
    {
        return static_cast<QubitIdType>(++this->lastId);
    }
    void ReleaseQubit(QubitIdType) override
    {
    }
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }
};

static void NoopCallableEntry(PTuple, PTuple, PTuple)
{
}

TEST_CASE("Callables: copy elision", "[qir_support]")
{
    QirExecutionContext::Scoped qirctx(nullptr, true);
    t_CallableEntry entries[4] = {NoopCallableEntry, nullptr, nullptr, nullptr};

    QirCallable* original = __quantum__rt__callable_create(entries, nullptr, nullptr);

    QirCallable* self = __quantum__rt__callable_copy(original, false);
    CHECK(self == original);

    QirCallable* other1 = __quantum__rt__callable_copy(original, true);
    CHECK(other1 != original);

    __quantum__rt__callable_update_alias_count(original, 1);
    QirCallable* other2 = __quantum__rt__callable_copy(original, false);
    CHECK(other2 != original);
    __quantum__rt__callable_update_alias_count(original, -1);

    __quantum__rt__callable_update_reference_count(original, -1);
    __quantum__rt__callable_update_reference_count(self, -1);
    __quantum__rt__callable_update_reference_count(other1, -1);
    __quantum__rt__callable_update_reference_count(other2, -1);
}

TEST_CASE("Tuples: copy elision", "[qir_support]")
{
    PTuple original = __quantum__rt__tuple_create(1);

    PTuple self = __quantum__rt__tuple_copy(original, false);
    CHECK(self == original);

    PTuple other1 = __quantum__rt__tuple_copy(original, true);
    CHECK(other1 != original);

    __quantum__rt__tuple_update_alias_count(original, 1);
    PTuple other2 = __quantum__rt__tuple_copy(original, false);
    CHECK(other2 != original);
    __quantum__rt__tuple_update_alias_count(original, -1);

    __quantum__rt__tuple_update_reference_count(original, -1);
    __quantum__rt__tuple_update_reference_count(self, -1);
    __quantum__rt__tuple_update_reference_count(other1, -1);
    __quantum__rt__tuple_update_reference_count(other2, -1);
}

// Adjoints for R and Exp are implemented by qis, so let's check they at least do the angle invertion in adjoints.
struct AdjointsTestSimulator : public SimulatorStub
{
    QubitIdType lastId   = -1;
    double rotationAngle = 0.0;
    double exponentAngle = 0.0;

    QubitIdType AllocateQubit() override
    {
        return ++this->lastId;
    }
    void ReleaseQubit(QubitIdType) override
    {
    }
    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }
    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }

    void R(PauliId, QubitIdType, double theta) override
    {
        this->rotationAngle += theta;
    }
    void Exp(long count, PauliId* paulis, QubitIdType*, double theta) override
    {
        this->exponentAngle += theta;

        // check that paulis were unpacked correctly (this assumes that the tests always invoke with the same axes)
        REQUIRE(count == 2);
        CHECK(paulis[0] == PauliId_Z);
        CHECK(paulis[1] == PauliId_Y);
    }
    void ControlledR(long, QubitIdType*, PauliId, QubitIdType, double theta) override
    {
        this->rotationAngle += theta;
    }
    void ControlledExp(long, QubitIdType*, long count, PauliId* paulis, QubitIdType*, double theta) override
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
    QirExecutionContext::Scoped qirctx(qapi.get());

    const double angle = 0.42;

    QUBIT* target   = __quantum__rt__qubit_allocate();
    QirArray* ctrls = __quantum__rt__qubit_allocate_array(2);

    __quantum__qis__r__body(PauliId_Y, angle, target);
    __quantum__qis__r__adj(PauliId_Y, angle, target);
    QirRTuple args = {PauliId_X, angle, target};
    __quantum__qis__r__ctl(ctrls, &args);
    __quantum__qis__r__ctladj(ctrls, &args);

    __quantum__rt__qubit_release_array(ctrls); // The `ctrls` is a dangling pointer from now on.
    __quantum__rt__qubit_release(target);

    REQUIRE(qapi->rotationAngle == Approx(0).epsilon(0.0001));
}

TEST_CASE("Adjoints of Exp should use inverse of the angle", "[qir_support]")
{
    std::unique_ptr<AdjointsTestSimulator> qapi = std::make_unique<AdjointsTestSimulator>();
    QirExecutionContext::Scoped qirctx(qapi.get());

    const double angle = 0.42;

    QirArray* targets = __quantum__rt__qubit_allocate_array(2);
    QirArray* ctrls   = __quantum__rt__qubit_allocate_array(2);
    QirArray* axes    = __quantum__rt__array_create_1d(1, 2);
    *reinterpret_cast<PauliId*>(__quantum__rt__array_get_element_ptr_1d(axes, 0)) = PauliId_Z;
    *reinterpret_cast<PauliId*>(__quantum__rt__array_get_element_ptr_1d(axes, 1)) = PauliId_Y;

    __quantum__qis__exp__body(axes, angle, targets);
    __quantum__qis__exp__adj(axes, angle, targets);
    QirExpTuple args = {axes, angle, targets};
    __quantum__qis__exp__ctl(ctrls, &args);
    __quantum__qis__exp__ctladj(ctrls, &args);

    __quantum__rt__array_update_reference_count(axes, -1);
    __quantum__rt__qubit_release_array(ctrls);   // The `ctrls` is a dangling pointer from now on.
    __quantum__rt__qubit_release_array(targets); // The `targets` is a dangling pointer from now on.

    REQUIRE(qapi->exponentAngle == Approx(0).epsilon(0.0001));
}
