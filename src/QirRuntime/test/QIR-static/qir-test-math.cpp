// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>
#include <cstring>

#include "catch.hpp"

#include "quantum__qis_internal.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body();           // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__LogTest__body();            // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body();        // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(int64_t min, int64_t max);  // NOLINT

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

TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
{
    // Use const seed (and 100%-predictable sequence of pseudo-random numbers):
    Quantum::Qis::Internal::UseRandomSeed(false);

    size_t times = 30;
    std::vector<int64_t> actualNumbers;
    std::vector<int64_t> expectedSmallNumbers( { -7,  7, 0, -4, 9,    -8, -6,  2, 10, -2,     -2, 5, -6, 7, -6, 
                                                 -8, -7, 7,  1, 0,    -7, -4, -4, -5,  9,      6, 9,  8, 0, 10 } );
    // Get the actual pseudo-random numbers:
    actualNumbers.reserve(times);
    while(times--)
    {
        actualNumbers.emplace_back( 
            Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(-10, 10));
    }

    // Compare the actual numbers with the expected ones:
    for(auto iterExp = expectedSmallNumbers.begin(), iterAct = actualNumbers.begin();
        iterExp != expectedSmallNumbers.end(); ++iterExp, ++iterAct)
    {
        REQUIRE(*iterExp == *iterAct);
    }


    // Repeat for large numbers:
    times = 30;
    actualNumbers.clear();
    std::vector<int64_t> expectedLargeNumbers( {  
        -5906760355100746824 /*0xae06f8c09cdc1bb8*/, -5720189720460620649 /*0xb09dcdc1901a8c97*/,  -439612500227010677 /*0xf9e62ec29d25cf8b*/, 
        -4480907261563067469 /*0xc1d09e962310a3b3*/,  8861952245290091527 /*0x7afbfa9d4cfdc407*/,  8955350353842143311 /*0x7c47cbb307ee004f*/, 
        -6280323296958344769 /*0xa8d7cf3c6a3011bf*/,  3137151747734999458 /*0x2b8966e4aa3d91a2*/,  4939508655077151009 /*0x448ca8f37ed75121*/, 
         6238374286314258160 /*0x5693285c6fb13ef0*/, -6040247118112373857 /*0xac2cbb3fa955c39f*/, -6824740380414679031 /*0xa149a6c8751e6809*/, 
        -3380739839894412592 /*0xd11533070d1522d0*/,  7062538648911045657 /*0x62032d7b74cf6419*/, -1848293964386331010 /*0xe6598a6e9c41167e*/, 
                                                                                                                       
        -1514943637843006295 /*0xeaf9d6c9b3a12ca9*/,   294039394754184707 /* 0x414a3458a4b4603*/,   -91412906514914735 /*0xfebb3c72234ae251*/, 
        -7093910850833618148 /*0x9d8d5daa93c5eb1c*/,  4756956360327131315 /*0x42041a9b355570b3*/, -6568968956750423344 /*0xa4d65589a8529ad0*/, 
        -5274461833025259975 /*0xb6cd58e87d2c7639*/, -5622420113283637231 /*0xb1f926b221b7a011*/,  1769368467569154988 /*0x188e0f3f2a3c9bac*/, 
         6326595214296717137 /*0x57cc94d3e1d79751*/,  6712677457684672091 /*0x5d2838951d112e5b*/,   544336960902186754 /* 0x78ddf94f8b0c702*/, 
          743075161731202080 /* 0xa4feeec30677c20*/,   609941927012233092 /* 0x876f2f3752e6f84*/, -7083339319657626609 /*0x9db2ec6afc40040f*/
    } );

    while(times--)
    {
        actualNumbers.emplace_back( 
            Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(std::numeric_limits<int64_t>::min(), 
                                                                            std::numeric_limits<int64_t>::max()));
    }

    for(auto iterExp = expectedLargeNumbers.begin(), iterAct = actualNumbers.begin();
        iterExp != expectedLargeNumbers.end(); ++iterExp, ++iterAct)
    {
        REQUIRE(*iterExp == *iterAct);
    }


    // Make sure the correct exception is thrown if min > max:
    REQUIRE_THROWS_AS(Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(10, 5), 
                      std::runtime_error);

    // Check the exception string:
    try
    {
        (void)Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(10, 5);
    }
    catch(std::runtime_error const & exc)
    {
        REQUIRE(0 == strcmp(exc.what(), Quantum::Qis::Internal::excStrDrawRandomInt));
    }
} // TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
