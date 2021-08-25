// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <complex>
#include <memory>
#include <vector>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"
#include "QirContext.hpp"

using namespace Microsoft::Quantum;
using namespace std;

// The tests rely on the implementation detail of CFullstateSimulator that the qubits are nothing more but contiguously
// incremented ids.
static unsigned GetQubitId(qubitid_t q)
{
    return static_cast<unsigned>(reinterpret_cast<size_t>(q));
}

static Result MZ(IQuantumGateSet* iqa, qubitid_t q)
{
    PauliId pauliZ[1] = {PauliId_Z};
    qubitid_t qs[1]   = {q};
    return iqa->Measure(1, pauliZ, 1, qs);
}

TEST_CASE("Fullstate simulator: allocate qubits", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();

    qubitid_t q0 = sim->AllocateQubit();
    qubitid_t q1 = sim->AllocateQubit();
    REQUIRE(GetQubitId(q0) == 0);
    REQUIRE(GetQubitId(q1) == 1);
    sim->ReleaseQubit(q0);
    sim->ReleaseQubit(q1);
}

TEST_CASE("Fullstate simulator: multiple instances", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim1 = CreateFullstateSimulator();
    qubitid_t q1                         = sim1->AllocateQubit();

    std::unique_ptr<IRuntimeDriver> sim2 = CreateFullstateSimulator();
    qubitid_t q2                         = sim2->AllocateQubit();

    REQUIRE(GetQubitId(q1) == 0);
    REQUIRE(GetQubitId(q2) == 0);

    sim1->ReleaseQubit(q1);
    sim2->ReleaseQubit(q2);
}

TEST_CASE("Fullstate simulator: X and measure", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q = sim->AllocateQubit();
    Result r1   = MZ(iqa, q);
    REQUIRE(Result_Zero == sim->GetResultValue(r1));
    REQUIRE(sim->AreEqualResults(r1, sim->UseZero()));

    iqa->X(q);
    Result r2 = MZ(iqa, q);
    REQUIRE(Result_One == sim->GetResultValue(r2));
    REQUIRE(sim->AreEqualResults(r2, sim->UseOne()));

    sim->ReleaseQubit(q);
    sim->ReleaseResult(r1);
    sim->ReleaseResult(r2);
}

TEST_CASE("Fullstate simulator: X, M, reuse, M", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q = sim->AllocateQubit();
    Result r1   = MZ(iqa, q);
    REQUIRE(Result_Zero == sim->GetResultValue(r1));
    REQUIRE(sim->AreEqualResults(r1, sim->UseZero()));

    iqa->X(q);
    Result r2 = MZ(iqa, q);
    REQUIRE(Result_One == sim->GetResultValue(r2));
    REQUIRE(sim->AreEqualResults(r2, sim->UseOne()));

    sim->ReleaseQubit(q);
    sim->ReleaseResult(r1);
    sim->ReleaseResult(r2);

    qubitid_t qq = sim->AllocateQubit();
    Result r3    = MZ(iqa, qq);
    // Allocated qubit should always be in |0> state even though we released
    // q in |1> state, and qq is likely reusing the same underlying qubit as q.
    REQUIRE(Result_Zero == sim->GetResultValue(r3));
    REQUIRE(sim->AreEqualResults(r3, sim->UseZero()));

    sim->ReleaseQubit(qq);
    sim->ReleaseResult(r3);
}

TEST_CASE("Fullstate simulator: measure Bell state", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q1 = sim->AllocateQubit();
    qubitid_t q2 = sim->AllocateQubit();

    iqa->H(q1);
    iqa->ControlledX(1, &q1, q2);

    Result r1 = MZ(iqa, q1);
    Result r2 = MZ(iqa, q2);
    REQUIRE(sim->AreEqualResults(r1, r2));

    sim->ReleaseQubit(q1);
    sim->ReleaseQubit(q2);
}

TEST_CASE("Fullstate simulator: ZZ measure", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q[2];
    PauliId paulis[2] = {PauliId_Z, PauliId_Z};

    q[0] = sim->AllocateQubit();
    q[1] = sim->AllocateQubit();
    iqa->H(q[0]);
    iqa->ControlledX(1, &q[0], q[1]);
    Result rZero = iqa->Measure(2, paulis, 2, q);
    REQUIRE(Result_Zero == sim->GetResultValue(rZero));

    iqa->X(q[1]);
    Result rOne = iqa->Measure(2, paulis, 2, q);
    REQUIRE(Result_One == sim->GetResultValue(rOne));

    iqa->X(q[1]);
    iqa->ControlledX(1, &q[0], q[1]);
    iqa->H(q[0]);

    sim->ReleaseQubit(q[0]);
    sim->ReleaseQubit(q[1]);
}

TEST_CASE("Fullstate simulator: assert probability", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t qs[2];
    qs[0] = sim->AllocateQubit();
    qs[1] = sim->AllocateQubit();
    iqa->X(qs[0]);

    PauliId zz[2] = {PauliId_Z, PauliId_Z};
    PauliId iz[2] = {PauliId_I, PauliId_Z};
    PauliId xi[2] = {PauliId_X, PauliId_I};

    IDiagnostics* idig = dynamic_cast<IDiagnostics*>(sim.get());
    REQUIRE(idig->AssertProbability(2, zz, qs, 0.0, 1e-10, ""));
    REQUIRE(idig->AssertProbability(2, iz, qs, 1.0, 1e-10, ""));
    REQUIRE(idig->AssertProbability(2, xi, qs, 0.5, 1e-10, ""));

    REQUIRE(idig->Assert(2, zz, qs, sim->UseOne(), ""));
    REQUIRE(idig->Assert(2, iz, qs, sim->UseZero(), ""));
    REQUIRE(!idig->Assert(2, xi, qs, sim->UseZero(), ""));
    REQUIRE(!idig->Assert(2, xi, qs, sim->UseOne(), ""));

    iqa->X(qs[0]);

    sim->ReleaseQubit(qs[0]);
    sim->ReleaseQubit(qs[1]);
}

TEST_CASE("Fullstate simulator: toffoli", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t qs[3];
    for (int i = 0; i < 3; i++)
    {
        qs[i] = sim->AllocateQubit();
    }

    iqa->X(qs[0]);
    iqa->ControlledX(2, qs, qs[2]);
    REQUIRE(Result_Zero == sim->GetResultValue(MZ(iqa, qs[2])));

    iqa->X(qs[1]);
    iqa->ControlledX(2, qs, qs[2]);
    REQUIRE(Result_One == sim->GetResultValue(MZ(iqa, qs[2])));

    iqa->X(qs[1]);
    iqa->X(qs[0]);

    for (int i = 0; i < 3; i++)
    {
        sim->ReleaseQubit(qs[i]);
    }
}

TEST_CASE("Fullstate simulator: SSZ=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q = sim->AllocateQubit();

    bool identitySSZ = true;
    for (int i = 0; i < 100 && identitySSZ; i++)
    {
        iqa->H(q);
        iqa->S(q);
        iqa->S(q);
        iqa->Z(q);
        iqa->H(q);
        identitySSZ = (Result_Zero == sim->GetResultValue(MZ(iqa, q)));
    }
    REQUIRE(identitySSZ);

    sim->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: TTSAdj=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q = sim->AllocateQubit();

    bool identityTTSAdj = true;
    for (int i = 0; i < 100 && identityTTSAdj; i++)
    {
        iqa->H(q);
        iqa->T(q);
        iqa->T(q);
        iqa->AdjointS(q);
        iqa->H(q);
        identityTTSAdj = (Result_Zero == sim->GetResultValue(MZ(iqa, q)));
    }
    REQUIRE(identityTTSAdj);

    sim->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: TTAdj=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q = sim->AllocateQubit();

    bool identityTTadj = true;
    for (int i = 0; i < 100 && identityTTadj; i++)
    {
        iqa->H(q);
        iqa->T(q);
        iqa->AdjointT(q);
        iqa->H(q);
        identityTTadj = (Result_Zero == sim->GetResultValue(MZ(iqa, q)));
    }
    REQUIRE(identityTTadj);

    sim->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: R", "[fullstate_simulator]")
{
    constexpr double pi                 = 3.1415926535897932384626433832795028841971693993751058209749445923078164062;
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    qubitid_t q   = sim->AllocateQubit();
    bool identity = true;
    for (int i = 0; i < 100 && identity; i++)
    {
        iqa->H(q);
        iqa->R(PauliId_X, q, 0.42);
        iqa->R(PauliId_Y, q, 0.17);
        iqa->T(q);
        iqa->R(PauliId_Z, q, -pi / 4.0);
        iqa->R(PauliId_Y, q, -0.17);
        iqa->R(PauliId_X, q, -0.42);
        iqa->H(q);
        identity = (Result_Zero == sim->GetResultValue(MZ(iqa, q)));
    }
    REQUIRE(identity);

    sim->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: exponents", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());
    const int n                         = 5;

    qubitid_t qs[n];
    for (int i = 0; i < n; i++)
    {
        qs[i] = sim->AllocateQubit();
    }

    PauliId paulis[3] = {PauliId_X, PauliId_Y, PauliId_Z};
    iqa->Exp(2, paulis, qs, 0.42);
    iqa->ControlledExp(2, qs, 3, paulis, &qs[2], 0.17);
    iqa->ControlledExp(2, qs, 3, paulis, &qs[2], -0.17);
    iqa->Exp(2, paulis, qs, -0.42);

    // not crashes? consider it passing
    REQUIRE(true);

    for (int i = 0; i < n; i++)
    {
        sim->ReleaseQubit(qs[i]);
    }
}

TEST_CASE("Fullstate simulator: get qubit state of Bell state", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    IQuantumGateSet* iqa                = dynamic_cast<IQuantumGateSet*>(sim.get());

    const int n        = 3;
    static double norm = 0.0;

    qubitid_t qs[n];
    for (int i = 0; i < n; i++)
    {
        qs[i] = sim->AllocateQubit();
    }

    iqa->H(qs[0]);
    iqa->ControlledX(1, &qs[0], qs[1]);
    // 1/sqrt(2)(|00> + |11>)x|0>

    dynamic_cast<IDiagnostics*>(sim.get())->GetState([](size_t idx, double re, double im) {
        norm += re * re + im * im;
        REQUIRE(idx < 4);
        switch (idx)
        {
        case 0:
        case 3:
            REQUIRE((1 / sqrt(2.0) == Approx(re).epsilon(0.0001)));
            REQUIRE(im == 0.0);
            break;
        default:
            REQUIRE(re == 0.0);
            REQUIRE(im == 0.0);
            break;
        }
        return idx < 3; // the last qubit is in separable |0> state
    });
    REQUIRE(1.0 == Approx(norm).epsilon(0.0001));
    norm = 0.0;

    iqa->Y(qs[2]);
    // 1/sqrt(2)(|00> + |11>)xi|1>

    dynamic_cast<IDiagnostics*>(sim.get())->GetState([](size_t idx, double re, double im) {
        norm += re * re + im * im;
        switch (idx)
        {
        case 4:
        case 7:
            REQUIRE(re == 0.0);
            REQUIRE(1 / sqrt(2.0) == Approx(im).epsilon(0.0001));
            break;
        default:
            REQUIRE(re == 0.0);
            REQUIRE(im == 0.0);
            break;
        }
        return true; // get full state
    });
    REQUIRE(1.0 == Approx(norm).epsilon(0.0001));
    norm = 0.0;

    iqa->Y(qs[2]);
    iqa->ControlledX(1, &qs[0], qs[1]);
    iqa->H(qs[0]);

    for (int i = 0; i < n; i++)
    {
        sim->ReleaseQubit(qs[i]);
    }
}

extern "C" int Microsoft__Quantum__Testing__QIR__InvalidRelease__Interop(); // NOLINT
TEST_CASE("QIR: Simulator rejects unmeasured, non-zero release", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped qirctx(sim.get(), true /*trackAllocatedObjects*/);
    REQUIRE_THROWS(Microsoft__Quantum__Testing__QIR__InvalidRelease__Interop());
}

extern "C" int Microsoft__Quantum__Testing__QIR__MeasureRelease__Interop(); // NOLINT
TEST_CASE("QIR: Simulator accepts measured release", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped qirctx(sim.get(), true /*trackAllocatedObjects*/);
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__MeasureRelease__Interop());
}

extern "C" int Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__Interop(); // NOLINT
TEST_CASE("QIR: invoke all standard Q# gates against the fullstate simulator", "[fullstate_simulator]")
{
    std::unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped qirctx(sim.get(), true /*trackAllocatedObjects*/);

    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__Interop());
}
