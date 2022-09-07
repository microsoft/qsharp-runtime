// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <iostream>
#include <fstream>
#include <cstdio>
#include <memory>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

extern "C"
{
    int64_t Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop(); // NOLINT

    void Microsoft__Quantum__Testing__QIR__DumpMachineTest__Interop();                   // NOLINT
    void Microsoft__Quantum__Testing__QIR__DumpMachineToFileTest__Interop(const void*);  // NOLINT
    void Microsoft__Quantum__Testing__QIR__DumpRegisterTest__Interop();                  // NOLINT
    void Microsoft__Quantum__Testing__QIR__DumpRegisterToFileTest__Interop(const void*); // NOLINT

    void Microsoft__Quantum__Testing__QIR__AssertMeasurementTest__Interop(); // NOLINT

    void Microsoft__Quantum__Testing__QIR__AssertMeasAlloc1OKTest__Interop();                   // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeasProbAlloc1HalfProbTest__Interop();         // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeasProbAllocPlusMinusTest__Interop();         // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeasSPlusMinusTest__Interop();                 // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeas0011__Interop();                           // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeas4Qubits__Interop();                        // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertBellPairMeasurementsAreCorrectTest__Interop(); // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeasMixedBasesTest__Interop();                 // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertGHZMeasurementsTest__Interop();                // NOLINT

    void Microsoft__Quantum__Testing__QIR__AssertMeasMessageTest__Interop(const char*);     // NOLINT
    void Microsoft__Quantum__Testing__QIR__AssertMeasProbMessageTest__Interop(const char*); // NOLINT
} // extern "C"

TEST_CASE("QIR: Generate a random number with full state simulator", "[qir]")
{
    const int64_t ret1 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    const int64_t ret2 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    const int64_t ret3 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    INFO(std::string("Three random numbers: ") + std::to_string(ret1) + ", " + std::to_string(ret2) + ", " +
         std::to_string(ret3));

    // Check that the returned numbers are at least somewhat random...
    CHECK(ret1 != ret2);
    CHECK(ret1 != ret3);
    CHECK(ret2 != ret3);
}

TEST_CASE("QIR: AssertMeasurement", "[qir][AssertMeasurement]")
{
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeasAlloc1OKTest__Interop());

    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeasProbAlloc1HalfProbTest__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeasProbAllocPlusMinusTest__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeasSPlusMinusTest__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeas0011__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeas4Qubits__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertBellPairMeasurementsAreCorrectTest__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertMeasMixedBasesTest__Interop());
    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__QIR__AssertGHZMeasurementsTest__Interop());
} // TEST_CASE("QIR: AssertMeasurement", "[qir][AssertMeasurement]")
