// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>

#include "catch.hpp"


extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Str__PauliToStringTest__Interop(); // NOLINT


TEST_CASE("QIR: Strings", "[qir.Str][qir.Str.PauliToString]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Str__PauliToStringTest__Interop());
}
