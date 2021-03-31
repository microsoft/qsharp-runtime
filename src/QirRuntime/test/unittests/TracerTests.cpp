// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <fstream>
#include <iostream>
#include <sstream>

#include "catch.hpp"

#include "CoreTypes.hpp"
#include "tracer.hpp"

using namespace std;
using namespace Microsoft::Quantum;

TEST_CASE("Layering distinct single-qubit operations of non-zero durations", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(3 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1)); // L(0,3) should be created
    CHECK(0 == tr->TraceSingleQubitOp(2, 2, q1)); // add the op into L(0,3)
    CHECK(0 == tr->TraceSingleQubitOp(3, 1, q2)); // add the op into L(0,3)
    CHECK(1 == tr->TraceSingleQubitOp(4, 3, q2)); // create new layer L(3,3)
    CHECK(2 == tr->TraceSingleQubitOp(5, 4, q2)); // long op! create new layer L(6,4)
    CHECK(1 == tr->TraceSingleQubitOp(6, 2, q1)); // add the op into L(3,3)
    CHECK(0 == tr->TraceSingleQubitOp(7, 1, q3)); // add the op into L(0,3)
    CHECK(2 == tr->TraceSingleQubitOp(8, 4, q3)); // long op! but fits into existing L(6,4)
    CHECK(3 == tr->TraceSingleQubitOp(9, 5, q1)); // long op! add the op into L(10,5)

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 4);
    CHECK(layers[0].startTime == 0);
    CHECK(layers[0].operations.size() == 4);
    CHECK(layers[1].startTime == 3);
    CHECK(layers[1].operations.size() == 2);
    CHECK(layers[2].startTime == 6);
    CHECK(layers[2].operations.size() == 2);
    CHECK(layers[3].startTime == 10);
    CHECK(layers[3].operations.size() == 1);
}

TEST_CASE("Layering single-qubit operations of zero duration", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(3 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));       // L(0,3) should be created
    CHECK(0 == tr->TraceSingleQubitOp(2, 0, q1));       // add the op into L(0,3)
    CHECK(INVALID == tr->TraceSingleQubitOp(3, 0, q3)); // pending zero op (will remain orphan)
    CHECK(INVALID == tr->TraceSingleQubitOp(4, 0, q2)); // pending zero op
    CHECK(INVALID == tr->TraceSingleQubitOp(5, 0, q2)); // another pending zero op
    CHECK(0 == tr->TraceSingleQubitOp(6, 1, q2));       // add the op into L(0,3) together with the pending ones

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 1);
    CHECK(layers[0].operations.size() == 5);
}

TEST_CASE("Layering distinct controlled single-qubit operations", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(3 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();
    Qubit q5 = tr->AllocateQubit();
    Qubit q6 = tr->AllocateQubit();

    CHECK(0 == tr->TraceMultiQubitOp(1, 1, 1 /*nFirst*/, &q1 /*first*/, 1 /*nSecond*/, &q2 /*second*/));
    CHECK(0 == tr->TraceMultiQubitOp(2, 2, 0 /*nFirst*/, nullptr /*first*/, 1 /*nSecond*/, &q2 /*second*/));
    // q2 now is at the limit of the layer duration

    Qubit qs12[2] = {q1, q2};
    CHECK(1 == tr->TraceMultiQubitOp(3, 1, 0 /*nFirst*/, nullptr /*first*/, 2 /*nSecond*/, qs12 /*second*/));
    CHECK(1 == tr->TraceMultiQubitOp(4, 1, 1 /*nFirst*/, &q2 /*first*/, 1 /*nSecond*/, &q3 /*second*/));
    // because of q2, both ops should have been added to a new layer, which now "catches" q1, q2, q3

    CHECK(0 == tr->TraceMultiQubitOp(5, 0, 1 /*nFirst*/, &q4 /*first*/, 1 /*nSecond*/, &q5 /*second*/));
    CHECK(0 == tr->TraceSingleQubitOp(6, 1, q6));
    // these ops should fall through into the first layer (notice no special handling of duration zero)

    CHECK(1 == tr->TraceMultiQubitOp(7, 1, 1 /*nFirst*/, &q1 /*first*/, 1 /*nSecond*/, &q6 /*second*/));
    CHECK(1 == tr->TraceMultiQubitOp(8, 1, 1 /*nFirst*/, &q3 /*first*/, 1 /*nSecond*/, &q4 /*second*/));
    // because of q1 and q3, thiese ops should be added into the second layer, which now has all but q5

    CHECK(0 == tr->TraceSingleQubitOp(9, 1, q5));
    // should fall through to the first layer

    Qubit qs46[2] = {q4, q6};
    CHECK(1 == tr->TraceMultiQubitOp(10, 1, 2 /*nFirst*/, qs46 /*first*/, 1 /*nSecond*/, &q5 /*second*/));
    // because of the controls, should be added into the second layer

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 2);

    CHECK(layers[0].operations.size() == 5);
    const auto& ops0 = layers[0].operations;
    CHECK(ops0.find(1) != ops0.end());
    CHECK(ops0.find(2) != ops0.end());
    CHECK(ops0.find(5) != ops0.end());
    CHECK(ops0.find(6) != ops0.end());
    CHECK(ops0.find(9) != ops0.end());

    CHECK(layers[1].operations.size() == 5);
    const auto& ops1 = layers[1].operations;
    CHECK(ops1.find(3) != ops1.end());
    CHECK(ops1.find(4) != ops1.end());
    CHECK(ops1.find(7) != ops1.end());
    CHECK(ops1.find(8) != ops1.end());
    CHECK(ops1.find(10) != ops1.end());
}

// TODO: add multi-qubit ops
TEST_CASE("Operations with same id are counted together", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(3 /*layer duration*/);

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

TEST_CASE("Global barrier", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(2 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 4, q1)); // L(0,4) created
    CHECK(0 == tr->TraceSingleQubitOp(2, 1, q4)); // added to L(0,4)
    CHECK(1 == tr->InjectGlobalBarrier(42, 1));   // creates L(4,2)

    CHECK(2 == tr->TraceMultiQubitOp(3, 1, 1 /*nFirst*/, &q2 /*first*/, 1 /*nSecond*/, &q3 /*second*/));
    // the barrier shouldn't allow this op to fall through into L(0,4), so should create L(6,2)

    CHECK(INVALID == tr->TraceSingleQubitOp(4, 0, q1));
    // the barrier shouldn't allow this op to fall through into L(0,4), so should create pending op

    CHECK(2 == tr->TraceSingleQubitOp(5, 1, q1));
    // should be added into L(6,2) together with the pending op `3`

    CHECK(3 == tr->TraceSingleQubitOp(6, 3, q2));
    // long op, with no existing wide layers to host it, so should create L(8,3)

    CHECK(3 == tr->TraceSingleQubitOp(7, 3, q4));
    // long op but can be added into L(8,3), which is post the barrier

    const vector<Layer>& layers = tr->UseLayers();
    REQUIRE(layers.size() == 4);
    CHECK(layers[0].operations.size() == 2);
    CHECK(layers[1].operations.size() == 0);
    CHECK(layers[2].operations.size() == 3);
    CHECK(layers[3].operations.size() == 2);

    const auto& ops0 = layers[0].operations;
    CHECK(ops0.find(1) != ops0.end());
    CHECK(ops0.find(2) != ops0.end());

    CHECK(42 == layers[1].barrierId);

    const auto& ops2 = layers[2].operations;
    CHECK(ops2.find(3) != ops2.end());
    CHECK(ops2.find(4) != ops2.end());
    CHECK(ops2.find(5) != ops2.end());

    const auto& ops3 = layers[3].operations;
    CHECK(ops3.find(6) != ops3.end());
    CHECK(ops3.find(7) != ops3.end());
}

// For layering purposes, measurements behave pretty much the same as other operations
TEST_CASE("Layering measurements", "[tracer]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();

    CHECK(0 == tr->GetLayerIdOfSourceMeasurement(tr->TraceSingleQubitMeasurement(1, 1, q1)));
    Qubit qs12[2] = {q1, q2};
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(tr->TraceMultiQubitMeasurement(2, 1, 2, qs12)));
    CHECK(0 == tr->TraceSingleQubitOp(3, 1, q4));
    CHECK(0 == tr->GetLayerIdOfSourceMeasurement(tr->TraceSingleQubitMeasurement(4, 1, q3)));
    Qubit qs23[2] = {q2, q3};
    CHECK(2 == tr->GetLayerIdOfSourceMeasurement(tr->TraceMultiQubitMeasurement(5, 1, 2, qs23)));
    CHECK(1 == tr->TraceSingleQubitOp(3, 1, q4));
}

TEST_CASE("Conditionals: noops", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(3 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 3, q1));
    CHECK(1 == tr->TraceSingleQubitOp(1, 3, q1));
    Result one = tr->UseOne();
    {
        CTracer::FenceScope fs(tr.get(), 1, &one, 0, nullptr);
        CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    }
    {
        CTracer::FenceScope fs(tr.get(), 0, nullptr, 1, &one);
        CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    }
    {
        CTracer::FenceScope fs(tr.get(), 0, nullptr, 0, nullptr);
        CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    }
}

TEST_CASE("Conditionals: a new layer because of the fence", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r, 0, nullptr);
        CHECK(2 == tr->TraceSingleQubitOp(1, 1, q2));
    }

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q3));
}

TEST_CASE("Conditionals: single fence", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r));
    CHECK(2 == tr->TraceSingleQubitOp(1, 1, q1));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r, 0, nullptr);
        CHECK(2 == tr->TraceSingleQubitOp(1, 1, q2));
    }

    CHECK(3 == tr->TraceSingleQubitOp(1, 1, q1));
    CHECK(3 == tr->TraceSingleQubitOp(1, 1, q2));
    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q3));
    CHECK(1 == tr->TraceSingleQubitOp(1, 1, q3));
    CHECK(2 == tr->TraceSingleQubitOp(1, 1, q3));
}

TEST_CASE("Conditionals: fence from two result arrays", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r1 = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r1));
    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    CHECK(1 == tr->TraceSingleQubitOp(1, 1, q2));
    Result r2 = tr->TraceSingleQubitMeasurement(1, 1, q2);
    CHECK(2 == tr->GetLayerIdOfSourceMeasurement(r2));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r1, 1, &r2);
        CHECK(3 == tr->TraceSingleQubitOp(1, 1, q3));
    }

    CHECK(2 == tr->TraceSingleQubitOp(1, 1, q1));
}

TEST_CASE("Conditionals: nested fence is later than parent", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();
    Qubit q5 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r1 = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r1));
    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    CHECK(1 == tr->TraceSingleQubitOp(1, 1, q2));
    Result r2 = tr->TraceSingleQubitMeasurement(1, 1, q2);
    CHECK(2 == tr->GetLayerIdOfSourceMeasurement(r2));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r1, 0, nullptr);
        CHECK(2 == tr->TraceSingleQubitOp(1, 1, q3));
        {
            CTracer::FenceScope fs(tr.get(), 0, nullptr, 1, &r2);
            CHECK(3 == tr->TraceSingleQubitOp(1, 1, q4));
        }
        CHECK(2 == tr->TraceSingleQubitOp(1, 1, q5));
    }

    CHECK(2 == tr->TraceSingleQubitOp(1, 1, q1));
}

TEST_CASE("Conditionals: nested fence is earlier than parent", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();
    Qubit q5 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r1 = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r1));
    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q2));
    CHECK(1 == tr->TraceSingleQubitOp(1, 1, q2));
    Result r2 = tr->TraceSingleQubitMeasurement(1, 1, q2);
    CHECK(2 == tr->GetLayerIdOfSourceMeasurement(r2));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r2, 0, nullptr);
        CHECK(3 == tr->TraceSingleQubitOp(1, 1, q3));
        {
            CTracer::FenceScope fs(tr.get(), 0, nullptr, 1, &r1);
            CHECK(3 == tr->TraceSingleQubitOp(1, 1, q4));
        }
        CHECK(3 == tr->TraceSingleQubitOp(1, 1, q5));
    }
    CHECK(2 == tr->TraceSingleQubitOp(1, 1, q1));
}

TEST_CASE("Conditionals: fences and barriers", "[tracer][tracer.conditionals]")
{
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/);

    Qubit q1 = tr->AllocateQubit();
    Qubit q2 = tr->AllocateQubit();
    Qubit q3 = tr->AllocateQubit();
    Qubit q4 = tr->AllocateQubit();
    Qubit q5 = tr->AllocateQubit();

    CHECK(0 == tr->TraceSingleQubitOp(1, 1, q1));
    Result r1 = tr->TraceSingleQubitMeasurement(1, 1, q1);
    CHECK(1 == tr->GetLayerIdOfSourceMeasurement(r1));

    CHECK(2 == tr->InjectGlobalBarrier(42, 1));

    Result r2 = tr->TraceSingleQubitMeasurement(1, 1, q2);
    CHECK(3 == tr->GetLayerIdOfSourceMeasurement(r2));

    {
        CTracer::FenceScope fs(tr.get(), 1, &r1, 0, nullptr);
        CHECK(3 == tr->TraceSingleQubitOp(1, 1, q3));
    }
    {
        CTracer::FenceScope fs(tr.get(), 0, nullptr, 1, &r2);
        CHECK(4 == tr->TraceSingleQubitOp(1, 1, q4));
    }
    CHECK(3 == tr->TraceSingleQubitOp(1, 1, q5));
}

TEST_CASE("Output: to string", "[tracer]")
{
    std::unordered_map<OpId, std::string> opNames = {{1, "X"}, {2, "Y"}, {3, "Z"}, {4, "b"}};
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, opNames);

    Qubit q1 = tr->AllocateQubit();
    tr->TraceSingleQubitOp(3, 1, q1);
    tr->TraceSingleQubitOp(5, 1, q1);
    tr->InjectGlobalBarrier(4, 2);
    tr->TraceSingleQubitOp(3, 4, q1);
    tr->TraceSingleQubitOp(2, 1, q1);

    {
        std::stringstream out;
        tr->PrintLayerMetrics(out, ",", true /*printZeroMetrics*/);
        std::string metrics = out.str();

        std::stringstream expected;
        expected << "layer_id,name,Y,Z,5" << std::endl;
        expected << "0,,0,1,0" << std::endl;
        expected << "1,,0,0,1" << std::endl;
        expected << "2,b,0,0,0" << std::endl;
        expected << "4,,0,1,0" << std::endl;
        expected << "8,,1,0,0" << std::endl;

        INFO(metrics);
        CHECK(metrics == expected.str());
    }

    {
        std::stringstream out;
        tr->PrintLayerMetrics(out, ",", false /*printZeroMetrics*/);
        std::string metrics = out.str();

        std::stringstream expected;
        expected << "layer_id,name,Y,Z,5" << std::endl;
        expected << "0,,,1," << std::endl;
        expected << "1,,,,1" << std::endl;
        expected << "2,b,,," << std::endl;
        expected << "4,,,1," << std::endl;
        expected << "8,,1,," << std::endl;

        INFO(metrics);
        CHECK(metrics == expected.str());
    }
}

TEST_CASE("Output: to file", "[tracer]")
{
    std::unordered_map<OpId, std::string> opNames = {{1, "X"}, {2, "Y"}, {3, "Z"}, {4, "b"}};
    shared_ptr<CTracer> tr = CreateTracer(1 /*layer duration*/, opNames);

    Qubit q1 = tr->AllocateQubit();
    tr->TraceSingleQubitOp(3, 1, q1);
    tr->TraceSingleQubitOp(5, 1, q1);
    tr->InjectGlobalBarrier(4, 2);
    tr->TraceSingleQubitOp(3, 4, q1);
    tr->TraceSingleQubitOp(2, 1, q1);

    const std::string fileName = "tracer-test.txt";
    std::ofstream out;
    out.open(fileName);
    tr->PrintLayerMetrics(out, "\t", false /*printZeroMetrics*/);
    out.close();

    std::ifstream in(fileName);
    string line;
    REQUIRE(in.is_open());
    std::string metrics(std::istreambuf_iterator<char>{in}, {});
    in.close();

    std::stringstream expected;
    expected << "layer_id\tname\tY\tZ\t5" << std::endl;
    expected << "0\t\t\t1\t" << std::endl;
    expected << "1\t\t\t\t1" << std::endl;
    expected << "2\tb\t\t\t" << std::endl;
    expected << "4\t\t\t1\t" << std::endl;
    expected << "8\t\t1\t\t" << std::endl;

    INFO(metrics);
    CHECK(metrics == expected.str());
}
