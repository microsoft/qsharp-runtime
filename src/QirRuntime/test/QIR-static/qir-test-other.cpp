// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "catch.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Other__ParityTest__body();                // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Other__PauliArrayAsIntTest__body();       // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Other__PauliArrayAsIntFailTest__body();   // NOLINT

TEST_CASE("QIR: Other.PauliArrayAsIntFail", "[qir.Other][qir.Other.PauliArrayAsIntFail]")
{
    REQUIRE_THROWS(Microsoft__Quantum__Testing__QIR__Other__PauliArrayAsIntFailTest__body());
}

TEST_CASE("QIR: Other.PauliArrayAsInt", "[qir.Other][qir.Other.PauliArrayAsInt]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Other__PauliArrayAsIntTest__body());
}


TEST_CASE("QIR: Other.Parity", "[qir.Other][qir.Other.Parity]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Other__ParityTest__body());
}
