// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <complex>
#include <memory>
#include <vector>

#include "catch.hpp"

#include "IQuantumApi.hpp"
#include "SimFactory.hpp"

using namespace Microsoft::Quantum;
using namespace std;

// The tests rely on the implementation detail of CFullstateSimulator that the qubits are nothing more but contiguously
// incremented ids.
unsigned GetQubitId(Qubit q)
{
    return static_cast<unsigned>(reinterpret_cast<size_t>(q));
}

TEST_CASE("Fullstate simulator: allocate qubits", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();
    Qubit q0 = iqa->AllocateQubit();
    Qubit q1 = iqa->AllocateQubit();
    REQUIRE(GetQubitId(q0) == 0);
    REQUIRE(GetQubitId(q1) == 1);
    iqa->ReleaseQubit(q0);
    iqa->ReleaseQubit(q1);
}

TEST_CASE("Fullstate simulator: multiple instances", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa1 = CreateFullstateSimulator();
    Qubit q1 = iqa1->AllocateQubit();

    std::unique_ptr<IQuantumApi> iqa2 = CreateFullstateSimulator();
    Qubit q2 = iqa2->AllocateQubit();

    REQUIRE(GetQubitId(q1) == 0);
    REQUIRE(GetQubitId(q2) == 0);

    iqa1->ReleaseQubit(q1);
    iqa2->ReleaseQubit(q2);
}

TEST_CASE("Fullstate simulator: X and measure", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q = iqa->AllocateQubit();
    Result r1 = iqa->M(q);
    REQUIRE(Result_Zero == iqa->GetResultValue(r1));
    REQUIRE(TernaryBool_True == iqa->AreEqualResults(r1, iqa->UseZero()));

    iqa->X(q);
    Result r2 = iqa->M(q);
    REQUIRE(Result_One == iqa->GetResultValue(r2));
    REQUIRE(TernaryBool_True == iqa->AreEqualResults(r2, iqa->UseOne()));

    iqa->ReleaseQubit(q);
    iqa->ReleaseResult(r1);
    iqa->ReleaseResult(r2);
}

TEST_CASE("Fullstate simulator: measure Bell state", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q1 = iqa->AllocateQubit();
    Qubit q2 = iqa->AllocateQubit();
    iqa->H(q1);
    iqa->CNOT(q1, q2);

    Result r1 = iqa->M(q1);
    Result r2 = iqa->M(q2);
    REQUIRE(TernaryBool_True == iqa->AreEqualResults(r1, r2));

    iqa->ReleaseQubit(q1);
    iqa->ReleaseQubit(q2);
}

TEST_CASE("Fullstate simulator: ZZ measure", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q[2];
    PauliId paulis[2] = {PauliId_Z, PauliId_Z};

    q[0] = iqa->AllocateQubit();
    q[1] = iqa->AllocateQubit();
    iqa->H(q[0]);
    iqa->CNOT(q[0], q[1]);
    Result rZero = iqa->Measure(2, paulis, 2, q);
    REQUIRE(Result_Zero == iqa->GetResultValue(rZero));

    iqa->X(q[1]);
    Result rOne = iqa->Measure(2, paulis, 2, q);
    REQUIRE(Result_One == iqa->GetResultValue(rOne));

    iqa->ReleaseQubit(q[0]);
    iqa->ReleaseQubit(q[1]);
}

TEST_CASE("Fullstate simulator: assert probability", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit qs[2];
    qs[0] = iqa->AllocateQubit();
    qs[1] = iqa->AllocateQubit();
    iqa->X(qs[0]);

    PauliId zz[2] = {PauliId_Z, PauliId_Z};
    PauliId iz[2] = {PauliId_I, PauliId_Z};
    PauliId xi[2] = {PauliId_X, PauliId_I};

    REQUIRE(iqa->AssertProbability(2, zz, qs, 0.0, 1e-10, ""));
    REQUIRE(iqa->AssertProbability(2, iz, qs, 1.0, 1e-10, ""));
    REQUIRE(iqa->AssertProbability(2, xi, qs, 0.5, 1e-10, ""));

    REQUIRE(iqa->Assert(2, zz, qs, iqa->UseOne(), ""));
    REQUIRE(iqa->Assert(2, iz, qs, iqa->UseZero(), ""));
    REQUIRE(!iqa->Assert(2, xi, qs, iqa->UseZero(), ""));
    REQUIRE(!iqa->Assert(2, xi, qs, iqa->UseOne(), ""));

    iqa->ReleaseQubit(qs[0]);
    iqa->ReleaseQubit(qs[1]);
}

TEST_CASE("Fullstate simulator: toffoli", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit qs[3];
    for (int i = 0; i < 3; i++)
    {
        qs[i] = iqa->AllocateQubit();
    }

    iqa->X(qs[0]);
    iqa->ControlledX(2, qs, qs[2]);
    REQUIRE(Result_Zero == iqa->GetResultValue(iqa->M(qs[2])));

    iqa->X(qs[1]);
    iqa->ControlledX(2, qs, qs[2]);
    REQUIRE(Result_One == iqa->GetResultValue(iqa->M(qs[2])));

    for (int i = 0; i < 3; i++)
    {
        iqa->ReleaseQubit(qs[i]);
    }
}

TEST_CASE("Fullstate simulator: SSZ=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q = iqa->AllocateQubit();

    bool identitySSZ = true;
    for (int i = 0; i < 100 && identitySSZ; i++)
    {
        iqa->H(q);
        iqa->S(q);
        iqa->S(q);
        iqa->Z(q);
        iqa->H(q);
        identitySSZ = (Result_Zero == iqa->GetResultValue(iqa->M(q)));
    }
    REQUIRE(identitySSZ);

    iqa->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: TTSAdj=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q = iqa->AllocateQubit();

    bool identityTTSAdj = true;
    for (int i = 0; i < 100 && identityTTSAdj; i++)
    {
        iqa->H(q);
        iqa->T(q);
        iqa->T(q);
        iqa->SAdjoint(q);
        iqa->H(q);
        identityTTSAdj = (Result_Zero == iqa->GetResultValue(iqa->M(q)));
    }
    REQUIRE(identityTTSAdj);

    iqa->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: TTAdj=Id", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q = iqa->AllocateQubit();

    bool identityTTadj = true;
    for (int i = 0; i < 100 && identityTTadj; i++)
    {
        iqa->H(q);
        iqa->T(q);
        iqa->TAdjoint(q);
        iqa->H(q);
        identityTTadj = (Result_Zero == iqa->GetResultValue(iqa->M(q)));
    }
    REQUIRE(identityTTadj);

    iqa->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: R", "[fullstate_simulator]")
{
    constexpr double pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062;
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();

    Qubit q = iqa->AllocateQubit();
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
        identity = (Result_Zero == iqa->GetResultValue(iqa->M(q)));
    }
    REQUIRE(identity);

    iqa->ReleaseQubit(q);
}

TEST_CASE("Fullstate simulator: exponents", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();
    const int n = 5;

    Qubit qs[n];
    for (int i = 0; i < n; i++)
    {
        qs[i] = iqa->AllocateQubit();
    }

    PauliId paulis[3] = {PauliId_X, PauliId_Y, PauliId_Z};
    iqa->Exp(2, paulis, qs, 0.42);
    iqa->ControlledExp(2, qs, 3, paulis, &qs[2], 0.17);

    // not crashes? consider it passing
    REQUIRE(true);

    for (int i = 0; i < n; i++)
    {
        iqa->ReleaseQubit(qs[i]);
    }
}

TEST_CASE("Fullstate simulator: get qubit state of Bell state", "[fullstate_simulator]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateFullstateSimulator();
    const int n = 3;
    static double norm = 0.0;

    Qubit qs[n];
    for (int i = 0; i < n; i++)
    {
        qs[i] = iqa->AllocateQubit();
    }

    iqa->H(qs[0]);
    iqa->CNOT(qs[0], qs[1]);
    // 1/sqrt(2)(|00> + |11>)x|0>

    iqa->GetState([](size_t idx, double re, double im) {
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

    iqa->GetState([](size_t idx, double re, double im) {
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

    for (int i = 0; i < n; i++)
    {
        iqa->ReleaseQubit(qs[i]);
    }
}