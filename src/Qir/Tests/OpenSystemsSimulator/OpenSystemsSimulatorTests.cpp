// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <complex>
#include <memory>
#include <vector>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include "context.hpp"

using namespace Microsoft::Quantum;
using namespace std;

TEST_CASE("Open systems simulator: X and measure", "[open_simulator]")
{
    std::unique_ptr<ISimulator> sim = CreateOpenSystemsSimulator();
    IQuantumGateSet* iqa = sim->AsQuantumGateSet();

    Qubit q = sim->AllocateQubit();
    Result r1 = sim->M(q);
    REQUIRE(Result_Zero == sim->GetResultValue(r1));
    REQUIRE(sim->AreEqualResults(r1, sim->UseZero()));

    iqa->X(q);
    Result r2 = sim->M(q);
    REQUIRE(Result_One == sim->GetResultValue(r2));
    REQUIRE(sim->AreEqualResults(r2, sim->UseOne()));

    sim->ReleaseQubit(q);
    sim->ReleaseResult(r1);
    sim->ReleaseResult(r2);
}
