// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstdint>
#include <memory>

#include "catch.hpp"

#include "QirTypes.hpp"

extern "C" QirString* Microsoft__Quantum__Testing__QIR__Format__FormattedITest__body(QirString* fmt, uint64_t value); // NOLINT

TEST_CASE("QIR: Format.FormattedI", "[qir.Format][qir.Format.FormattedI]")
{
    QirString qstr{std::string("{x}")};
    std::unique_ptr<QirString> retQStr{
            Microsoft__Quantum__Testing__QIR__Format__FormattedITest__body(&qstr, 42)};
    REQUIRE(retQStr->str == "2a");
}
