// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <sstream>

#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"

#include "QirContext.hpp"
#include "tracer-config.hpp"
#include "tracer.hpp"

using namespace std;
using namespace Microsoft::Quantum;

namespace TracerUser
{

TEST_CASE("Invoke each intrinsic from Q# core once", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, g_operationNames);
    QirExecutionContext::Scoped qirctx(tr.get(), true /*trackAllocatedObjects*/);

    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__Tracer__TestCoreIntrinsics__Interop());
    const vector<Layer>& layers = tr->UseLayers();

    std::stringstream out;
    tr->PrintLayerMetrics(out, ",", true /*printZeroMetrics*/);
    INFO(out.str());

    // TestCoreIntrinsics happens to produce 24 layers right now and we are not checking whether that's expected -- as
    // testing of layering logic is better done by unit tests.
    CHECK(layers.size() == 24);
}

TEST_CASE("Conditional execution on measurement result", "[qir-tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, g_operationNames);
    QirExecutionContext::Scoped qirctx(tr.get(), true /*trackAllocatedObjects*/);

    REQUIRE_NOTHROW(Microsoft__Quantum__Testing__Tracer__TestMeasurements__Interop());

    std::stringstream out;
    tr->PrintLayerMetrics(out, ",", true /*printZeroMetrics*/);
    INFO(out.str());
    CHECK(tr->UseLayers().size() == 5);
}
} // namespace TracerUser
