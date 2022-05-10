// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include <memory>

#include "catch.hpp"

#include "QirRuntime.hpp"
#include "QirRuntimeApi_I.hpp"
#include "SimFactory.hpp"
#include "QirContext.hpp"
#include "QirOutputHandling.hpp"
#include "OutputStream.hpp"

using namespace std;
using namespace Microsoft::Quantum;

TEST_CASE("QIR: TupleOutHandle", "[qir][out_handl][tuple_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    // tuple_start_record_output
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__tuple_start_record_output();
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_TUPLE_START) + QOH_REC_DELIMITER));
    }

    // tuple_end_record_output
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__tuple_end_record_output();
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_TUPLE_END) + QOH_REC_DELIMITER));
    }

    // start + end
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__tuple_start_record_output();
            __quantum__rt__tuple_end_record_output();
        }
        REQUIRE(actualStrStream.str() ==
                (string(QOH_REC_TUPLE_START) + QOH_REC_DELIMITER + string(QOH_REC_TUPLE_END) + QOH_REC_DELIMITER));
    }
}

TEST_CASE("QIR: ArrayOutHandle", "[qir][out_handl][array_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    // array_start_record_output
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__array_start_record_output();
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_ARRAY_START) + QOH_REC_DELIMITER));
    }

    // array_end_record_output
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__array_end_record_output();
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_ARRAY_END) + QOH_REC_DELIMITER));
    }

    // start + end
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__array_start_record_output();
            __quantum__rt__array_end_record_output();
        }
        REQUIRE(actualStrStream.str() ==
                (string(QOH_REC_ARRAY_START) + QOH_REC_DELIMITER + string(QOH_REC_ARRAY_END) + QOH_REC_DELIMITER));
    }
}

TEST_CASE("QIR: ResultOutHandle", "[qir][out_handl][result_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__result_record_output(__quantum__rt__result_get_zero());
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_RESULT_ZERO) + QOH_REC_DELIMITER));
    }

    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__result_record_output(__quantum__rt__result_get_one());
        }
        REQUIRE(actualStrStream.str() == (string(QOH_REC_RESULT_ONE) + QOH_REC_DELIMITER));
    }
}

TEST_CASE("QIR: BoolOutHandle", "[qir][out_handl][bool_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__bool_record_output(false);
        }

        REQUIRE(actualStrStream.str() == (string(QOH_REC_FALSE) + QOH_REC_DELIMITER));
    }

    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__bool_record_output(true);
        }

        REQUIRE(actualStrStream.str() == (string(QOH_REC_TRUE) + QOH_REC_DELIMITER));
    }
}

TEST_CASE("QIR: i64OutHandle", "[qir][out_handl][i64_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    auto i64Value = GENERATE(42LL, -2LL, 0x7FFFFFFFFFFFFFFFLL, 0x8000000000000000LL, 0x3333333333333333LL);
    //                                   9223372036854775807   -9223372036854775808  3689348814741910323
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__integer_record_output(i64Value);
        }

        std::stringstream expectedStrStream;
        expectedStrStream << i64Value;

        REQUIRE(actualStrStream.str() == (string(QOH_REC_PREFIX) + expectedStrStream.str() + QOH_REC_DELIMITER));
    }
}

TEST_CASE("QIR: doubleOutHandle", "[qir][out_handl][double_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    auto value = GENERATE(0.0, 1.0, -2.0, 3.14159, -6.28, 6.67E+23, NAN, INFINITY);
    //                                                    6.67e+23  nan  inf
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__double_record_output(value);
        }

        std::stringstream expectedStrStream;
        expectedStrStream << value;

        REQUIRE(actualStrStream.str() == (string(QOH_REC_PREFIX) + expectedStrStream.str() + QOH_REC_DELIMITER));
    }
}


// Group/mixed.
TEST_CASE("QIR: MixedOutHandle", "[qir][out_handl][tuple_record_output]")
{
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirExecutionContext::Scoped contextReleaser{sim.get()};

    // clang-format off
    {
        ostringstream actualStrStream;
        {
            OutputStream::ScopedRedirector qOStreamRedirector(actualStrStream);
            __quantum__rt__array_start_record_output();
                __quantum__rt__tuple_start_record_output();
                    __quantum__rt__double_record_output(6.67E+23);
                    __quantum__rt__integer_record_output(42LL);
                    __quantum__rt__bool_record_output(true);
                    __quantum__rt__result_record_output(__quantum__rt__result_get_one());
                __quantum__rt__tuple_end_record_output();

                __quantum__rt__tuple_start_record_output();
                    __quantum__rt__double_record_output(-10.123);
                    __quantum__rt__integer_record_output(-2049LL);
                    __quantum__rt__bool_record_output(false);
                    __quantum__rt__result_record_output(__quantum__rt__result_get_zero());
                __quantum__rt__tuple_end_record_output();
            __quantum__rt__array_end_record_output();
        }

        std::stringstream expectedStrStream;
        expectedStrStream << 
            QOH_REC_ARRAY_START << QOH_REC_DELIMITER <<
                QOH_REC_TUPLE_START << QOH_REC_DELIMITER <<
                    QOH_REC_PREFIX << (double)6.67E+23 << QOH_REC_DELIMITER <<
                    QOH_REC_PREFIX << 42LL << QOH_REC_DELIMITER <<
                    QOH_REC_TRUE << QOH_REC_DELIMITER <<
                    QOH_REC_RESULT_ONE << QOH_REC_DELIMITER <<
                QOH_REC_TUPLE_END << QOH_REC_DELIMITER <<

                QOH_REC_TUPLE_START << QOH_REC_DELIMITER <<
                    QOH_REC_PREFIX << (double)-10.123 << QOH_REC_DELIMITER <<
                    QOH_REC_PREFIX << -2049LL << QOH_REC_DELIMITER <<
                    QOH_REC_FALSE << QOH_REC_DELIMITER <<
                    QOH_REC_RESULT_ZERO << QOH_REC_DELIMITER <<
                QOH_REC_TUPLE_END << QOH_REC_DELIMITER <<
            QOH_REC_ARRAY_END << QOH_REC_DELIMITER;

        REQUIRE(actualStrStream.str() == expectedStrStream.str());
        // actual: "RESULT\tARRAY_START\nRESULT\tTUPLE_START\nRESULT\t6.67e+23\nRESULT\t42\nRESULT\ttrue\nRESULT\t1\nRESULT\tTUPLE_END\n"
        //                              "RESULT\tTUPLE_START\nRESULT\t-10.123\nRESULT\t-2049\nRESULT\tfalse\nRESULT\t0\nRESULT\tTUPLE_END\n"
        //         "RESULT\tARRAY_END\n\xcd\xcd\xcd\xcd\xcd..\xee\xfe\xee\xfe"
    }
    // clang-format on
}
