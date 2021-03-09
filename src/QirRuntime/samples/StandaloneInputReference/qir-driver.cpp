// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstring> // for memcpy
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

#include "CLI11.hpp"

#include "CoreTypes.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"

#include "quantum__qis_internal.hpp"
#include "quantum__rt.hpp"

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

const char FalseAsChar = 0x0;
const char TrueAsChar = 0x1;
map<string, bool> BoolAsCharMap{
    {"0", FalseAsChar},
    {"false", FalseAsChar},
    {"1", TrueAsChar},
    {"true", TrueAsChar}};

map<string, PauliId> PauliMap{
    {"PauliI", PauliId::PauliId_I},
    {"PauliX", PauliId::PauliId_X},
    {"PauliY", PauliId::PauliId_Y},
    {"PauliZ", PauliId::PauliId_Z}};

map<string, char> ResultAsCharMap{
    {"0", FalseAsChar},
    {"Zero", FalseAsChar},
    {"false", FalseAsChar},
    {"1", TrueAsChar},
    {"One", TrueAsChar},
    {"true", TrueAsChar}};

template<typename T>
QirArray* CreateQirArray(T* dataBuffer, int64_t itemCount)
{
    int32_t typeSize = sizeof(T); // NOLINT
    QirArray* qirArray = quantum__rt__array_create_1d(typeSize, itemCount);
    memcpy(qirArray->buffer, dataBuffer, typeSize * itemCount);
    return qirArray;
}

template<typename D, typename S>
unique_ptr<D[]> TranslateVectorToBuffer(vector<S>sourceVector, function<D(S)> translationFunction)
{
    unique_ptr<D[]> buffer (new D[sourceVector.size()]);
    for (int index = 0; index < sourceVector.size(); index++)
    {
        buffer[index] = translationFunction(sourceVector[index]);
    }

    return buffer;
}

using RangeTuple = tuple<int64_t, int64_t, int64_t>;
QirRange TranslateRangeTupleToQirRange(RangeTuple rangeTuple)
{
    QirRange qirRange = {
        get<0>(rangeTuple), // Start
        get<1>(rangeTuple), // Step
        get<2>(rangeTuple)  // End
    };

    return qirRange;
}

bool TranslateCharToBool(char boolAsChar)
{
    return (boolAsChar != FalseAsChar);
}

// Result Zero and One are opaque types defined by the runtime. They are declared here and initialized before executing
// the simulation.
Result RuntimeResultZero = nullptr;
Result RuntimeResultOne = nullptr;
Result TranslateCharToResult(char resultAsChar)
{
    return resultAsChar == FalseAsChar ? RuntimeResultZero : RuntimeResultOne;
}

int main(int argc, char* argv[])
{
    CLI::App app("QIR Standalone Entry Point Inputs Reference");

    // Initialize simulator.
    unique_ptr<ISimulator> sim = CreateFullstateSimulator();
    QirContextScope qirctx(sim.get(), false /*trackAllocatedObjects*/);
    RuntimeResultZero = sim->UseZero();
    RuntimeResultOne = sim->UseOne();

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
    vector<int64_t> integerVector;
    app.add_option("--integer-array", integerVector, "An integer array")->required();

    // Option for a Q# Double type.
    double_t doubleValue = 0.0;
    app.add_option("--double-value", doubleValue, "A double value")->required();

    // Option for a Q# Array<Double> type.
    vector<double_t> doubleVector;
    app.add_option("--double-array", doubleVector, "A double array")->required();

    // Option for a Q# Bool type.
    bool boolValue = false;
    app.add_option("--bool-value", boolValue, "A bool value")->required();

    // Option for a Q# Array<Bool> type.
    // N.B. For command line parsing, a char vector is used because vector<bool> is a specialized version of vector not
    //      supported by CLI11.
    vector<char> boolAsCharVector;
    app.add_option("--bool-array", boolAsCharVector, "A bool array")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolAsCharMap, CLI::ignore_case));

    // Option for Q# Pauli type.
    PauliId pauliValue = PauliId::PauliId_I;
    app.add_option("--pauli-value", pauliValue, "A Pauli value")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for a Q# Array<Pauli> type.
    std::vector<PauliId> pauliVector;
    app.add_option("--pauli-array", pauliVector, "A Pauli array")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for Q# Range type.
    // N.B. RangeTuple type is used here instead of QirRange because CLI11 supports tuple parsing which is leveraged and
    //      the tuple is later translated to QirRange.
    RangeTuple rangeValue(0, 0, 0);
    app.add_option("--range-value", rangeValue, "A Range value (start, step, end)")->required();

    // Option for a Q# Array<Range> type.
    vector<RangeTuple> rangeTupleVector;
    app.add_option("--range-array", rangeTupleVector, "A Range array")->required();

    // Option for Q# Result type.
    // N.B. This is implemented as a char rather than a boolean to be consistent with the way an array of results has to
    //      be implemented.
    char resultAsCharValue = FalseAsChar;
    app.add_option("--result-value", resultAsCharValue, "A Result value")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultAsCharMap, CLI::ignore_case));

    // Option for a Q# Array<Result> type.
    // N.B. Similarly to the case of Q# Array<bool>, for command line parsing, a char vector is used because CLI11 does
    //      not support vector<bool> since it is a specialized version of vector.
    vector<char> resultAsCharVector;
    app.add_option("--result-array", resultAsCharVector, "A Result array")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultAsCharMap, CLI::ignore_case));

    // Option for Q# String type.
    string stringValue;
    app.add_option("--string-value", stringValue, "A String value")->required();

    // With all the options added, parse arguments from the command line.
    CLI11_PARSE(app, argc, argv);

    // Translate values to its final form after parsing.
    // Create a QirArray of integer values.
    QirArray* qirIntegerArray = CreateQirArray(integerVector.data(), integerVector.size());

    // Create a QirArray of double values.
    QirArray* qirDoubleArray = CreateQirArray(doubleVector.data(), doubleVector.size());

    // Create a QirArray of bool values.
    unique_ptr<bool[]> boolArray = TranslateVectorToBuffer<bool, char>(boolAsCharVector, TranslateCharToBool);
    QirArray* qirboolArray = CreateQirArray(boolArray.get(), boolAsCharVector.size());

    // Create a QirArray of Pauli values.
    QirArray* qirPauliArray = CreateQirArray(pauliVector.data(), pauliVector.size());

    // Create a QirRange.
    QirRange qirRange = TranslateRangeTupleToQirRange(rangeValue);

    // Create a QirArray of Range values.
    unique_ptr<QirRange[]> rangeArray = TranslateVectorToBuffer<QirRange, RangeTuple>(
        rangeTupleVector, TranslateRangeTupleToQirRange);

    QirArray* qirRangeArray = CreateQirArray(rangeArray.get(), rangeTupleVector.size());

    // Create a Result.
    Result result = TranslateCharToResult(resultAsCharValue);

    // Create a QirArray of Result values.
    unique_ptr<Result[]> resultArray = TranslateVectorToBuffer<Result, char>(resultAsCharVector, TranslateCharToResult);
    QirArray* qirResultArray = CreateQirArray(resultArray.get(), resultAsCharVector.size());

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
    if (operationOutputFileStream.is_open())
    {
        operationOutputFileStream.close();
    }

    if (simulationOutputFileStream.is_open())
    {
        simulationOutputFileStream.close();
    }
}
