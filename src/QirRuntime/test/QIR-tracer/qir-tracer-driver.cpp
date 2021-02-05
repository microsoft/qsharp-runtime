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

TEST_CASE("Test that we are building the new components correctly", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, g_operationNames);
    QirContextScope qirctx(tr.get(), false /*trackAllocatedObjects*/);

    REQUIRE(Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body());
    vector<Layer> layers = tr->UseLayers();

    // AllIntrinsics happens to produce 25 layers right now and we are not checking whether that's expected -- as 
    // testing of layering logic is better done by unit tests.
    CHECK(layers.size() == 25);

    std::ofstream out;
    out.open("qir-tracer-test.txt");
    tr->PrintLayerMetrics(out, "\t", false /*printZeroMetrics*/);
    out.close();
}

}