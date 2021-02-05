#include <cmath>

#include "catch.hpp"

extern "C" double __quantum__qis__sqrt__body(double);   // NOLINT

TEST_CASE("QIR: math.sqrt", "[qir.math][qir.math.sqrt]")
{
    REQUIRE(2.0     == __quantum__qis__sqrt__body((double)4.0));
    REQUIRE(3.0     == __quantum__qis__sqrt__body((double)9.0));
    REQUIRE(10.0    == __quantum__qis__sqrt__body((double)100.0));

    REQUIRE( isnan(__quantum__qis__sqrt__body((double)-5.0)) );     // (double)NAN == sqrt((double)-5.0)
    REQUIRE( isnan(__quantum__qis__sqrt__body(nan(""))) );          // (double)NAN == sqrt((double)<quiet NAN>)
    REQUIRE( isinf(__quantum__qis__sqrt__body((double)INFINITY)) ); // +-infinity  == sqrt((double) +infinity)
}
