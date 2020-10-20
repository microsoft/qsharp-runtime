// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <memory>
#include <vector>

#include "catch.hpp"

#include "ExperimentalSimFactory.hpp"
#include "IQuantumApi.hpp"
#include "QuantumApiBase.hpp"

using namespace Microsoft::Quantum;
using namespace std;

struct CMockSimulatorForLockstepTests final : public CQuantumApiBase
{
    int qubitsAllocated = 0;
    int invokedX = 0;
    int invokedCX = 0;

    struct PresetResult
    {
        ResultValue value = Result_Pending;
    };
    vector<PresetResult> presetResults;

    CMockSimulatorForLockstepTests()
    {
        presetResults.reserve(8);
    }
    ~CMockSimulatorForLockstepTests() = default;

    Qubit AllocateQubit() override
    {
        qubitsAllocated++;
        return nullptr;
    }
    void ReleaseQubit(Qubit qubit) override {}

    void X(Qubit qubit) override
    {
        invokedX++;
    }

    void ControlledX(long numControls, Qubit controls[], Qubit target) override
    {
        invokedCX++;
    }

    Result M(Qubit target) override
    {
        if (this->presetResults.size() == 8)
        {
            throw std::runtime_error("results might be moved");
        }
        return reinterpret_cast<Result>(&this->presetResults.back());
    }
    ResultValue GetResultValue(Result result) override
    {
        return reinterpret_cast<PresetResult*>(result)->value;
    }
    TernaryBool AreEqualResults(Result r1, Result r2) override
    {
        ResultValue v1 = reinterpret_cast<PresetResult*>(r1)->value;
        ResultValue v2 = reinterpret_cast<PresetResult*>(r2)->value;

        return (v1 == Result_Pending || v2 == Result_Pending) ? TernaryBool_Undefined
                                                              : (v1 == v2) ? TernaryBool_True : TernaryBool_False;
    }
    Result UseZero() override
    {
        static PresetResult zero{Result_Zero};
        return reinterpret_cast<Result>(&zero);
    }
    Result UseOne() override
    {
        static PresetResult one{Result_One};
        return reinterpret_cast<Result>(&one);
    }
    void ReleaseResult(Result result) override {}
};

TEST_CASE("Correct number of delegated invocations", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();

    std::unique_ptr<IQuantumApi> iqaLockstep =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get()}, nullptr);
    Qubit q = iqaLockstep->AllocateQubit();
    iqaLockstep->X(q);
    iqaLockstep->X(q);

    REQUIRE(1 == iqa1->qubitsAllocated);
    REQUIRE(2 == iqa1->invokedX);

    REQUIRE(1 == iqa2->qubitsAllocated);
    REQUIRE(2 == iqa2->invokedX);
}

TEST_CASE("Delegation of controlled operation", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();

    std::unique_ptr<IQuantumApi> iqaLockstep =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get()}, nullptr);
    const int numQubits = 3;
    Qubit qubits[numQubits];
    for (int i = 0; i < numQubits; i++)
    {
        qubits[i] = iqaLockstep->AllocateQubit();
    }
    iqaLockstep->ControlledX(numQubits - 1, qubits, qubits[numQubits - 1]);

    REQUIRE(numQubits == iqa1->qubitsAllocated);
    REQUIRE(0 == iqa1->invokedX);
    REQUIRE(1 == iqa1->invokedCX);

    REQUIRE(numQubits == iqa2->qubitsAllocated);
    REQUIRE(0 == iqa2->invokedX);
    REQUIRE(1 == iqa2->invokedCX);
}

TEST_CASE("Comparing results", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();
    ResultValue resultValues[2];
    std::unique_ptr<IQuantumApi> iqaLockstep =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get()}, resultValues);

    Qubit q = iqaLockstep->AllocateQubit();

    iqa1->presetResults.push_back({Result_Zero});
    iqa2->presetResults.push_back({Result_Pending});
    volatile Result rPending = iqaLockstep->M(q);

    iqa1->presetResults.push_back({Result_One});
    iqa2->presetResults.push_back({Result_Zero});
    volatile Result rMixed = iqaLockstep->M(q);

    Result zero = iqaLockstep->UseZero();
    Result one = iqaLockstep->UseOne();

    REQUIRE(TernaryBool_Undefined == iqaLockstep->AreEqualResults(rPending, rPending));
    REQUIRE(TernaryBool_Undefined == iqaLockstep->AreEqualResults(rPending, rMixed));
    REQUIRE(TernaryBool_True == iqaLockstep->AreEqualResults(rMixed, rMixed));
    REQUIRE(TernaryBool_False == iqaLockstep->AreEqualResults(rMixed, zero));
    REQUIRE(TernaryBool_False == iqaLockstep->AreEqualResults(rMixed, one));
    REQUIRE(TernaryBool_True == iqaLockstep->AreEqualResults(zero, zero));
    REQUIRE(TernaryBool_False == iqaLockstep->AreEqualResults(zero, one));

    iqaLockstep->ReleaseResult(rPending);
    iqaLockstep->ReleaseResult(rMixed);
}

TEST_CASE("Getting result values", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();
    ResultValue resultValues[2];
    std::unique_ptr<IQuantumApi> iqaLockstep =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get()}, resultValues);

    Qubit q = iqaLockstep->AllocateQubit();

    iqa1->presetResults.push_back({Result_Zero});
    iqa2->presetResults.push_back({Result_Pending});
    Result r = iqaLockstep->M(q);
    ResultValue rv = iqaLockstep->GetResultValue(r);
    REQUIRE(rv == Result_Pending);
    REQUIRE(resultValues[0] == Result_Zero);
    REQUIRE(resultValues[1] == Result_Pending);

    iqa1->presetResults.push_back({Result_One});
    iqa2->presetResults.push_back({Result_Zero});
    r = iqaLockstep->M(q);
    rv = iqaLockstep->GetResultValue(r);
    REQUIRE(rv != Result_Pending);
    REQUIRE(resultValues[0] == Result_One);
    REQUIRE(resultValues[1] == Result_Zero);
    iqaLockstep->ReleaseResult(r);
}

// Qubits allocated by different IQuantumApi targets have nothing in common and cannot be passed
// from one target to another (unfortunatly, code like this will compile, though). However, with
// out current design it's still possible to inject additional work on one of the governed iqas
// by allocating new qubits directly and applying quantum operations to them.
TEST_CASE("Interfere with one of the targets", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();
    ResultValue resultValues[2];
    std::unique_ptr<IQuantumApi> iqaLockstep =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get()}, resultValues);

    Qubit q = iqaLockstep->AllocateQubit();
    iqaLockstep->X(q);

    Qubit q1 = iqa1->AllocateQubit();
    iqa1->X(q1);

    iqaLockstep->X(q);
    iqaLockstep->ReleaseQubit(q);
    iqa1->ReleaseQubit(q1);

    REQUIRE(2 == iqa1->qubitsAllocated);
    REQUIRE(3 == iqa1->invokedX);

    REQUIRE(1 == iqa2->qubitsAllocated);
    REQUIRE(2 == iqa2->invokedX);
}

// We don't know of any use case for setup like this but it should work, and it's a good
// stress case for the implementation.
TEST_CASE("Hierarchy of lockstep targets", "[lockstep]")
{
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa1 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa2 = make_unique<CMockSimulatorForLockstepTests>();
    std::unique_ptr<CMockSimulatorForLockstepTests> iqa3 = make_unique<CMockSimulatorForLockstepTests>();
    ResultValue resultValuesInner[3];
    std::unique_ptr<IQuantumApi> iqaLockstepInner =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa1.get(), iqa2.get(), iqa3.get()}, resultValuesInner);

    std::unique_ptr<CMockSimulatorForLockstepTests> iqa4 = make_unique<CMockSimulatorForLockstepTests>();
    ResultValue resultValuesOuter[2];
    std::unique_ptr<IQuantumApi> iqaLockstepOuter =
        CreateLockstepSimulator(vector<IQuantumApi*>{iqa4.get(), iqaLockstepInner.get()}, resultValuesOuter);

    Qubit q = iqaLockstepOuter->AllocateQubit();
    iqaLockstepOuter->X(q);
    REQUIRE(1 == iqa1->qubitsAllocated);
    REQUIRE(1 == iqa1->invokedX);
    REQUIRE(1 == iqa2->qubitsAllocated);
    REQUIRE(1 == iqa2->invokedX);
    REQUIRE(1 == iqa3->qubitsAllocated);
    REQUIRE(1 == iqa3->invokedX);
    REQUIRE(1 == iqa4->qubitsAllocated);
    REQUIRE(1 == iqa4->invokedX);

    iqa1->presetResults.push_back({Result_Zero});
    iqa2->presetResults.push_back({Result_Zero});
    iqa3->presetResults.push_back({Result_Zero});
    iqa4->presetResults.push_back({Result_One});
    Result r = iqaLockstepOuter->M(q);
    iqaLockstepOuter->GetResultValue(r);
    REQUIRE(resultValuesOuter[0] == Result_One);
    REQUIRE(resultValuesOuter[1] == Result_Zero);
}