// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "tracer.hpp"

using namespace std;
using namespace Microsoft::Quantum;

extern "C" bool Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body(); // NOLINT
TEST_CASE("Test that we are building the new components correctly", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer();
    SetSimulatorForQIR(tr.get());

    REQUIRE(Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body());
}
