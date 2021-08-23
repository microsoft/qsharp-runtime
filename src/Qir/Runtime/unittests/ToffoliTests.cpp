// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <vector>

#include "catch.hpp"

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"

using namespace Microsoft::Quantum;

static Result MZ(IQuantumGateSet* iqa, qubitid_t q)
{
    PauliId pauliZ[1] = {PauliId_Z};
    qubitid_t qs[1]   = {q};
    return iqa->Measure(1, pauliZ, 1, qs);
}

TEST_CASE("Basis vector", "[toffoli]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateToffoliSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    constexpr int n = 1000;
    std::vector<qubitid_t> qubits;
    qubits.reserve(n);
    for (int i = 0; i < n; i++)
    {
        qubitid_t q = sim->AllocateQubit();
        qubits.push_back(q);
        if ((i & 0x1) == 1)
        {
            iqa->X(q);
        }
    }

    long sum = 0;
    for (qubitid_t q : qubits)
    {
        if (sim->GetResultValue(MZ(iqa, q)) == Result_One)
        {
            sum++;
        }
    }
    REQUIRE(sum == n / 2);
}

TEST_CASE("Controlled X", "[toffoli]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateToffoliSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q[4];
    q[0] = sim->AllocateQubit();
    q[1] = sim->AllocateQubit();
    q[2] = sim->AllocateQubit();
    q[3] = sim->AllocateQubit();

    // qubits state: |0000>
    iqa->ControlledX(1, &q[0], q[1]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[1])) == Result_Zero);
    iqa->ControlledX(2, &q[0], q[2]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[2])) == Result_Zero);
    iqa->ControlledX(3, &q[0], q[3]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[2])) == Result_Zero);

    iqa->X(q[0]);

    // qubits state: |1000>
    iqa->ControlledX(2, &q[0], q[2]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[2])) == Result_Zero);
    iqa->ControlledX(3, &q[0], q[3]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[3])) == Result_Zero);
    iqa->ControlledX(1, &q[0], q[2]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[2])) == Result_One);

    // qubits state: |1010>
    iqa->ControlledX(3, &q[0], q[3]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[3])) == Result_Zero);

    iqa->X(q[1]);

    // qubits state: |1110>
    iqa->ControlledX(2, &q[1], q[3]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[3])) == Result_One);

    // qubits state: |1111>
    iqa->ControlledX(3, &q[1], q[0]);
    REQUIRE(sim->GetResultValue(MZ(iqa, q[0])) == Result_Zero);
}

TEST_CASE("Measure and assert probability", "[toffoli]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateToffoliSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    const int count = 3;
    qubitid_t qs[count];
    for (int i = 0; i < count; i++)
    {
        qs[i] = sim->AllocateQubit();
    }

    PauliId zzz[count] = {PauliId_Z, PauliId_Z, PauliId_Z};
    PauliId ziz[count] = {PauliId_Z, PauliId_I, PauliId_Z};

    // initial state is |000>
    IDiagnostics* idig = dynamic_cast<IDiagnostics*>(sim.get());
    REQUIRE(sim->GetResultValue(iqa->Measure(count, zzz, count, qs)) == Result_Zero);
    REQUIRE(sim->GetResultValue(iqa->Measure(count, ziz, count, qs)) == Result_Zero);
    REQUIRE(idig->Assert(count, zzz, qs, sim->UseZero(), ""));
    REQUIRE(idig->AssertProbability(count, zzz, qs, 1.0, 0.01, ""));

    // set state to: |010>
    iqa->X(qs[1]);
    REQUIRE(sim->GetResultValue(iqa->Measure(count, zzz, count, qs)) == Result_One);
    REQUIRE(sim->GetResultValue(iqa->Measure(count, ziz, count, qs)) == Result_Zero);
    REQUIRE(idig->Assert(count, zzz, qs, sim->UseOne(), ""));
    REQUIRE(idig->AssertProbability(count, ziz, qs, 1.0, 0.01, ""));

    // set state to: |111>
    iqa->X(qs[0]);
    iqa->X(qs[2]);
    REQUIRE(sim->GetResultValue(iqa->Measure(count, zzz, count, qs)) == Result_One);
    REQUIRE(sim->GetResultValue(iqa->Measure(count, ziz, count, qs)) == Result_Zero);
    REQUIRE(idig->Assert(count, ziz, qs, sim->UseZero(), ""));
    REQUIRE(idig->AssertProbability(count, zzz, qs, 0.0, 0.01, ""));
}
