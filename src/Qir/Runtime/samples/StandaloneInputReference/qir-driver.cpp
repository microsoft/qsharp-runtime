// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

#include "CLI11.hpp"

#include "QirContext.hpp"
#include "QirRuntime.hpp"
#include "SimFactory.hpp"

using namespace Microsoft::Quantum;
using namespace std;

struct InteropArray
{
    int64_t Size;
    void* Data;

    InteropArray(int64_t size, void* data) :
        Size(size),
        Data(data){}
};

using RangeTuple = tuple<int64_t, int64_t, int64_t>;
struct InteropRange
{
    int64_t Start;
    int64_t Step;
    int64_t End;

    InteropRange() :
        Start(0),
        Step(0),
        End(0){}

    InteropRange(RangeTuple rangeTuple) :
        Start(get<0>(rangeTuple)),
        Step(get<1>(rangeTuple)),
        End(get<2>(rangeTuple)){}
};

// This is the function corresponding to the QIR entry-point.
extern "C" void Quantum__StandaloneSupportedInputs__ExerciseInputs( // NOLINT
    int64_t intValue,
    InteropArray* integerArray,
    double doubleValue,
    InteropArray* doubleArray,
    char boolValue,
    InteropArray* boolArray,
    char pauliValue,
    InteropArray* pauliArray,
    InteropRange* rangeValue,
    char resultValue,
    InteropArray* resultArray,
    const char* stringValue);

const char InteropFalseAsChar = 0x0;
const char InteropTrueAsChar = 0x1;
map<string, bool> BoolAsCharMap{
    {"0", InteropFalseAsChar},
    {"false", InteropFalseAsChar},
    {"1", InteropTrueAsChar},
    {"true", InteropTrueAsChar}};

map<string, PauliId> PauliMap{
    {"PauliI", PauliId::PauliId_I},
    {"PauliX", PauliId::PauliId_X},
    {"PauliY", PauliId::PauliId_Y},
    {"PauliZ", PauliId::PauliId_Z}};

const char InteropResultZeroAsChar = 0x0;
const char InteropResultOneAsChar = 0x1;
map<string, char> ResultAsCharMap{
    {"0", InteropResultZeroAsChar},
    {"Zero", InteropResultZeroAsChar},
    {"1", InteropResultOneAsChar},
    {"One", InteropResultOneAsChar}
};

template<typename T>
unique_ptr<InteropArray> CreateInteropArray(vector<T>& v)
{
    unique_ptr<InteropArray> array(new InteropArray(v.size(), v.data()));
    return array;
}

unique_ptr<InteropRange> CreateInteropRange(RangeTuple rangeTuple)
{
    unique_ptr<InteropRange> range(new InteropRange(rangeTuple));
    return range;
}

template<typename T>
void FreePointerVector(vector<T*>& v)
{
    for (auto p : v)
    {
        delete p;
    }
}

char TranslatePauliToChar(PauliId& pauli)
{
    return static_cast<char>(pauli);
}

template<typename S, typename D>
void TranslateVector(vector<S>& sourceVector, vector<D>& destinationVector, function<D(S&)> translationFunction)
{
    destinationVector.resize(sourceVector.size());
    transform(sourceVector.begin(), sourceVector.end(), destinationVector.begin(), translationFunction);
}

InteropRange* TranslateRangeTupleToInteropRangePointer(RangeTuple& rangeTuple)
{
    InteropRange* range = new InteropRange(rangeTuple);
    return range;
}

const char* TranslateStringToCharBuffer(string& s)
{
    return s.c_str();
}

int main(int argc, char* argv[])
{
    cout << "00" << endl;
    CLI::App app("QIR Standalone Entry Point Inputs Reference");

    // Initialize simulator.
    cout << "01" << endl;
    unique_ptr<IRuntimeDriver> sim = CreateFullstateSimulator();
    QirContextScope qirctx(sim.get(), false /*trackAllocatedObjects*/);

    // Add the --simulation-output options.
    // N.B. This option should be present in all standalone drivers.
    cout << "02" << endl;
    string simulationOutputFile;
    CLI::Option* simulationOutputFileOpt = app.add_option(
        "-s,--simulation-output", simulationOutputFile,
        "File where the output produced during the simulation is written");

    // Add the options that correspond to the parameters that the QIR entry-point needs.
    // Option for a Q# Int type.
    cout << "03" << endl;
    int64_t intValue = 0;
    app.add_option("--int-value", intValue, "An integer value")->required();

    // Option for a Q# Array<Int> type.
    cout << "04" << endl;
    vector<int64_t> integerVector;
    app.add_option("--integer-array", integerVector, "An integer array")->required();

    // Option for a Q# Double type.
    cout << "05" << endl;
    double_t doubleValue = 0.0;
    app.add_option("--double-value", doubleValue, "A double value")->required();

    // Option for a Q# Array<Double> type.
    cout << "06" << endl;
    vector<double_t> doubleVector;
    app.add_option("--double-array", doubleVector, "A double array")->required();

    // Option for a Q# Bool type.
    cout << "07" << endl;
    char boolAsCharValue = InteropFalseAsChar;
    app.add_option("--bool-value", boolAsCharValue, "A bool value")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolAsCharMap, CLI::ignore_case));

    // Option for a Q# Array<Bool> type.
    // N.B. For command line parsing, a char vector is used because vector<bool> is a specialized version of vector not
    //      supported by CLI11.
    cout << "08" << endl;
    vector<char> boolAsCharVector;
    app.add_option("--bool-array", boolAsCharVector, "A bool array")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolAsCharMap, CLI::ignore_case));

    // Option for Q# Pauli type.
    cout << "09" << endl;
    PauliId pauliValue = PauliId::PauliId_I;
    app.add_option("--pauli-value", pauliValue, "A Pauli value")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for a Q# Array<Pauli> type.
    cout << "10" << endl;
    std::vector<PauliId> pauliVector;
    app.add_option("--pauli-array", pauliVector, "A Pauli array")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for Q# Range type.
    // N.B. RangeTuple type is used here instead of QirRange because CLI11 supports tuple parsing which is leveraged and
    //      the tuple is later translated to QirRange.
    cout << "11" << endl;
    RangeTuple rangeTuple(0, 0, 0);
    app.add_option("--range-value", rangeTuple, "A Range value (start, step, end)")->required();

    // Option for a Q# Array<Range> type.
    cout << "12" << endl;
    vector<RangeTuple> rangeTupleVector;
    app.add_option("--range-array", rangeTupleVector, "A Range array")->required();

    // Option for Q# Result type.
    // N.B. This is implemented as a char rather than a boolean to be consistent with the way an array of results has to
    //      be implemented.
    cout << "13" << endl;
    char resultAsCharValue = InteropResultZeroAsChar;
    app.add_option("--result-value", resultAsCharValue, "A Result value")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultAsCharMap, CLI::ignore_case));

    // Option for a Q# Array<Result> type.
    // N.B. Similarly to the case of Q# Array<bool>, for command line parsing, a char vector is used because CLI11 does
    //      not support vector<bool> since it is a specialized version of vector.
    cout << "14" << endl;
    vector<char> resultAsCharVector;
    app.add_option("--result-array", resultAsCharVector, "A Result array")
        ->required()
        ->transform(CLI::CheckedTransformer(ResultAsCharMap, CLI::ignore_case));

    // Option for Q# String type.
    cout << "15" << endl;
    string stringValue;
    app.add_option("--string-value", stringValue, "A String value")->required();

    // Option for a Q# Array<String> type.
    cout << "16" << endl;
    vector<string> stringVector;
    app.add_option("--string-array", stringVector, "A String array")->required();


    // With all the options added, parse arguments from the command line.
    cout << "17" << endl;
    CLI11_PARSE(app, argc, argv);

    // Translate values to its final form after parsing.
    // Create an interop array of integer values.
    cout << "18" << endl;
    unique_ptr<InteropArray> integerArray = CreateInteropArray(integerVector);

    // Create an interop array of double values.
    cout << "19" << endl;
    unique_ptr<InteropArray> doubleArray = CreateInteropArray(doubleVector);

    // Create an interop array of bool values.
    cout << "20" << endl;
    unique_ptr<InteropArray> boolArray = CreateInteropArray(boolAsCharVector);

    // Translate a PauliID value to its char representation.
    cout << "21" << endl;
    char pauliAsCharValue = TranslatePauliToChar(pauliValue);

    // Create an interop array of Pauli values represented as chars.
    cout << "22" << endl;
    vector<char> pauliAsCharVector;
    TranslateVector<PauliId, char>(pauliVector, pauliAsCharVector, TranslatePauliToChar);
    unique_ptr<InteropArray> pauliArray = CreateInteropArray(pauliAsCharVector);

    // Create an interop range.
    cout << "23" << endl;
    unique_ptr<InteropRange> rangeValue = CreateInteropRange(rangeTuple);
    vector<InteropRange*> rangeVector;
    TranslateVector<RangeTuple, InteropRange*>(rangeTupleVector, rangeVector, TranslateRangeTupleToInteropRangePointer);
    unique_ptr<InteropArray> rangeArray = CreateInteropArray(rangeVector);

    // Create an interop array of Result values.
    cout << "24" << endl;
    unique_ptr<InteropArray> resultArray = CreateInteropArray(resultAsCharVector);

    // Create an interop array of String values.
    cout << "25" << endl;
    vector<const char *> stringBufferVector;
    TranslateVector<string, const char*>(stringVector, stringBufferVector, TranslateStringToCharBuffer);
    unique_ptr<InteropArray> stringArray = CreateInteropArray(stringBufferVector);

    // Redirect the simulator output from std::cout if the --simulation-output option is present.
    cout << "26" << endl;
    ostream* simulatorOutputStream = &cout;
    ofstream simulationOutputFileStream;
    if (!simulationOutputFileOpt->empty())
    {
        simulationOutputFileStream.open(simulationOutputFile);
        SetOutputStream(simulationOutputFileStream);
        simulatorOutputStream = &simulationOutputFileStream;
    }

    // Run simulation and write the output of the operation to the corresponding stream.
    cout << "27" << endl;
    Quantum__StandaloneSupportedInputs__ExerciseInputs(
        intValue,
        integerArray.get(),
        doubleValue,
        doubleArray.get(),
        boolAsCharValue,
        boolArray.get(),
        pauliAsCharValue,
        pauliArray.get(),
        rangeValue.get(),
        resultAsCharValue,
        resultArray.get(),
        stringValue.c_str());

    cout << "28" << endl;
    FreePointerVector(rangeVector);
    simulatorOutputStream->flush();
    if (simulationOutputFileStream.is_open())
    {
        simulationOutputFileStream.close();
    }
}
