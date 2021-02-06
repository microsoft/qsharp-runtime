#include <cstdint>

#include "catch.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__TestSqrt__body();   // NOLINT

TEST_CASE("QIR: math.sqrt", "[qir.math][qir.math.sqrt]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__TestSqrt__body());
}
