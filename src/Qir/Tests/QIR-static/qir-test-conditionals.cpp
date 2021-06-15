// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cassert>
#include <iostream>
#include <sstream>
#include <vector>

#include "catch.hpp"

#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QirRuntimeApi_I.hpp"
#include "SimulatorStub.hpp"

using namespace std;
using namespace Microsoft::Quantum;

// TestConditionalOnResult() is authored in a way that the expected path through the function only applies X operator
// for the chosen sequence of measurement results, and all other paths apply Y. Thus, the correct execution must get the
// expected maximum number of X and ControlledX callbacks.
struct ConditionalsTestSimulator : public Microsoft::Quantum::SimulatorStub
{
    int nGateCallback = 0;
    vector<int> xCallbacks;
    vector<int> cxCallbacks;
    vector<int> otherCallbacks;

    vector<ResultValue> mockMeasurements;
    int nextMeasureResult = 0;

    explicit ConditionalsTestSimulator(vector<ResultValue>&& results)
        : mockMeasurements(results)
    {
    }

    std::string GetHistory()
    {
        std::stringstream out;
        out << "X: ";
        for (int i : this->xCallbacks)
        {
            out << i << ",";
        }

        out << std::endl << "CX: ";
        for (int i : this->cxCallbacks)
        {
            out << i << ",";
        }

        out << std::endl << "Other: ";
        for (int i : this->otherCallbacks)
        {
            out << i << ",";
        }
        return out.str();
    }

    Qubit AllocateQubit() override
    {
        return nullptr;
    }
    void ReleaseQubit(Qubit /*qubit*/) override {}

    void X(Qubit) override
    {
        this->xCallbacks.push_back(this->nGateCallback);
        this->nGateCallback++;
    }
    void ControlledX(long /* numControls */, Qubit* /* controls */, Qubit /* qubit */) override
    {
        this->cxCallbacks.push_back(this->nGateCallback);
        this->nGateCallback++;
    }
    void Y(Qubit) override
    {
        this->otherCallbacks.push_back(this->nGateCallback);
        this->nGateCallback++;
    }
    void ControlledY(long /* numControls */, Qubit* /* controls */, Qubit /* qubit */) override
    {
        this->otherCallbacks.push_back(this->nGateCallback);
        this->nGateCallback++;
    }

    Result Measure(long /* numBases */, PauliId* /* bases */, long /* numTargets */, Qubit* /* targets */) override
    {
        assert(
            (size_t)(this->nextMeasureResult) < this->mockMeasurements.size() &&
            "ConditionalsTestSimulator isn't set up correctly");

        Result r = (this->mockMeasurements[this->nextMeasureResult] == Result_Zero) ? UseZero() : UseOne();
        this->nextMeasureResult++;
        return r;
    }

    bool AreEqualResults(Result r1, Result r2) override
    {
        // those are bogus pointers but it's ok to compare them _as pointers_
        return (r1 == r2);
    }

    void ReleaseResult(Result /*result*/) override {} // the results aren't allocated by this test simulator

    Result UseZero() override
    {
        return reinterpret_cast<Result>(0);
    }

    Result UseOne() override
    {
        return reinterpret_cast<Result>(1);
    }
};

extern "C" void Microsoft__Quantum__Testing__QIR__TestApplyIf__Interop(); // NOLINT
TEST_CASE("QIR: ApplyIf", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirExecutionContext::Scoped qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestApplyIf__Interop());

    INFO(qapi->GetHistory());
    CHECK(qapi->xCallbacks.size() == 8);
    CHECK(qapi->cxCallbacks.size() == 0);
    CHECK(qapi->otherCallbacks.size() == 0);
}

extern "C" void Microsoft__Quantum__Testing__QIR__TestApplyIfWithFunctors__Interop(); // NOLINT
TEST_CASE("QIR: ApplyIf with functors", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirExecutionContext::Scoped qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestApplyIfWithFunctors__Interop());

    INFO(qapi->GetHistory());
    CHECK(qapi->xCallbacks.size() == 5);
    CHECK(qapi->cxCallbacks.size() == 7);
    CHECK(qapi->otherCallbacks.size() == 0);
}

extern "C" void Microsoft__Quantum__Testing__QIR__TestApplyConditionally__Interop(); // NOLINT
TEST_CASE("QIR: ApplyConditionally", "[qir][qir.conditionals]")
{
    unique_ptr<ConditionalsTestSimulator> qapi =
        make_unique<ConditionalsTestSimulator>(vector<ResultValue>{Result_Zero, Result_One});
    QirExecutionContext::Scoped qirctx(qapi.get(), true /*trackAllocatedObjects*/);

    CHECK_NOTHROW(Microsoft__Quantum__Testing__QIR__TestApplyConditionally__Interop());

    INFO(qapi->GetHistory());
    CHECK(qapi->xCallbacks.size() == 4);
    CHECK(qapi->cxCallbacks.size() == 2);
    CHECK(qapi->otherCallbacks.size() == 0);
}
