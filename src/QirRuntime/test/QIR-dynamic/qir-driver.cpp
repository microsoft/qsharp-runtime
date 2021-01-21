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

// This VQE sample is taken from https://github.com/msr-quarc/StandaloneVQE
// When executed in Q# it returns -1.0 with single decimal precision (the correct energy value is close to -1.3)
extern "C" void SetupQirToRunOnFullStateSimulator();
extern "C" int64_t Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body(); // NOLINT
TEST_CASE("QIR: SimpleVQE with full state simulator", "[qir]")
{
    SetupQirToRunOnFullStateSimulator();

    const int ret1 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body();
    const int ret2 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body();
    INFO(std::string("two random numbers: ") + std::to_string(ret1) + " " + std::to_string(ret2));
    REQUIRE(ret1 != ret2);

}
