// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

extern "C" int To_Be_Generated(); // NOLINT
TEST_CASE("Test that we are building the new components correctly", "[qir-tracer]")
{
    REQUIRE(0 == To_Be_Generated());
}
