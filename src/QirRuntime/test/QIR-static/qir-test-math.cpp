// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>

#include "catch.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__LogTest__body();            // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body();        // NOLINT

TEST_CASE("QIR: Math.Sqrt", "[qir.math][qir.Math.Sqrt]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body());
}

TEST_CASE("QIR: Math.Log", "[qir.math][qir.Math.Log]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__LogTest__body());
}

TEST_CASE("QIR: Math.ArcTan2", "[qir.math][qir.Math.ArcTan2]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body());
}

