// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <iostream>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

// Can manually add calls to DebugLog in the ll files for debugging.
extern "C" void DebugLog(int64_t value)
{
    std::cout << value << std::endl;
}
extern "C" void DebugLogPtr(char* value)
{
    std::cout << (const void*)value << std::endl;
}

extern "C" void SetupQirToRunOnFullStateSimulator();
extern "C" int64_t Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body(); // NOLINT
TEST_CASE("QIR: Generate a random number with full state simulator", "[qir]")
{
    SetupQirToRunOnFullStateSimulator();

    const int ret1 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body();
    const int ret2 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body();
    const int ret3 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body();
    INFO(
        std::string("Three random numbers: ") + std::to_string(ret1) + ", " + std::to_string(ret2) + ", " +
        std::to_string(ret3));

    // Check that the returned numbers are at least somewhat random...
    CHECK(ret1 != ret2);
    CHECK(ret1 != ret3);
    CHECK(ret2 != ret3);
}
