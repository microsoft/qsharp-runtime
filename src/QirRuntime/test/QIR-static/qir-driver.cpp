#include <assert.h>
#include <bitset>
#include <iostream>
#include <memory>
#include <string>
#include <unordered_set>

#include "CoreTypes.hpp"
#include "IQuantumApi.hpp"
#include "QuantumApiBase.hpp"
#include "SimFactory.hpp"
#include "__quantum__rt.hpp"
#include "qirTypes.hpp"

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

using namespace Microsoft::Quantum;
using namespace std;

// Can manually add calls to DebugLog in the ll files for debugging.
extern "C" void DebugLog(int64_t value)
{
    std::cout << value << std::endl;
}
extern "C" void DebugLogPtr(char* value)
{
    std::cout << (const void*)value << std::endl;
}

/*
    state1__count is the number of entries in the state1 array of integers.
    state1 is an array of indices into the qubit array that get Xs applied to them in the state prep.
        All of the entries in this array must be zero or greater and must be less than ops__count.
    state2__count is the number of entries in the state2 array of integers.
    state2 is an array of indices into the qubit array that get Xs applied to them in the state prep in a slightly
        different context than those in state1 (but I'm not sure it actually makes a difference). All of the entries in
        this array must be zero or greater and must be less than ops__count.
    phase is a Z rotation applied within the state preparation.
    ops__count is the number of entries in the ops array of Pauli operators.
        This will also be the number of qubits allocated for the state, plus two auxiliary qubits.
    ops is an array of 2-bit Paulis -- which I think the LLVM generator should promote (in the entry point) to an array
        of bytes, but which the generated code is treating as if it were an array of bytes, so it should actually be OK
        I think. The actual expectation value that's measured is the parity of the product of these Paulis, with any
        that are 0 (identity) skipped.
    coeff is a simple multiplier of the measurement expectation to get the energy contribution.
    nSamples is how many times to run the prepare-measure loop.
*/
extern "C" double Sample_VQE_EstimateTermExpectation( // NOLINT
    int64_t state1Count,
    int64_t* state1,
    int64_t state2Count,
    int64_t* state2,
    double phase,
    int64_t opsCount,
    int8_t* ops,
    double coeff,
    int64_t nSamples);
double EstimateTermExpectation(
    int cState1,
    int64_t* state1,
    int cState2,
    int64_t* state2,
    double phase,
    int cOps,
    int8_t* ops,
    double coeff,
    int nSamples);
TEST_CASE("QIR: VQE with full state simulator", "[qir]")
{
    unique_ptr<IQuantumApi> qapi = CreateFullstateSimulator();
    SetCurrentQuantumApiForQIR(qapi.get());

    // PauliId_Z = 2
    int8_t ops[3] = {2, 2, 2};
    const double phase = 0.0;
    const double coeff = 4.2;

    int64_t state1[1] = {0};
    int64_t state2[2] = {1, 2};

    SECTION("Running QIR against the simulator (even)")
    {
        const double ret1 = Sample_VQE_EstimateTermExpectation(1, state1, 1, state2, phase, 3, ops, coeff, 1);
        CHECK(ret1 == coeff);
    }
    SECTION("Running QIR against the simulator (odd)")
    {
        const double ret2 = Sample_VQE_EstimateTermExpectation(1, state1, 2, state2, 0.0, 3, ops, coeff, 1);
        CHECK(ret2 == -coeff);
    }
    SECTION("Running against the simulator natively (even)")
    {
        const double ret1 = EstimateTermExpectation(1, state1, 1, state2, phase, 3, ops, coeff, 1);
        CHECK(ret1 == coeff);
    }
    SECTION("Running against the simulator natively (odd)")
    {
        const double ret2 = EstimateTermExpectation(1, state1, 2, state2, 0.0, 3, ops, coeff, 1);
        CHECK(ret2 == -coeff);
    }

    // State of the simulator should be fully reset now
    qapi->GetState([](size_t idx, double re, double im) {
        INFO(std::string("|") + std::to_string(idx) + ">:" + std::to_string(re) + "+" + std::to_string(im) + "i");
        if (idx == 0)
        {
            CHECK(re * re + im * im == 1.0);
        }
        else
        {
            CHECK(re * re + im * im == 0);
        }
        return true;
    });

    SetCurrentQuantumApiForQIR(nullptr);
}

extern "C" int64_t Microsoft_Quantum_Testing_QIR_Test_Arrays( // NOLINT
    int64_t cValues,
    double* values,
    double increment,
    int64_t turns);
TEST_CASE("QIR: Using arrays", "[qir]")
{
    constexpr int64_t n = 3;
    double values[n] = {-5, -3, -1};

    // A single turn consists of incrementing all values in the array by the given increment value
    // and calculating the difference between the number of positive and negative resulting values.

    long res1 = Microsoft_Quantum_Testing_QIR_Test_Arrays(n, values, 2 /*increment*/, 1 /*turns*/);
    INFO("Array test for one turn");
    REQUIRE(res1 == -1);

    long res2 = Microsoft_Quantum_Testing_QIR_Test_Arrays(n, values, 2 /*increment*/, 2 /*turns*/);
    INFO("Array test for two turns");
    REQUIRE(res2 == 0);

    long res3 = Microsoft_Quantum_Testing_QIR_Test_Arrays(n, values, 2 /*increment*/, 3 /*turns*/);
    INFO("Array test for three turns");
    REQUIRE(res3 == 3);

    long res = Microsoft_Quantum_Testing_QIR_Test_Arrays(n, values, 0 /*increment*/, 10 /*turns*/);
    INFO("Array test result for 10 turns without increment");
    REQUIRE(res == -3 * 10);
}

#ifdef _WIN32
// A non-sensical function that creates a 3D array with given dimensions, then projects on the index = 1 of the
// second dimension and returns a function of the sizes of the dimensions of the projection and a the provided value,
// that is written to the original array at [1,1,1] and then retrieved from [1,1].
// Thus, all three dimensions must be at least 2.
extern "C" int64_t TestMultidimArrays(char value, int64_t dim0, int64_t dim1, int64_t dim2);
TEST_CASE("QIR: multidimensional arrays", "[qir]")
{
    REQUIRE(42 + (2 + 8) / 2 == TestMultidimArrays(42, 2, 4, 8));
    REQUIRE(17 + (3 + 7) / 2 == TestMultidimArrays(17, 3, 5, 7));
}
#else // not _WIN32
// TODO: The bridge for variadic functions is broken on Linux!
#endif

// Microsoft__Quantum__Testing__QIR__TestRange__body, defined in ll file uses %Range type which has identical layout
// to the Range struct defined below. Because Clang doesn't check return/arg types of IR functions, the call will
// compile and populate resulting Range correctly.
struct Range
{
    int64_t start;
    int64_t step;
    int64_t end;
};
extern "C" Range Microsoft__Quantum__Testing__QIR__TestRange__body(); // NOLINT
TEST_CASE("QIR: Using range to slice 1D array", "[qir]")
{
    Range range = Microsoft__Quantum__Testing__QIR__TestRange__body();

    REQUIRE(range.start == 0);
    REQUIRE(range.step == 2);
    REQUIRE(range.end == 6);
}

// Manually authored QIR to test dumping range [0..2..6] into string and then raising a failure with it
extern "C" void TestFailWithRangeString(int64_t start, int64_t step, int64_t end);
TEST_CASE("QIR: Report range in a failure message", "[qir]")
{
    bool failed = false;
    try
    {
        TestFailWithRangeString(0, 5, 42);
    }
    catch (const std::exception& e)
    {
        failed = true;
        REQUIRE(std::string(e.what()) == "0..5..42");
    }
    REQUIRE(failed);
}

// Autogenerated QIR for partial application of callables. It applies rotation operator and then its adjoint to a qubit
// and returns "true" if the measurement produces zero (expected).
extern "C" bool Microsoft__Quantum__Testing__QIR__TestPartials__body(); // NOLINT
struct CallablesTestQAPI : public Microsoft::Quantum::CQuantumApiBase
{
    int lastId = -1;
    const int maxQubits;
    vector<double> rotations;

    static bool AreApproximatelyEqual(double x, double y)
    {
        return std::abs(x - y) < 0.01;
    }

    static int GetQubitId(Qubit qubit)
    {
        return static_cast<int>(reinterpret_cast<int64_t>(qubit));
    }

    CallablesTestQAPI(int maxQubits)
        : maxQubits(maxQubits)
        , rotations(maxQubits, 0.0)
    {
    }

    Qubit AllocateQubit() override
    {
        assert(this->lastId < this->maxQubits);
        this->lastId++;
        return reinterpret_cast<Qubit>(this->lastId);
    }

    void ReleaseQubit(Qubit qubit) override
    {
        const int id = GetQubitId(qubit);
        assert(id < this->maxQubits);
        assert(AreApproximatelyEqual(0.0, this->rotations[id]));
        this->rotations[id] = 0.0;
    }

    void R(PauliId axis, Qubit qubit, double theta) override
    {
        assert(axis == PauliId_Z);
        const int id = GetQubitId(qubit);
        assert(id < this->maxQubits);
        this->rotations[id] += theta;
    }

    Result M(Qubit qubit) override
    {
        const int id = GetQubitId(qubit);
        assert(id < this->maxQubits);
        const int result = (AreApproximatelyEqual(0.0, this->rotations[id]) ? Result_Zero : Result_Pending);
        return reinterpret_cast<Result>(result);
    }

    TernaryBool AreEqualResults(Result r1, Result r2) override
    {
        // those are bogus pointers but it's ok to compare them _as pointers_
        return r1 == r2 ? TernaryBool_True : TernaryBool_False;
    }

    void ReleaseResult(Result result) override {} // the results aren't allocated by this test simulator

    Result UseZero() override
    {
        return reinterpret_cast<Result>(Result_Zero);
    }

    Result UseOne() override
    {
        return reinterpret_cast<Result>(Result_One);
    }
};
TEST_CASE("QIR: Partial application of a callable", "[qir]")
{
    unique_ptr<CallablesTestQAPI> qapi = make_unique<CallablesTestQAPI>(101);
    SetCurrentQuantumApiForQIR(qapi.get());
    REQUIRE(Microsoft__Quantum__Testing__QIR__TestPartials__body());
    SetCurrentQuantumApiForQIR(nullptr);
}


struct ControlFunctorTestQAPI : public Microsoft::Quantum::CQuantumApiBase
{
    int lastId = -1;
    std::unordered_set<int> releasedQubits;

    static int GetQubitId(Qubit qubit)
    {
        return static_cast<int>(reinterpret_cast<int64_t>(qubit));
    }

    bool IsValid(Qubit qubit) const
    {
        const int id = GetQubitId(qubit);
        return id >= 0 && id <= this->lastId && this->releasedQubits.count(id) == 0;
    }

    Qubit AllocateQubit() override
    {
        return reinterpret_cast<Qubit>(++this->lastId);
    }

    void ReleaseQubit(Qubit qubit) override
    {
        REQUIRE(IsValid(qubit));
        releasedQubits.insert(GetQubitId(qubit));
    }

    Result M(Qubit qubit) override
    {
        return UseZero();
    }

    TernaryBool AreEqualResults(Result r1, Result r2) override
    {
        // those are bogus pointers but it's ok to compare them _as pointers_
        return r1 == r2 ? TernaryBool_True : TernaryBool_False;
    }

    void ReleaseResult(Result result) override {} // the results aren't allocated by this test simulator

    Result UseZero() override
    {
        return reinterpret_cast<Result>(Result_Zero);
    }

    Result UseOne() override
    {
        return reinterpret_cast<Result>(Result_One);
    }

    void K(Qubit q, int t)
    {
        std::cout << "K invoked on: " << GetQubitId(q) << std::endl;
        CHECK(IsValid(q));
    }

    void ControlledK(int cc, Qubit* controls, Qubit q, int t)
    {
        std::cout << "ControlledK invoked on: " << GetQubitId(q) << std::endl;
        CHECK(IsValid(q));

        std::cout << " with " << cc << " controls: ";
        
        for (int i = 0; i < cc; i++)
        {
            std::cout << GetQubitId(controls[i]) << ",";
            CHECK(IsValid(controls[i]));
        }
        std::cout << std::endl;
    }
};
ControlFunctorTestQAPI* g_ctrqapi = nullptr;
extern "C" bool Microsoft__Quantum__Testing__QIR__TestControlled__body(); // NOLINT
extern "C" void quantum__qis__k(Qubit q, int t)                           // NOLINT
{
    g_ctrqapi->K(q, t);
}
extern "C" void quantum__qis__ck(QirArray* controls, Qubit q, int t) // NOLINT
{
    g_ctrqapi->ControlledK(controls->count, reinterpret_cast<Qubit*>(controls->buffer), q, t);
}
TEST_CASE("QIR: application of controlled functor", "[skip]")
{
    unique_ptr<ControlFunctorTestQAPI> qapi = make_unique<ControlFunctorTestQAPI>();
    SetCurrentQuantumApiForQIR(qapi.get());
    g_ctrqapi = qapi.get();

    REQUIRE(Microsoft__Quantum__Testing__QIR__TestControlled__body());

    SetCurrentQuantumApiForQIR(nullptr);
    g_ctrqapi = nullptr;
}