// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <iostream>
#include <sstream>

#include "catch.hpp"

#include "qirTypes.hpp"

extern "C" void Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(QirString*);        // NOLINT


// https://stackoverflow.com/a/5419388/6362941
struct CoutRedirector
{
    CoutRedirector(std::streambuf * newBuffer) 
        : old(std::cout.rdbuf(newBuffer))      // Redirect std::cout to new_buffer.
    {}

    ~CoutRedirector() 
    {
        REQUIRE_NOTHROW(std::cout.rdbuf(old));     // Redirect std::cout back to stdout.
    }

private:
    std::streambuf * old;
};


TEST_CASE("QIR: Out.Message", "[qir.Out][qir.Out.Message]")
{
    std::string testStr1 = "Test String 1";
    std::string testStr2 = "Test String 2";
    std::stringstream coutBuffer;

    {
        CoutRedirector coutRedirector(coutBuffer.rdbuf());  // Redirect std::cout to coutBuffer.

        // Print something to std::cout:
        QirString qstr{std::string(testStr1)};
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);
        qstr.str = testStr2;
        Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(&qstr);

    } // Recover std::cout.

    REQUIRE(coutBuffer.str() == (testStr1 + "\n" + testStr2 + "\n"));
}
