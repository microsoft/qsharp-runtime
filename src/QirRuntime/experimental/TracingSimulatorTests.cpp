#include <iostream>

#include "catch.hpp"

#include "ExperimentalSimFactory.hpp"
#include "IQuantumApi.hpp"
#include "ITranslator.hpp"

using namespace quantum;
using namespace std;

static void AllocateQubits(IQuantumApi* iqa, int count, Qubit* qubits)
{
    for (int i = 0; i < count; i++)
    {
        qubits[i] = iqa->AllocateQubit();
    }
}
static void ReleaseQubits(IQuantumApi* iqa, int count, Qubit* qubits)
{
    for (int i = 0; i < count; i++)
    {
        iqa->ReleaseQubit(qubits[i]);
    }
}

TEST_CASE("Tracing Simulator: no resources used", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    REQUIRE(os.str() == "{\"qubit_width\":0,\"statistics\":[]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: simple program", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    Qubit q = iqa->AllocateQubit();
    iqa->ReleaseQubit(q);

    q = iqa->AllocateQubit();
    iqa->X(q);
    iqa->ReleaseQubit(q);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    REQUIRE(os.str() == "{\"qubit_width\":1,\"circuit_depth\":1,\"statistics\":[{\"metric\":\"cX\",\"value\":1},]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: optimize qubit width, no dependencies", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_QubitWidth);

    const int n = 3;
    Qubit qs[n];

    AllocateQubits(iqa.get(), n, qs);
    for (int i = 0; i < n; i++)
    {
        iqa->X(qs[i]);
    }
    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    REQUIRE(os.str() == "{\"qubit_width\":1,\"statistics\":[{\"metric\":\"cX\",\"value\":3},]}");
    REQUIRE(errors.str().empty());
}

void NoDependenciesStaggeredAllocation(OptimizeFor settings, ostringstream& os, ostringstream* errors)
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, settings);

    const int n = 3;
    for (int i = 0; i < n; i++)
    {
        Qubit q = iqa->AllocateQubit();
        iqa->X(q);
        iqa->ReleaseQubit(q);
    }

    itr->PrintRepresentation(os, errors);
}
TEST_CASE("Tracing Simulator: optimize circuit depth, no dependencies", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    const int n = 3;
    for (int i = 0; i < n; i++)
    {
        Qubit q = iqa->AllocateQubit();
        iqa->X(q);
        iqa->ReleaseQubit(q);
    }

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    REQUIRE(os.str() == "{\"qubit_width\":3,\"circuit_depth\":1,\"statistics\":[{\"metric\":\"cX\",\"value\":3},]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: shared gate sinks all qubits to the lowest of their depth", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    const int n = 3;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    iqa->H(qs[0]);
    iqa->CNOT(qs[0], qs[1]);
    iqa->ControlledX(2, qs, qs[2]);
    iqa->Z(qs[2]);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":3,\"circuit_depth\":4") != string::npos);
    REQUIRE(errors.str().empty());
}

/*
        +-------+  +----+  +-------+
0+------+       +--+    +--+       +--+0
        |       |  |    |  |       |
        |   U   |  |    |  |   V   |
        |       |  |    |  |       |
0+------+       +--+ G  +--+       +--+0
        +-------+  |    |  +-------+
                   |    |
                   |    |  +----+
ψ+-----------------+    +--+    +--------------+
                   +----+  |    |
                           |    |
                +-------+  |    |  +-------+
        0+------+       +--+ G  +--+       +--+0
                |       |  |    |  |       |
                |   U   |  |    |  |   V   |
                |       |  |    |  |       |
        0+------+       +--+    +--+       +--+0
                +-------+  +----+  +-------+
depth of this circuit is: depth(U) + 2*depth(G) + depth(V)
*/
TEST_CASE("Tracing Simulator: overlapping sub-circuits", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    const int n = 5;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    // top subcircuit
    // U
    iqa->H(qs[0]);
    iqa->CNOT(qs[0], qs[1]);
    // G
    iqa->ControlledH(2, qs, qs[2]);
    iqa->CNOT(qs[2], qs[0]);
    iqa->Z(qs[1]);
    // V
    iqa->T(qs[0]);

    // bottom subcircuit
    // U
    iqa->H(qs[3]);
    iqa->CNOT(qs[3], qs[4]);
    // G
    iqa->ControlledH(2, &qs[3], qs[2]);
    iqa->CNOT(qs[2], qs[3]);
    iqa->Z(qs[4]);
    // V
    iqa->T(qs[3]);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    INFO(os.str());
    // depth(U) + 2*depth(G) + depth(V) = 2 + 2*2 + 1 = 7
    REQUIRE(os.str().find("\"qubit_width\":5,\"circuit_depth\":7") != string::npos);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: can reuse qubit while keepting optimal depth", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_CircuitDepth);

    const int n = 4;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    iqa->T(qs[0]);

    iqa->X(qs[1]);
    iqa->H(qs[1]);

    iqa->H(qs[2]);
    iqa->CNOT(qs[2], qs[3]);

    iqa->CNOT(qs[1], qs[3]);
    iqa->S(qs[1]);

    // start/end depths of the qubits above are:
    // 0: {1,1}
    // 1: {1,4}
    // 2: {1,2}
    // 3: {2,4}
    // thus, qs[0] and qs[3] can be merged without affecting the depth of the circuit

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":3,\"circuit_depth\":4") != string::npos);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: optimal qubit width for two independent groups", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_QubitWidth);

    const int n = 5;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    // first group involves three qubits, none of which can be reused
    iqa->H(qs[0]);
    iqa->CNOT(qs[0], qs[1]);
    iqa->CNOT(qs[1], qs[2]);
    iqa->CNOT(qs[2], qs[0]);

    // second group involves two qubits
    iqa->H(qs[3]);
    iqa->CNOT(qs[3], qs[4]);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    // second group should reuse the qubits from the first group
    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":3") != string::npos);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: chained CNOTs", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_QubitWidth);

    const int n = 5;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    iqa->H(qs[0]);
    iqa->CNOT(qs[0], qs[1]);
    iqa->CNOT(qs[1], qs[2]);
    iqa->CNOT(qs[2], qs[3]);
    iqa->CNOT(qs[3], qs[4]);
    (void)iqa->M(qs[4]);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    // The circuit creates state |00000> + |11111>, but "reads" only the last qubit, so it can be compacted to
    // use only two qubits. However, our interference algorithm doesn't find the optimum and settles on width of 3.
    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":3") != string::npos);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: one qubits interferes with all", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_QubitWidth);

    const int n = 4;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    iqa->H(qs[0]);
    iqa->X(qs[1]);
    iqa->T(qs[1]);
    iqa->Z(qs[2]);
    iqa->ControlledR(3, qs, PauliId_Y, qs[3], 4.2);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    // second group should reuse the qubits from the first group
    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":4") != string::npos);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Tracing Simulator: triangle of CNOTs", "[tracing_simulator]")
{
    std::shared_ptr<ITranslator> itr = CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateTracingSimulator(itr, OptimizeFor_QubitWidth);

    const int n = 4;
    Qubit qs[n];
    AllocateQubits(iqa.get(), n, qs);

    iqa->CNOT(qs[0], qs[1]);
    iqa->CNOT(qs[2], qs[3]);
    iqa->CNOT(qs[1], qs[2]);

    ReleaseQubits(iqa.get(), n, qs);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    INFO(os.str());
    REQUIRE(os.str().find("\"qubit_width\":3") != string::npos);
    REQUIRE(errors.str().empty());
}

