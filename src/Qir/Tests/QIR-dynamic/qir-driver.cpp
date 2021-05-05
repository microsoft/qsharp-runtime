// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <iostream>
#include <fstream>
#include <cstdio>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "SimFactory.hpp"
#include "QirContext.hpp"
#include "OutputStream.hpp"

extern "C" int64_t Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop(); // NOLINT

extern "C" void Microsoft__Quantum__Testing__QIR__DumpMachineTest__Interop(); // NOLINT
extern "C" void Microsoft__Quantum__Testing__QIR__DumpMachineToFileTest__Interop(const char[]); // NOLINT
extern "C" void Microsoft__Quantum__Testing__QIR__DumpRegisterTest__Interop(); // NOLINT
extern "C" void Microsoft__Quantum__Testing__QIR__DumpRegisterToFileTest__Interop(const char[]); // NOLINT

extern "C" void Microsoft__Quantum__Testing__QIR__AssertMeasurementTest__Interop(); // NOLINT

using namespace Microsoft::Quantum;

TEST_CASE("QIR: Generate a random number with full state simulator", "[qir]")
{
    QirExecutionContext::Scoped contextReleaser{CreateFullstateSimulator().release()};

    const int ret1 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    const int ret2 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    const int ret3 = Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__Interop();
    INFO(
        std::string("Three random numbers: ") + std::to_string(ret1) + ", " + std::to_string(ret2) + ", " +
        std::to_string(ret3));

    // Check that the returned numbers are at least somewhat random...
    CHECK(ret1 != ret2);
    CHECK(ret1 != ret3);
    CHECK(ret2 != ret3);
}


static bool FileExists(const char * filePath)
{
    return std::ifstream(filePath).operator bool();
}

TEST_CASE("QIR: DumpMachine", "[qir][DumpMachine]")
{
    QirExecutionContext::Scoped contextReleaser{CreateFullstateSimulator().release()};

    // Dump to the std::cout:
    {
        std::ostringstream      outStrStream;
        {
            // Redirect the output from std::cout to outStrStream:
            OutputStream::ScopedRedirector qOStreamRedirector(outStrStream);

            Microsoft__Quantum__Testing__QIR__DumpMachineTest__Interop();
        } // qOStreamRedirector goes out of scope.

        REQUIRE(outStrStream.str().size() != 0);
    }


    // Dump to empty string location (std::cout):
    {
        std::ostringstream      outStrStream;
        {
            // Redirect the output from std::cout to outStrStream:
            OutputStream::ScopedRedirector qOStreamRedirector(outStrStream);

            Microsoft__Quantum__Testing__QIR__DumpMachineToFileTest__Interop("");
        } // qOStreamRedirector goes out of scope.

        REQUIRE(outStrStream.str().size() != 0);
    }


    // Dump to a file:
    const char* filePath = "DumpMachineTest.log";

    // Remove the `filePath`, if exists.
    if(FileExists(filePath))
    {
        CHECK(0 == remove(filePath));
    }

    REQUIRE(!FileExists(filePath));

    // Dump the machine state to that `filePath`:
    Microsoft__Quantum__Testing__QIR__DumpMachineToFileTest__Interop(filePath);

    // Make sure the file has been created.
    REQUIRE(FileExists(filePath));

    // If we got here then the test has succeeded, we don't need the file.
    // Otherwise (test fails) we don't get here, and the file is kept for the subsequent analysis.
    // Remove the file, ignore the failure:
    (void) remove(filePath);
}


TEST_CASE("QIR: DumpRegister", "[qir][DumpRegister]")
{
    QirExecutionContext::Scoped contextReleaser{CreateFullstateSimulator().release()};

    // Dump to the std::cout:
    {
        std::ostringstream      outStrStream;
        {
            // Redirect the output from std::cout to outStrStream:
            OutputStream::ScopedRedirector qOStreamRedirector(outStrStream);

            Microsoft__Quantum__Testing__QIR__DumpRegisterTest__Interop();
        } // qOStreamRedirector goes out of scope.

        REQUIRE(outStrStream.str().size() != 0);
    }


    // Dump to empty string location (std::cout):
    {
        std::ostringstream      outStrStream;
        {
            // Redirect the output from std::cout to outStrStream:
            OutputStream::ScopedRedirector qOStreamRedirector(outStrStream);

            Microsoft__Quantum__Testing__QIR__DumpRegisterToFileTest__Interop("");
        } // qOStreamRedirector goes out of scope.

        REQUIRE(outStrStream.str().size() != 0);
    }


    // Dump to a file:
    const char* filePath = "DumpRegisterTest.log";

    // Remove the `filePath` if exists.
    if(FileExists(filePath))
    {
        CHECK(0 == remove(filePath));
    }

    REQUIRE(!FileExists(filePath));

    // Dump to that `filePath`:
    Microsoft__Quantum__Testing__QIR__DumpRegisterToFileTest__Interop(filePath);

    // Make sure the file has been created.
    REQUIRE(FileExists(filePath));

    // If we got here then the test has succeeded, we don't need the file.
    // Otherwise (test fails) we don't get here, and the file is kept for the subsequent analysis.
    // Remove the file, ignore the failure:
    (void) remove(filePath);
}


TEST_CASE("QIR: AssertMeasurement", "[qir][AssertMeasurement]")
{
    QirExecutionContext::Scoped contextReleaser{CreateFullstateSimulator().release()};

    Microsoft__Quantum__Testing__QIR__AssertMeasurementTest__Interop();
} // TEST_CASE("QIR: AssertMeasurement", "[qir][AssertMeasurement]")
