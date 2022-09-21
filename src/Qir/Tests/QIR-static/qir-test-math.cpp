// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>
#include <cstring>
#include <iostream>

#include "catch.hpp"

#include "FloatUtils.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SqrtTest__Interop();          // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__LogTest__Interop();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__InfTest__Interop();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__Interop();       // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SinTest__Interop();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__CosTest__Interop();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__TanTest__Interop();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcSinTest__Interop();        // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcCosTest__Interop();        // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcTanTest__Interop();        // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SinhTest__Interop();          // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__CoshTest__Interop();          // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__TanhTest__Interop();          // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__IeeeRemainderTest__Interop(); // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ExponentTest__Interop();      // NOLINT
extern "C" int64_t Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__Interop(    // NOLINT
    int64_t min, int64_t max);
extern "C" double Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomDouble__Interop( // NOLINT
    double min, double max);

TEST_CASE("QIR: Math.Sqrt", "[qir.math][qir.Math.Sqrt]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__SqrtTest__Interop());
}

TEST_CASE("QIR: Math.Log", "[qir.math][qir.Math.Log]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__LogTest__Interop());
}

TEST_CASE("QIR: Math.Inf", "[qir.math][qir.Math.Inf]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__InfTest__Interop());
}

TEST_CASE("QIR: Math.ArcTan2", "[qir.math][qir.Math.ArcTan2]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__Interop());
}

TEST_CASE("QIR: Math.Sin", "[qir.math][qir.Math.Sin]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__SinTest__Interop());
}

TEST_CASE("QIR: Math.Cos", "[qir.math][qir.Math.Cos]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__CosTest__Interop());
}

TEST_CASE("QIR: Math.Tan", "[qir.math][qir.Math.Tan]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__TanTest__Interop());
}

TEST_CASE("QIR: Math.ArcSin", "[qir.math][qir.Math.ArcSin]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ArcSinTest__Interop());
}

TEST_CASE("QIR: Math.ArcCos", "[qir.math][qir.Math.ArcCos]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ArcCosTest__Interop());
}

TEST_CASE("QIR: Math.ArcTan", "[qir.math][qir.Math.ArcTan]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ArcTanTest__Interop());
}

TEST_CASE("QIR: Math.Sinh", "[qir.math][qir.Math.Sinh]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__SinhTest__Interop());
}

TEST_CASE("QIR: Math.Cosh", "[qir.math][qir.Math.Cosh]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__CoshTest__Interop());
}

TEST_CASE("QIR: Math.Tanh", "[qir.math][qir.Math.Tanh]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__TanhTest__Interop());
}

TEST_CASE("QIR: Math.IeeeRemainder", "[qir.math][qir.Math.IeeeRemainder]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__IeeeRemainderTest__Interop());
}

TEST_CASE("QIR: Math.Exponent.builtin", "[qir.math][qir.Math.Exponent.builtin]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__ExponentTest__Interop());
}

TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
{
    // Test equal minimum and maximum:
    for (int64_t num : {-5, 0, 3})
    {
        REQUIRE(Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__Interop(num, num) == num);
    }
} // TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
