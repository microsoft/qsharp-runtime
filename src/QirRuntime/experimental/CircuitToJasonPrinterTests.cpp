#include <iostream>
#include <vector>

#include "catch.hpp"

#include "ExperimentalSimFactory.hpp"
#include "IQuantumApi.hpp"
#include "ITranslator.hpp"

using namespace quantum;
using namespace std;

TEST_CASE("Empty program", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":0,\"circuit\":[]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Qubit allocation", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    iqa->ReleaseQubit(iqa->AllocateQubit());
    iqa->ReleaseQubit(iqa->AllocateQubit());

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":2,\"circuit\":[]}");
    REQUIRE(errors.str().empty());
}

// measurements aren't recorded in the program
TEST_CASE("Measurement", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q = iqa->AllocateQubit();
    iqa->M(q);
    iqa->ReleaseQubit(q);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":1,\"circuit\":[]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Simple gates", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q = iqa->AllocateQubit();
    iqa->X(q);
    iqa->Y(q);
    iqa->Z(q);
    iqa->H(q);
    iqa->S(q);
    iqa->SAdjoint(q);
    iqa->T(q);
    iqa->TAdjoint(q);
    iqa->ReleaseQubit(q);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    string expected = "{\"qubits\":1,\"circuit\":["
                      "{\"gate\":\"x\",\"target\":0,},"
                      "{\"gate\":\"y\",\"target\":0,},"
                      "{\"gate\":\"z\",\"target\":0,},"
                      "{\"gate\":\"h\",\"target\":0,},"
                      "{\"gate\":\"s\",\"target\":0,},"
                      "{\"gate\":\"si\",\"target\":0,},"
                      "{\"gate\":\"t\",\"target\":0,},"
                      "{\"gate\":\"ti\",\"target\":0,},"
                      "]}";
    REQUIRE(os.str() == expected);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Rotations, etc.", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q1 = iqa->AllocateQubit();
    Qubit q2 = iqa->AllocateQubit();

    iqa->R(PauliId_X, q1, 0.4);
    iqa->R(PauliId_Y, q1, 0.4);
    iqa->R(PauliId_Z, q2, 0.4);
    iqa->SWAP(q1, q2);

    Qubit qubits[] = {q1, q2};

    PauliId paulisX[] = {PauliId_X, PauliId_X};
    iqa->Exp(2, paulisX, qubits, 0.4);
    PauliId paulisY[] = {PauliId_Y, PauliId_Y};
    iqa->Exp(2, paulisY, qubits, 0.4);
    PauliId paulisZ[] = {PauliId_Z, PauliId_Z};
    iqa->Exp(2, paulisZ, qubits, 0.4);

    iqa->ReleaseQubit(q1);
    iqa->ReleaseQubit(q2);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    string expected = "{\"qubits\":2,\"circuit\":["
                      "{\"gate\":\"rx\",\"target\":0,\"rotation\":0.4,},"
                      "{\"gate\":\"ry\",\"target\":0,\"rotation\":0.4,},"
                      "{\"gate\":\"rz\",\"target\":1,\"rotation\":0.4,},"
                      "{\"gate\":\"swap\",\"target\":[0,1,],},"
                      "{\"gate\":\"xx\",\"target\":[0,1,],\"rotation\":0.2,},"
                      "{\"gate\":\"yy\",\"target\":[0,1,],\"rotation\":0.2,},"
                      "{\"gate\":\"zz\",\"target\":[0,1,],\"rotation\":0.2,},"
                      "]}";
    REQUIRE(os.str() == expected);
    REQUIRE(errors.str().empty());
}

TEST_CASE("Unsupported exponent", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q1 = iqa->AllocateQubit();
    Qubit q2 = iqa->AllocateQubit();
    Qubit q3 = iqa->AllocateQubit();

    Qubit qubits[] = {q1, q2, q3};
    PauliId paulis[] = {PauliId_X, PauliId_X, PauliId_X};

    // wrong number of qubits
    iqa->Exp(1, paulis, qubits, 0.4);
    iqa->Exp(3, paulis, qubits, 0.4);

    // PauliId matrices should be the same
    paulis[0] = PauliId_Y;
    iqa->Exp(2, paulis, qubits, 0.4);

    // PauliId matrices shouldn't be Identity
    paulis[0] = PauliId_I;
    paulis[1] = PauliId_I;
    iqa->Exp(2, paulis, qubits, 0.4);

    iqa->ReleaseQubit(q1);
    iqa->ReleaseQubit(q2);
    iqa->ReleaseQubit(q3);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    REQUIRE(os.str() == "{\"qubits\":3,\"circuit\":[]}");
    INFO(errors.str());
    REQUIRE(errors.str().find("Exp", 0) != string::npos);
}

TEST_CASE("Controlled gates", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q1 = iqa->AllocateQubit();
    Qubit q2 = iqa->AllocateQubit();
    Qubit q3 = iqa->AllocateQubit();
    Qubit controls[] = {q2, q3};

    iqa->ControlledX(2, controls, q1);
    iqa->ControlledR(1, &q2, PauliId_X, q1, 0.3);
    iqa->ControlledSWAP(1, &q1, q2, q3);

    iqa->ReleaseQubit(q1);
    iqa->ReleaseQubit(q2);
    iqa->ReleaseQubit(q3);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);

    string expected = "{\"qubits\":3,\"circuit\":["
                      "{\"gate\":\"x\",\"target\":0,\"control\":[1,2,],},"
                      "{\"gate\":\"rx\",\"target\":0,\"control\":1,\"rotation\":0.3,},"
                      "{\"gate\":\"swap\",\"target\":[1,2,],\"control\":0,},"
                      "]}";
    REQUIRE(os.str() == expected);
    REQUIRE(errors.str().empty());
}

// Translator should ignore quantum operations on already measured qubit and
// log an error.
TEST_CASE("Qubit use after measurement", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q = iqa->AllocateQubit();
    iqa->M(q);
    iqa->X(q);
    iqa->ReleaseQubit(q);

    q = iqa->AllocateQubit();
    iqa->Y(q);
    iqa->ReleaseQubit(q);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":2,\"circuit\":[{\"gate\":\"y\",\"target\":1,},]}");
    INFO(errors.str());
    REQUIRE(errors.str().find("x", 0) != string::npos);
}

TEST_CASE("Qubit use after release", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Qubit q = iqa->AllocateQubit();
    iqa->ReleaseQubit(q);
    iqa->X(q);

    q = iqa->AllocateQubit();
    iqa->Y(q);
    iqa->ReleaseQubit(q);

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":2,\"circuit\":[{\"gate\":\"y\",\"target\":1,},]}");

    INFO(errors.str());
    REQUIRE(errors.str().find("x", 0) != string::npos);
}

TEST_CASE("Can get result value only from constants", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Result zero = iqa->UseZero();
    REQUIRE(Result_Zero == iqa->GetResultValue(zero));

    Result one = iqa->UseOne();
    REQUIRE(Result_One == iqa->GetResultValue(one));

    Qubit q = iqa->AllocateQubit();
    Result r = iqa->M(q);
    iqa->ReleaseQubit(q);
    REQUIRE(Result_Pending == iqa->GetResultValue(r));

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":1,\"circuit\":[]}");
    REQUIRE(errors.str().empty());
}

TEST_CASE("Comparing results is limited", "[circuit_printer]")
{
    std::shared_ptr<ITranslator> itr = CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> iqa = CreateCircuitPrintingSimulator(itr);

    Result zero = iqa->UseZero();
    Result one = iqa->UseOne();

    Qubit q = iqa->AllocateQubit();
    Result r = iqa->M(q);
    iqa->ReleaseQubit(q);

    REQUIRE(TernaryBool_True == iqa->AreEqualResults(zero, zero));
    REQUIRE(TernaryBool_True == iqa->AreEqualResults(one, one));
    REQUIRE(TernaryBool_False == iqa->AreEqualResults(zero, one));
    REQUIRE(TernaryBool_Undefined == iqa->AreEqualResults(zero, r));
    REQUIRE(TernaryBool_Undefined == iqa->AreEqualResults(r, r));

    ostringstream os, errors;
    itr->PrintRepresentation(os, &errors);
    REQUIRE(os.str() == "{\"qubits\":1,\"circuit\":[]}");

    INFO(errors.str());
    REQUIRE(errors.str().find("\"error_count\":2", 0) != string::npos);
}