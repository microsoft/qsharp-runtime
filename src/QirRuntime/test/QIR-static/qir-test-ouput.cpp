// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <iostream>
#include <sstream>

#include "catch.hpp"

#include "QirTypes.hpp"
#include "QirRuntime.hpp"
//#include "SimFactory.hpp"
//#include "qsharp__foundation_internal.hpp"

extern "C" void Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(void*); // NOLINT


// https://stackoverflow.com/a/5419388/6362941
// https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574170031
// https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574194191
struct OstreamRedirectorScoped
{
    OstreamRedirectorScoped(std::ostream& newOstream)
        : old(Microsoft::Quantum::SetOutputStream(newOstream))
    {}

    ~OstreamRedirectorScoped()
    {
        Microsoft::Quantum::SetOutputStream(old);
    }

  private:
    std::ostream& old;
};


TEST_CASE("QIR: Out.Message", "[qir.Out][qir.Out.Message]")
{
    const std::string       testStr1 = "Test String 1";
    const std::string       testStr2 = "Test String 2";

    std::ostringstream      outStrStream;

    {
        OstreamRedirectorScoped qOStreamRedirector(outStrStream);    // Redirect the output from std::cout to outStrStream.

        // Log something (to the redirected output):
        QirString qstr{std::string(testStr1)};
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);
        qstr.str = testStr2;
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);

    } // Recover the output stream.

    REQUIRE(outStrStream.str() == (testStr1 + "\n" + testStr2 + "\n"));
}
