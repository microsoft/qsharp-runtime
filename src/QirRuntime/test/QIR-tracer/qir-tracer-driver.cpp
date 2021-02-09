// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <fstream>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "context.hpp"
#include "tracer-config.hpp"
#include "tracer.hpp"

using namespace std;
using namespace Microsoft::Quantum;

namespace TracerUser
{

TEST_CASE("Invoke each operator from Q# core once", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, g_operationNames);
    QirContextScope qirctx(tr.get(), false /*trackAllocatedObjects*/);

    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__Tracer__TestCoreIntrinsics__body());
    vector<Layer> layers = tr->UseLayers();

    // TestCoreIntrinsics happens to produce 24 layers right now and we are not checking whether that's expected -- as 
    // testing of layering logic is better done by unit tests.
    CHECK(layers.size() == 24);

    std::ofstream out;
    out.open("qir-tracer-test.txt");
    tr->PrintLayerMetrics(out, "\t", false /*printZeroMetrics*/);
    out.close();
}

TEST_CASE("Measurements can be counted but cannot be compared", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, g_operationNames);
    QirContextScope qirctx(tr.get(), false /*trackAllocatedObjects*/);

    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__Tracer__TestMeasurements__body(false /*compare*/));
    CHECK(tr->UseLayers().size() == 1);

    REQUIRE_THROWS(Microsoft__Quantum__Testing__Tracer__TestMeasurements__body(true /*compare*/));
}
}