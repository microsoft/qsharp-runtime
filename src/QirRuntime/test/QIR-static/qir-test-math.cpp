// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>
#include <cstring>
#include <iostream>

#include "catch.hpp"

#include "quantum__qis_internal.hpp"

extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body();                                  // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__LogTest__body();                                   // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body();                               // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__SinTest__body();                                   // NOLINT
extern "C" uint64_t Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(int64_t min, int64_t max); // NOLINT

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

TEST_CASE("QIR: Math.Sin", "[qir.math][qir.Math.Sin]")
{
    REQUIRE(0 == Microsoft__Quantum__Testing__QIR__Math__SinTest__body());
}


TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
{
    // Test that the Q# random number generator is a wrapper around the C++ generator:
    size_t times = 1000;
    while(--times)
    {
        const uint64_t qsRndNum = 
            Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(std::numeric_limits<int64_t>::min(),
                                                                            std::numeric_limits<int64_t>::max());
        const uint64_t cppRndNum = Quantum::Qis::Internal::GetLastGeneratedRandomNumber();  // This call must be done 
            // _after_ the  Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body().
        REQUIRE(qsRndNum == cppRndNum);
    }

    // Make sure the correct exception is thrown if min > max:
    REQUIRE_THROWS_AS(Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(10, 5), std::runtime_error);

    // Check the exception string:
    try
    {
        (void)Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(10, 5);
    }
    catch (std::runtime_error const& exc)
    {
        REQUIRE(0 == strcmp(exc.what(), Quantum::Qis::Internal::excStrDrawRandomInt));
    }

    // There is a strong difference in the opinions about how the random number generator must be tested.
    // More or less agreed-upon items are:
    //  * The test must be 100% deterministic, i.e. must not fail, even with a very low probability. 
    //    Otherwise it will bother the unrelated CI builds/test-runs, that are done a lot. 
    //  * The test must not be platform-, compiler-, etc. dependent. 
    //    Otherwise it can break upon migration to a newer compiler, OS update, new OS added to the test runs, etc.
    // 
    // The code below is platform-dependent, can also depend on the compiler version. 
    // Commenting out for now.

    // #ifdef __APPLE__
    //     std::vector<int64_t> expectedLargeNumbers( {  
    //         -2160833387943730151 /*0xe2032d7b74cf6419*/,  7375078072468444798 /*0x66598a6e9c41167e*/,  7708428399011769513 /*0x6af9d6c9b3a12ca9*/,
    //         -8929332642100591101 /*0x8414a3458a4b4603*/,  9131959130339861073 /*0x7ebb3c72234ae251*/,  2129461186021157660 /*0x1d8d5daa93c5eb1c*/,
    //         -4466415676527644493 /*0xc2041a9b355570b3*/,  2654403080104352464 /*0x24d65589a8529ad0*/,  3948910203829515833 /*0x36cd58e87d2c7639*/,
    //          3600951923571138577 /*0x31f926b221b7a011*/, -7454003569285620820 /*0x988e0f3f2a3c9bac*/, -2896776822558058671 /*0xd7cc94d3e1d79751*/,
    //         -2510694579170103717 /*0xdd2838951d112e5b*/, -8679035075952589054 /*0x878ddf94f8b0c702*/, -8480296875123573728 /*0x8a4feeec30677c20*/,

    //         -8613430109842542716 /*0x8876f2f3752e6f84*/,  2140032717197149199 /*0x1db2ec6afc40040f*/,  -917262003397267527 /*0xf3453b11598aefb9*/,
    //         -3734430349428794203 /*0xcc2ca3620fdbdca5*/,  5134567830016493736 /*0x4741a63cbf4808a8*/, -8243723698983337761 /*0x8d9868f90fa100df*/,
    //          5560736588152128922 /*0x4d2bb4770253459a*/,    50526560201835791 /*  0xb381a3888d850f*/,  1288735234894005209 /*0x11e281de3d6303d9*/,
    //          3656101241126025060 /*0x32bd14b53c2e7764*/,   872395409727236160 /* 0xc1b5f00c4792840*/,  7628415731883617240 /*0x69dd93b0e9ecabd8*/,
    //         -1986081594003691539 /*0xe47005501e77e7ed*/,  7532118334194327900 /*0x688775b7d3dc215c*/, -4186893097968929306 /*0xc5e52ae91706f5e6*/
    //     } );
    //     std::vector<int64_t> expectedSmallNumbers( { 1, 4, 2, 4, 5,     -2, -4, 9,  4, -4,    -9,  9, -1,  5, 7, 
    //                                                 -8, 0, 2, 5, 0,     -1,  1, 9, -3,  5,    -8, -9,  6, -1, 6 } );
    // #else
    //     std::vector<int64_t> expectedLargeNumbers( {  
    //         -5906760355100746824 /*0xae06f8c09cdc1bb8*/, -5720189720460620649 /*0xb09dcdc1901a8c97*/,  -439612500227010677 /*0xf9e62ec29d25cf8b*/,
    //         -4480907261563067469 /*0xc1d09e962310a3b3*/,  8861952245290091527 /*0x7afbfa9d4cfdc407*/,  8955350353842143311 /*0x7c47cbb307ee004f*/,
    //         -6280323296958344769 /*0xa8d7cf3c6a3011bf*/,  3137151747734999458 /*0x2b8966e4aa3d91a2*/,  4939508655077151009 /*0x448ca8f37ed75121*/,
    //          6238374286314258160 /*0x5693285c6fb13ef0*/, -6040247118112373857 /*0xac2cbb3fa955c39f*/, -6824740380414679031 /*0xa149a6c8751e6809*/,
    //         -3380739839894412592 /*0xd11533070d1522d0*/,  7062538648911045657 /*0x62032d7b74cf6419*/, -1848293964386331010 /*0xe6598a6e9c41167e*/,

    //         -1514943637843006295 /*0xeaf9d6c9b3a12ca9*/,   294039394754184707 /* 0x414a3458a4b4603*/,   -91412906514914735 /*0xfebb3c72234ae251*/,
    //         -7093910850833618148 /*0x9d8d5daa93c5eb1c*/,  4756956360327131315 /*0x42041a9b355570b3*/, -6568968956750423344 /*0xa4d65589a8529ad0*/,
    //         -5274461833025259975 /*0xb6cd58e87d2c7639*/, -5622420113283637231 /*0xb1f926b221b7a011*/,  1769368467569154988 /*0x188e0f3f2a3c9bac*/,
    //          6326595214296717137 /*0x57cc94d3e1d79751*/,  6712677457684672091 /*0x5d2838951d112e5b*/,   544336960902186754 /* 0x78ddf94f8b0c702*/,
    //           743075161731202080 /* 0xa4feeec30677c20*/,   609941927012233092 /* 0x876f2f3752e6f84*/, -7083339319657626609 /*0x9db2ec6afc40040f*/
    //     } );
    // #ifdef _WIN32
    //     std::vector<int64_t> expectedSmallNumbers( { -7,  7, 0, -4, 9,    -8, -6,  2, 10, -2,     -2, 5, -6, 7, -6,
    //                                                  -8, -7, 7,  1, 0,    -7, -4, -4, -5,  9,      6, 9,  8, 0, 10 } );
    // #else
    //     std::vector<int64_t> expectedSmallNumbers( { -7, 10, -10, 2,  1,    -9, 3, -2,  7,  9,       -2, 3, 9, -3, -5,
    //                                                  -1,  6,   4, 1, -4,    -7, 2,  1, -7, -7,      -10, 1, 4, -2,  9 } );
    // #endif // #ifdef _WIN32
    // #endif // #ifdef __APPLE__

    //     // Use const seed (and 100%-predictable sequence of pseudo-random numbers):
    //     Quantum::Qis::Internal::RandomizeSeed(false);

    //     size_t times = 30;
    //     std::vector<int64_t> actualNumbers;
    //     // Get the actual pseudo-random numbers:
    //     actualNumbers.reserve(times);
    //     while (times--)
    //     {
    //         actualNumbers.emplace_back(Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(-10, 10));
    //     }

    //     // Compare the actual numbers with the expected ones:
    //     for (auto iterExp = expectedSmallNumbers.begin(), iterAct = actualNumbers.begin();
    //          iterExp != expectedSmallNumbers.end(); ++iterExp, ++iterAct)
    //     {
    //         REQUIRE(*iterExp == *iterAct);
    //     }


    //     // Repeat for large numbers:
    //     times = 30;
    //     actualNumbers.clear();
    //     while (times--)
    //     {
    //         actualNumbers.emplace_back(
    //             Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(std::numeric_limits<int64_t>::min(),
    //                                                                             std::numeric_limits<int64_t>::max()));
    //     }

    //     for (auto iterExp = expectedLargeNumbers.begin(), iterAct = actualNumbers.begin();
    //          iterExp != expectedLargeNumbers.end(); ++iterExp, ++iterAct)
    //     {
    //         REQUIRE(*iterExp == *iterAct);
    //     }

} // TEST_CASE("QIR: Math.DrawRandomInt", "[qir.math][qir.Math.DrawRandomInt]")
