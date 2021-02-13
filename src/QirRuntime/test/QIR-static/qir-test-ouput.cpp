// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <iostream>
#include <sstream>

#include "catch.hpp"

#include "qirTypes.hpp"
#include "quantum__qis_internal.hpp"

extern "C" void Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(QirString*);        // NOLINT


// https://stackoverflow.com/a/5419388/6362941
// https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574170031
// https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574194191
struct QOstreamRedirector
{
    QOstreamRedirector(std::ostream & newOstream)
        : old(SetQOstream(newOstream))
    {}

    ~QOstreamRedirector()
    {
        SetQOstream(old);
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
        QOstreamRedirector qOStreamRedirector(outStrStream);

        // Log something:
        QirString qstr{std::string(testStr1)};
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);
        qstr.str = testStr2;
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);

    } // Recover the output stream.

    REQUIRE(outStrStream.str() == (testStr1 + "\n" + testStr2 + "\n"));
}
