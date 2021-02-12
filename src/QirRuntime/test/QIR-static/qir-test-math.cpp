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
    // Commented out until https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r573978601
    // is resolved.

    /*
    // Range of the generated random numbers:
    constexpr int64_t   minimum = -1024;
    constexpr int64_t   maximum =  1023;
    constexpr size_t    count =  maximum - minimum + 1;     // How many numbers are in the range.

    size_t genAverage = 1000;                               // Each number should be generated ~1000 times.
    size_t times = count * genAverage;                      // How many times to draw.

    std::vector<uint16_t>  counters(count, 0);              // How many times each random number has been generated.

    // Count how many times each random number has been generated.
    while(--times)
    {
        const int64_t randomNumber = 
            Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(minimum, maximum);
        REQUIRE(minimum <= randomNumber);
        REQUIRE(randomNumber <= maximum);

        // Increment the counter for this number:
        const int64_t index = randomNumber - minimum;
        REQUIRE(0 <= index);
        REQUIRE(index < counters.size());
        ++(counters[index]);
    }

    // Make sure that each number has been generated, and the distribution is approximately uniform:
    for(auto counter : counters)
    {
        REQUIRE((genAverage - 300) < counter);  // The random number has been generated >  700 times (of expected 1000).
        REQUIRE(counter < (genAverage + 300));  // The random number has been generated < 1300 times (of expected 1000).
    }
    */

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
        REQUIRE(0 == strcmp(exc.what(), excStrDrawRandomInt));
    }

}
