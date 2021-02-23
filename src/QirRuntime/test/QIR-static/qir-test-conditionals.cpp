// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cassert>
#include <iostream>
#include <vector>

#include "catch.hpp"

#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimulatorStub.hpp"

using namespace std;
using namespace Microsoft::Quantum;

// TestConditionalOnResult() is authored in a way that the expected path through the function only applies X operator
// for the chosen sequence of measurement results, and all other paths apply Y. Thus, the correct execution must get the
// expected maximum number of X and ControlledX callbacks.
struct ConditionalsTestSimulator : public Microsoft::Quantum::SimulatorStub
{
    int cX = 0;
    int ccX = 0;

    vector<ResultValue> mockMeasurements;
    int nMeasure = -1;

    explicit ConditionalsTestSimulator(vector<ResultValue>&& results)
        : mockMeasurements(results)
    {
    }

    Qubit AllocateQubit() override
    {
        return nullptr;
    }
    void ReleaseQubit(Qubit qubit) override {}

    void X(Qubit) override
    {
        this->cX++;
    }
    void ControlledX(long numControls, Qubit controls[], Qubit qubit) override
    {
        this->ccX++;
    }
    void Y(Qubit) override {}

    Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
    {
        this->nMeasure++;
        assert(this->nMeasure < this->mockMeasurements.size() && "ConditionalsTestSimulator isn't set up correctly");

        return (this->mockMeasurements[this->nMeasure] == Result_Zero) ? UseZero() : UseOne();
    }

    bool AreEqualResults(Result r1, Result r2) override
    {
        // those are bogus pointers but it's ok to compare them _as pointers_
        return (r1 == r2);
    }

    void ReleaseResult(Result result) override {} // the results aren't allocated by this test simulator

    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }

    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }
};

extern "C" void Microsoft__Quantum__Testing__QIR__TestApplyIf__body(); // NOLINT
TEST_CASE("QIR: ApplyIf", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirContextScope qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestApplyIf__body());
    CHECK(qapi->cX == 10);
    CHECK(qapi->ccX == 7);
}

extern "C" void Microsoft__Quantum__Testing__QIR__TestApplyConditionally__body(); // NOLINT
TEST_CASE("QIR: ApplyConditionally", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirContextScope qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestApplyConditionally__body());
    CHECK(qapi->cX == 4);
    CHECK(qapi->ccX == 2);
}

extern "C" void Microsoft__Quantum__Testing__QIR__TestConditionalRewrite__body(); // NOLINT
TEST_CASE("QIR: conditionals on measurement results", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirContextScope qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestConditionalRewrite__body());
    CHECK(qapi->cX == 1);
    CHECK(qapi->ccX == 1);
}