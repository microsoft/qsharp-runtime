// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstring> // for memcpy
#include <fstream>
#include <iostream>
#include <map>
#include <vector>

#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"

#include "quantum__qis_internal.hpp"
#include "quantum__rt.hpp"

#include "CLI11.hpp"

using namespace Microsoft::Quantum;
using namespace std;

// This is the function corresponding to the QIR entry-point.
extern "C" int64_t Quantum__StandaloneSupportedInputs__ExerciseInputs__body( // NOLINT
    int64_t intValue,
    double doubleValue,
    Result resultValue,
    QirString* stringValue,
    int64_t rangeStart,
    int64_t rangeStep,
    int64_t rangeEnd);

map<string, char> BoolMap{
    {"0", 0x0},
    {"false", 0x0},
    {"1", 0x1},
    {"true", 0x1}};

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

    // Option for a Q# Array<Int> type.
    vector<int64_t> integerArray;
    app.add_option("--integer-array", integerArray, "An integer array")->required();

    // Option for a Q# Double type.
    double_t doubleValue = 0.0;
    app.add_option("--double-value", doubleValue, "A double value")->required();

    // Option for a Q# Array<Double> type.
    vector<double_t> doubleArray;
    app.add_option("--double-array", doubleArray, "A double array")->required();

    // Option for a Q# Bool type.
    bool boolValue = false;
    app.add_option("--bool-value", boolValue, "A bool value")->required();

    // Option for a Q# Array<Bool> type.
    std::vector<char> boolArray;
    app.add_option("--bool-array", boolArray, "A bool array")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolMap, CLI::ignore_case));

    // Option for Q# Pauli type.
    PauliId pauliValue = PauliId::PauliId_I;
    app.add_option("--pauli-value", pauliValue, "A Pauli value")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for a Q# Array<Pauli> type.
    std::vector<PauliId> pauliArray;
    app.add_option("--pauli-array", pauliArray, "A Pauli array")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for Q# Range type.
    tuple<int64_t, int64_t, int64_t> rangeValue(0, 0, 0);
    app.add_option("--range-value", rangeValue, "A Range value (start, step, end)")->required();

    // Option for Q# Result type.
    bool resultValue = false;
    app.add_option("--result-value", resultValue, "A Result value")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultMap, CLI::ignore_case));

    // Option for Q# String type.
    string stringValue;
    app.add_option("--string-value", stringValue, "A String value")->required();

    // With all the options added, parse arguments from the command line.
    CLI11_PARSE(app, argc, argv);

    // Translate values to its final form after parsing.
    // Create a QirArray of integer values.
    int32_t integerSize = sizeof(int64_t);
    QirArray* qirIntArray = quantum__rt__array_create_1d(integerSize, integerArray.size());
    memcpy(qirIntArray->buffer, integerArray.data(), integerSize * integerArray.size());

    // Create a QirArray of double values.
    int32_t doubleSize = sizeof(double_t);
    QirArray* qirDoubleArray = quantum__rt__array_create_1d(doubleSize, doubleArray.size());
    memcpy(qirDoubleArray->buffer, doubleArray.data(), doubleSize * doubleArray.size());

    // Create a QirArray of bool values.
    int32_t boolSize = sizeof(bool);
    bool* boolBuffer = new bool[boolArray.size()];
    for (int index = 0; index < boolArray.size(); index++) {
        boolBuffer[index] = boolArray[index] == 0x1 ? true : false;
    }

    QirArray* qirboolArray = quantum__rt__array_create_1d(boolSize, boolArray.size());
    memcpy(qirboolArray->buffer, boolBuffer, boolSize * boolArray.size());

    // Create QirRange.
    QirRange qirRange = {
        get<0>(rangeValue), // Start
        get<1>(rangeValue), // Step
        get<2>(rangeValue)  // End
    };

    // Create a Result.
    Result result = resultValue ? sim->UseOne() : sim->UseZero();

    // Create a QirString.
    QirString* qirString = quantum__rt__string_create(stringValue.c_str());

    // Redirect the simulator output from std::cout if the --simulator-output option is present.
    ostream* simulatorOutputStream = &cout;
    ofstream simulationOutputFileStream;
    if (!simulationOutputFileOpt->empty())
    {
        simulationOutputFileStream.open(simulationOutputFile);
        Quantum::Qis::Internal::SetOutputStream(simulationOutputFileStream);
        simulatorOutputStream = &simulationOutputFileStream;
    }

    // Redirect the Q# operation output from std::cout if the --operation-output option is present.
    ostream* operationOutputStream = &cout;
    ofstream operationOutputFileStream;
    if (!operationOutputFileOpt->empty())
    {
        operationOutputFileStream.open(operationOutputFile);
        operationOutputStream = &operationOutputFileStream;
    }

    // Run simulation and write the output of the operation to the corresponding stream.
    int64_t operationOutput = Quantum__StandaloneSupportedInputs__ExerciseInputs__body(
        intValue, doubleValue, result, qirString, qirRange.start, qirRange.step, qirRange.end);

    simulatorOutputStream->flush();
    (*operationOutputStream) << operationOutput << endl;
    operationOutputStream->flush();

    // Close opened file buffers;
    if (simulationOutputFileStream.is_open())
    {
        simulationOutputFileStream.close();
    }

    if (operationOutputFileStream.is_open())
    {
        operationOutputFileStream.close();
    }
}
