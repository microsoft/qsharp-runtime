// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "catch.hpp"

#include "CoreTypes.hpp"
#include "tracer.hpp"

using namespace std;
using namespace Microsoft::Quantum;

TEST_CASE("Layering distinct single-qubit operations of non-zero durations", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer();
    tr->SetPreferredLayerDuration(3);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    tr->TraceSingleQubitOp(1, 1, q1); // L(0,3) should be created
    tr->TraceSingleQubitOp(2, 2, q1); // add the op into L(0,3)
    tr->TraceSingleQubitOp(3, 1, q2); // add the op into L(0,3)
    tr->TraceSingleQubitOp(4, 3, q2); // create new layer L(3,3)
    tr->TraceSingleQubitOp(5, 4, q2); // create new layer L(6,4)
    tr->TraceSingleQubitOp(6, 2, q1); // add the op into L(3,3)
    tr->TraceSingleQubitOp(7, 1, q3); // add the op into L(0,3)

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 3);
    CHECK(layers[0].startTime == 0);
    CHECK(layers[0].operations.size() == 4);
    CHECK(layers[1].startTime == 3);
    CHECK(layers[1].operations.size() == 2);
    CHECK(layers[2].startTime == 6);
    CHECK(layers[2].operations.size() == 1);
}

TEST_CASE("Layering single-qubit operations of zero duration", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer();
    tr->SetPreferredLayerDuration(3);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    tr->TraceSingleQubitOp(1, 1, q1); // L(0,3) should be created
    tr->TraceSingleQubitOp(2, 0, q1); // add the op into L(0,3)
    tr->TraceSingleQubitOp(3, 0, q3); // pending zero op (will remain orphan)
    tr->TraceSingleQubitOp(4, 0, q2); // pending zero op
    tr->TraceSingleQubitOp(5, 0, q2); // another pending zero op
    tr->TraceSingleQubitOp(6, 1, q2); // add the op into L(0,3) together with the pending ones

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 1);
    CHECK(layers[0].operations.size() == 5);
}

TEST_CASE("Layering distinct controlled single-qubit operations", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer();
    tr->SetPreferredLayerDuration(3);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();
    Qubit q5 = tr->AllocateQubit();
    Qubit q6 = tr->AllocateQubit();

    tr->TraceControlledSingleQubitOp(1 /*id*/, 1 /*dur*/, 1 /*nCtls*/, &q1 /*ctls*/, q2 /*target*/);
    tr->TraceSingleQubitOp(2 /*id*/, 2 /*dur*/, q2);
    // q2 now is at the limit of the layer duration

    tr->TraceControlledSingleQubitOp(3 /*id*/, 1 /*dur*/, 1 /*nCtls*/, &q2 /*ctls*/, q3 /*target*/);
    // because of q2 this should have created a new layer

    tr->TraceControlledSingleQubitOp(4 /*id*/, 0 /*dur*/, 1 /*nCtls*/, &q4 /*ctls*/, q5 /*target*/);
    tr->TraceSingleQubitOp(5 /*id*/, 1 /*dur*/, q6);
    tr->TraceControlledSingleQubitOp(6 /*id*/, 1 /*dur*/, 1 /*nCtls*/, &q1 /*ctls*/, q6 /*target*/);
    // these ops should fall through into the first layer (notice no special handling of duration zero)

    tr->TraceControlledSingleQubitOp(7 /*id*/, 1 /*dur*/, 1 /*nCtls*/, &q3 /*ctls*/, q4 /*target*/);
    // because of q3 should be added into the second layer

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 2);

    REQUIRE(layers[0].operations.size() == 5);
    const auto& ops0 = layers[0].operations;
    CHECK(ops0.find(1) != ops0.end());
    CHECK(ops0.find(2) != ops0.end());
    CHECK(ops0.find(4) != ops0.end());
    CHECK(ops0.find(5) != ops0.end());
    CHECK(ops0.find(6) != ops0.end());

    CHECK(layers[1].operations.size() == 2);
    const auto& ops1 = layers[1].operations;
    CHECK(ops1.find(3) != ops1.end());
    CHECK(ops1.find(7) != ops1.end());
}

// TODO: add controlled and multi-qubit ops
TEST_CASE("Operations with same id are counted together", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer();
    tr->SetPreferredLayerDuration(3);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    // All of these ops should fit into a single layer L(0,3)
    tr->TraceSingleQubitOp(1, 1, q1);
    tr->TraceSingleQubitOp(2, 2, q1);
    tr->TraceSingleQubitOp(1, 1, q2);
    tr->TraceSingleQubitOp(2, 1, q2);
    tr->TraceSingleQubitOp(1, 1, q2);
    tr->TraceSingleQubitOp(3, 2, q3);

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 1);
    CHECK(layers[0].operations.size() == 3);
    const auto& ops = layers[0].operations;
    CHECK(ops.find(1)->second == 3);
    CHECK(ops.find(2)->second == 2);
    CHECK(ops.find(3)->second == 1);
}
