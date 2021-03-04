// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "CLI11.hpp"
#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include "quantum__qis_internal.hpp"
#include "quantum__rt.hpp"
#include <cctype>
#include <iostream>
#include <map>
#include <vector>

using namespace Microsoft::Quantum;
using namespace std;

// This is the function corresponding to the QIR entry-point.
extern "C" int64_t Quantum__StandaloneSupportedInputs__ExerciseInputs__body( // NOLINT
    int64_t intValue,
    double doubleValue);

map<string, PauliId> PauliMap{
    {"PauliI", PauliId::PauliId_I},
    {"PauliX", PauliId::PauliId_X},
    {"PauliY", PauliId::PauliId_Y},
    {"PauliZ", PauliId::PauliId_Z}};

map<string, bool> ResultMap{
    {"0", false},
    {"Zero", false},
    {"1", true},
    {"One", true}};

int main(int argc, char* argv[])
{
    CLI::App app("QIR Standalone Entry Point Inputs Reference");

    // Initialize simulator.
    unique_ptr<ISimulator> sim = CreateFullstateSimulator();
    QirContextScope qirctx(sim.get(), false /*trackAllocatedObjects*/);

    // Add the --simulation-output and --operation-output options.
    // N.B. These options should be present in all standalone drivers.
    string simulationOutputFile;
    CLI::Option* simulationOutputFileOpt = app.add_option(
        "-s,--simulation-output", simulationOutputFile,
        "File where the output produced during the simulation is written");

    string operationOutputFile;
    CLI::Option* operationOutputFileOpt = app.add_option(
        "-o,--operation-output", operationOutputFile, "File where the output of the Q# operation is written");

    // Add the options that correspond to the parameters that the QIR entry-point needs.
    // Option for a Q# Int type.
    int64_t intValue = 0;
    app.add_option("--int-value", intValue, "An integer value")->required();

    // Option for a Q# Double type.
    double_t doubleValue = 0.0;
    app.add_option("--double-value", doubleValue, "A double value")->required();

    // Option for a Q# Bool type.
    bool boolValue = false;
    app.add_option("--bool-value", boolValue, "A bool value")->required();

    // Option for Q# Pauli type.
    PauliId pauliValue = PauliId::PauliId_I;
    app.add_option("--pauli-value", pauliValue, "A Pauli value")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for Q# Range type.
    tuple<int64_t, int64_t, int64_t> rangeValue(0, 0, 0);
    app.add_option("--range-value", rangeValue, "A Range value (start, step, end)")->required();
    QirRange qirRange = {
        get<0>(rangeValue), // Start
        get<1>(rangeValue), // Step
        get<2>(rangeValue)  // End
    };

    // Option for Q# Result type.
    bool resultValue = false;
    app.add_option("--result-value", resultValue, "A Result value")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultMap, CLI::ignore_case));

    Result result = resultValue ? sim->UseOne() : sim->UseZero();

    // Option for Q# String type.
    string stringValue;
    app.add_option("--string-value", stringValue, "A String value")->required();
    QirString* qirString = quantum__rt__string_create(stringValue.c_str());

    // Option for a Q# Array<Int> type.
    vector<int64_t> integerArray;
    CLI::Option* integerArrayOpt = app.add_option("--integer-array", integerArray, "An integer array")->required();

    // With all the options added, parse arguments from the command line.
    CLI11_PARSE(app, argc, argv);

    // Redirect the simulator output from std::cout if the --simulator-output option is present.
    ostream* simulatorOutputStream = &cout;
    filebuf simulationOutputFileBuffer;
    if (!simulationOutputFileOpt->empty())
    {
        simulationOutputFileBuffer.open(simulationOutputFile, ios::out);
        ostream simulationOutputFileStream(&simulationOutputFileBuffer);
        Quantum::Qis::Internal::SetOutputStream(simulationOutputFileStream);
        simulatorOutputStream = &simulationOutputFileStream;
    }

    // Redirect the Q# operation output from std::cout if the --operation-output option is present.
    ostream* operationOutputStream = &cout;
    filebuf operationOutputFileBuffer;
    if (!operationOutputFileOpt->empty())
    {
        operationOutputFileBuffer.open(operationOutputFile, ios::out);
        ostream operationOutputFileStream(&operationOutputFileBuffer);
        operationOutputStream = &operationOutputFileStream;
    }

    // Run simulation and write the output of the operation to the corresponding stream.
    int64_t operationOutput = Quantum__StandaloneSupportedInputs__ExerciseInputs__body(intValue, doubleValue);
    simulatorOutputStream->flush();
    (*operationOutputStream) << "1";
    operationOutputStream->flush();

    // Close opened file buffers;
    if (!simulationOutputFileOpt->empty())
    {
        simulationOutputFileBuffer.close();
    }

    if (!operationOutputFileOpt->empty())
    {
        operationOutputFileBuffer.close();
    }
}
