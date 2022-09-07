// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <complex>
#include <memory>
#include <string>
#include <vector>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

using namespace std;

extern "C" int Microsoft__Quantum__Testing__QIR__MeasureRelease__Interop(); // NOLINT
TEST_CASE("QIR: Simulator accepts measured release", "[fullstate_simulator]")
{
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__MeasureRelease__Interop());
}

extern "C" int Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__Interop(); // NOLINT
TEST_CASE("QIR: invoke all standard Q# gates against the fullstate simulator", "[fullstate_simulator]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__Interop());
}
