// https://github.com/catchorg/Catch2/blob/master/docs/tutorial.md
#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include <iostream>

#include "QAPI.hpp"
#include "SimFactory.hpp"
#include "ResourceStatistics.hpp"

using namespace quantum;
using namespace std;

extern ResourceStatistics g_stats;

TEST_CASE("Tracing Context: no resources used", "[tracing_context]")
{
    ostringstream os;
    g_stats.Print(os);

    REQUIRE(os.str() == "{\"qubit_width\":0,\"statistics\":[]}");
}

TEST_CASE("Tracing Context: simple program", "[tracing_context]")
{
    std::unique_ptr<IQuantumApi> iqa = CreateToffoliSimulator();
    QuantumExecutionContext ctx;
    ctx.hQuantumApi = reinterpret_cast<uint64_t>(iqa.get());

    Qubit q = QAPI_AllocateQubit(&ctx);
    QAPI_ReleaseQubit(&ctx, q);
    q = QAPI_AllocateQubit(&ctx);
    QAPI_X(&ctx, q);
    QAPI_ReleaseQubit(&ctx, q);

    ostringstream os;
    g_stats.Print(os);
    g_stats = {0};

    REQUIRE(os.str() == "{\"qubit_width\":1,\"statistics\":[{\"metric\":\"cX\",\"value\":1},]}");
}

TEST_CASE("Tracing Context: simulator is fully intercepted", "[tracing_context]")
{
    QuantumExecutionContext ctx;
    ctx.hQuantumApi = reinterpret_cast<uint64_t>(nullptr);

    Qubit q = QAPI_AllocateQubit(&ctx);
    QAPI_Y(&ctx, q);
    QAPI_H(&ctx, q);
    QAPI_ReleaseQubit(&ctx, q);

    ostringstream os;
    g_stats.Print(os);
    g_stats = {0};

    REQUIRE(
        os.str() ==
        "{\"qubit_width\":1,\"statistics\":[{\"metric\":\"cY\",\"value\":1},{\"metric\":\"cH\",\"value\":1},]}");
}