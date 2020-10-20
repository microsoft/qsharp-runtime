// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <memory>
#include <vector>

#include "catch.hpp"

#include "ChunkedStore.hpp"
#include "SimFactory.hpp"
#include "QuantumApiBase.hpp"
#include "QubitAllocationPolicies.hpp"

using namespace Microsoft::Quantum;

class CDeferredResultsTestSimulator final : public CQuantumApiBase
{
    struct TestQubit
    {
        long id = -1;
        long gen = 0;
    };
    struct DeferredResult
    {
        long id = -1;
        TestQubit* qubit = nullptr;
        long gen = -1;
        ResultValue value = Result_Pending;
    };

    CReuseLastReleasedQubitAllocationPolicy qubitIdsManager;
    CChunkedStore<TestQubit> store;

    CReuseLastReleasedQubitAllocationPolicy resultIdsManager;
    CChunkedStore<DeferredResult> results;

    void ClearResult(DeferredResult* tr)
    {
        tr->qubit = nullptr;
        tr->gen = -1;
        tr->value = Result_Pending;
    }

  public:
    void FinalizeMeasurement(Result result)
    {
        // real simulators/emulators would do something smart here, but we will
        // do a simple deterministic "finalization" to enable the tests
        DeferredResult* r = reinterpret_cast<DeferredResult*>(result);
        r->value = (r->gen == 0) ? Result_Zero : Result_One;
        r->qubit = nullptr;
        r->gen = -1;
    }

    void H(Qubit qubit) override
    {
        TestQubit* tq = reinterpret_cast<TestQubit*>(qubit);
        tq->gen++;
    }

    Result M(Qubit qubit) override
    {
        TestQubit* tq = reinterpret_cast<TestQubit*>(qubit);
        DeferredResult* r = this->results.Allocate(this->resultIdsManager.AcquireId());
        r->qubit = tq;
        r->gen = tq->gen;
        return reinterpret_cast<Result>(r);
    }

    void ReleaseResult(Result result) override
    {
        DeferredResult* r = reinterpret_cast<DeferredResult*>(result);
        ClearResult(r);
        this->results.Release(r);
        this->resultIdsManager.ReleaseId(r->id);
    }

    TernaryBool AreEqualResults(Result r1, Result r2) override
    {
        if (r1 == r2)
        {
            return TernaryBool_True;
        }

        DeferredResult* tr1 = reinterpret_cast<DeferredResult*>(r1);
        DeferredResult* tr2 = reinterpret_cast<DeferredResult*>(r2);

        // both measurements have been finalized
        if (tr1->qubit == nullptr && tr2->qubit == nullptr)
        {
            return tr1->value == tr2->value ? TernaryBool_True : TernaryBool_False;
        }

        // both measurements are deferred
        if (tr1->qubit != nullptr && tr2->qubit != nullptr)
        {
            assert(tr1->gen != -1 && tr2->gen != -1);
            if (tr1->qubit == tr2->qubit && tr1->gen == tr2->gen)
            {
                return TernaryBool_True;
            }
        }

        return TernaryBool_Undefined;
    }

    ResultValue GetResultValue(Result result) override
    {
        DeferredResult* tr = reinterpret_cast<DeferredResult*>(result);
        return tr->value;
    }

    Qubit AllocateQubit() override
    {
        return reinterpret_cast<Qubit>(this->store.Allocate(this->qubitIdsManager.AcquireId()));
    }

    void ReleaseQubit(Qubit qubit) override
    {
        // could probably do something smart with the deferred results for this qubit
        TestQubit* tq = reinterpret_cast<TestQubit*>(qubit);
        this->store.Release(tq);
        this->qubitIdsManager.ReleaseId(tq->id);
    }
};

TEST_CASE("Measure before and after applying a gate", "[deferred_results]")
{
    std::unique_ptr<IQuantumApi> iqa = std::make_unique<CDeferredResultsTestSimulator>();

    Qubit q = iqa->AllocateQubit();

    Result r1 = iqa->M(q);
    Result r2 = iqa->M(q);
    iqa->H(q);
    Result r3 = iqa->M(q);

    REQUIRE(iqa->AreEqualResults(r1, r2) == TernaryBool_True);
    REQUIRE(iqa->AreEqualResults(r2, r3) == TernaryBool_Undefined);
}

TEST_CASE("Finalize measurement results", "[deferred_results]")
{
    std::unique_ptr<CDeferredResultsTestSimulator> sim = std::make_unique<CDeferredResultsTestSimulator>();
    IQuantumApi* iqa = sim.get();

    Qubit q = iqa->AllocateQubit();

    Result r1 = iqa->M(q);
    iqa->H(q);
    Result r2 = iqa->M(q);

    sim->FinalizeMeasurement(r1);
    REQUIRE(iqa->GetResultValue(r1) == Result_Zero);
    REQUIRE(iqa->AreEqualResults(r1, r2) == TernaryBool_Undefined);

    sim->FinalizeMeasurement(r2);
    REQUIRE(iqa->GetResultValue(r2) == Result_One);
    REQUIRE(iqa->AreEqualResults(r1, r2) == TernaryBool_False);
}