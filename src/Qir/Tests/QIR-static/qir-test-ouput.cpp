// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <sstream>

#include "catch.hpp"

#include "QirRuntime.hpp"
#include "OutputStream.hpp"

extern "C" void Microsoft__Quantum__Testing__QIR__Out__MessageTest__Interop(const char[]); // NOLINT

TEST_CASE("QIR: Out.Message", "[qir.Out][qir.Out.Message]")
{
    const std::string       testStr1 = "Test String 1";
    const std::string       testStr2 = "Test String 2";

    std::ostringstream      outStrStream;

    {
        // Redirect the output from std::cout to outStrStream:
        Microsoft::Quantum::OutputStream::ScopedRedirector qOStreamRedirector(outStrStream);

        // Log something (to the redirected output):
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__Interop(testStr1.c_str());
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__Interop(testStr2.c_str());

    } // Recover the output stream.

    REQUIRE(outStrStream.str() == (testStr1 + "\n" + testStr2 + "\n"));
}
