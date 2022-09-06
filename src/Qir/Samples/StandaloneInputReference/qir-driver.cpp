// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

// clang-format off
#pragma clang diagnostic push
    // Temporarily disable `-Wswitch-enum`, one of the `switch`es in "CLI11.hpp" handles not all the enumerators.
    #pragma clang diagnostic ignored "-Wswitch-enum"
    #include "CLI11.hpp"
#pragma clang diagnostic pop
// clang-format on

using namespace std;

namespace // == `static`
{
struct InteropArray
{
    size_t Size; // TODO: Never used?
    void* Data;

    InteropArray(size_t size, void* data) : Size(size), Data(data)
    {
    }
};

using RangeTuple = tuple<int64_t, int64_t, int64_t>;
struct InteropRange
{
    int64_t Start;
    int64_t Step;
    int64_t End;

    [[maybe_unused]] InteropRange() : Start(0), Step(0), End(0)
    {
    }

    [[maybe_unused]] InteropRange(RangeTuple rangeTuple)
        : Start(get<0>(rangeTuple))
        , Step(get<1>(rangeTuple))
        , End(get<2>(rangeTuple))
    {
    }
};

} // namespace

// This is the function corresponding to the QIR entry-point.
extern "C" void Quantum__StandaloneSupportedInputs__ExerciseInputs( // NOLINT
    int64_t intValue, InteropArray* integerArray, double doubleValue, InteropArray* doubleArray, char boolValue,
    InteropArray* boolArray, char pauliValue, InteropArray* pauliArray, InteropRange* rangeValue, char resultValue,
    InteropArray* resultArray, const char* stringValue);

static const char InteropFalseAsChar = 0x0;
static const char InteropTrueAsChar  = 0x1;
static map<string, bool> BoolAsCharMap{{"0", InteropFalseAsChar},
                                       {"false", InteropFalseAsChar},
                                       {"1", InteropTrueAsChar},
                                       {"true", InteropTrueAsChar}};

static map<string, char> PauliMap{{"PauliI", 0}, {"PauliX", 1}, {"PauliY", 3}, {"PauliZ", 2}};

static const char InteropResultZeroAsChar = 0x0;
static const char InteropResultOneAsChar  = 0x1;
static map<string, char> ResultAsCharMap{{"0", InteropResultZeroAsChar},
                                         {"Zero", InteropResultZeroAsChar},
                                         {"1", InteropResultOneAsChar},
                                         {"One", InteropResultOneAsChar}};

template<typename T>
unique_ptr<InteropArray> CreateInteropArray(vector<T>& v)
{
    unique_ptr<InteropArray> array(new InteropArray(v.size(), v.data()));
    return array;
}

static unique_ptr<InteropRange> CreateInteropRange(RangeTuple rangeTuple)
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

template<typename S, typename D>
void TranslateVector(vector<S>& sourceVector, vector<D>& destinationVector, function<D(S&)> translationFunction)
{
    destinationVector.resize(sourceVector.size());
    transform(sourceVector.begin(), sourceVector.end(), destinationVector.begin(), translationFunction);
}

static InteropRange* TranslateRangeTupleToInteropRangePointer(RangeTuple& rangeTuple)
{
    InteropRange* range = new InteropRange(rangeTuple);
    return range;
}

static const char* TranslateStringToCharBuffer(string& s)
{
    return s.c_str();
}

int main(int argc, char* argv[])
{
    CLI::App app("QIR Standalone Entry Point Inputs Reference");

    // Initialize simulator.

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
    char boolAsCharValue = InteropFalseAsChar;
    app.add_option("--bool-value", boolAsCharValue, "A bool value")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolAsCharMap, CLI::ignore_case));

    // Option for a Q# Array<Bool> type.
    // N.B. For command line parsing, a char vector is used because vector<bool> is a specialized version of vector not
    //      supported by CLI11.
    vector<char> boolAsCharVector;
    app.add_option("--bool-array", boolAsCharVector, "A bool array")
        ->required()
        ->transform(CLI::CheckedTransformer(BoolAsCharMap, CLI::ignore_case));

    // Option for Q# Pauli type.
    char pauliValue = 0;
    app.add_option("--pauli-value", pauliValue, "A Pauli value")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for a Q# Array<Pauli> type.
    std::vector<char> pauliVector;
    app.add_option("--pauli-array", pauliVector, "A Pauli array")
        ->required()
        ->transform(CLI::CheckedTransformer(PauliMap, CLI::ignore_case));

    // Option for Q# Range type.
    // N.B. RangeTuple type is used here instead of QirRange because CLI11 supports tuple parsing which is leveraged and
    //      the tuple is later translated to QirRange.
    RangeTuple rangeTuple(0, 0, 0);
    app.add_option("--range-value", rangeTuple, "A Range value (start, step, end)")->required();

    // Option for a Q# Array<Range> type.
    vector<RangeTuple> rangeTupleVector;
    app.add_option("--range-array", rangeTupleVector, "A Range array")->required();

    // Option for Q# Result type.
    // N.B. This is implemented as a char rather than a boolean to be consistent with the way an array of results has to
    //      be implemented.
    char resultAsCharValue = InteropResultZeroAsChar;
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

    // Option for a Q# Array<String> type.
    vector<string> stringVector;
    app.add_option("--string-array", stringVector, "A String array")->required();


    // With all the options added, parse arguments from the command line.
    CLI11_PARSE(app, argc, argv);

    // Translate values to its final form after parsing.
    // Create an interop array of integer values.
    unique_ptr<InteropArray> integerArray = CreateInteropArray(integerVector);

    // Create an interop array of double values.
    unique_ptr<InteropArray> doubleArray = CreateInteropArray(doubleVector);

    // Create an interop array of bool values.
    unique_ptr<InteropArray> boolArray = CreateInteropArray(boolAsCharVector);

    // Translate a PauliID value to its char representation.
    char pauliAsCharValue = pauliValue;

    // Create an interop array of Pauli values represented as chars.
    unique_ptr<InteropArray> pauliArray = CreateInteropArray(pauliVector);

    // Create an interop range.
    unique_ptr<InteropRange> rangeValue = CreateInteropRange(rangeTuple);
    vector<InteropRange*> rangeVector;
    TranslateVector<RangeTuple, InteropRange*>(rangeTupleVector, rangeVector, TranslateRangeTupleToInteropRangePointer);
    unique_ptr<InteropArray> rangeArray = CreateInteropArray(rangeVector);

    // Create an interop array of Result values.
    unique_ptr<InteropArray> resultArray = CreateInteropArray(resultAsCharVector);

    // Create an interop array of String values.
    vector<const char*> stringBufferVector;
    TranslateVector<string, const char*>(stringVector, stringBufferVector, TranslateStringToCharBuffer);
    unique_ptr<InteropArray> stringArray = CreateInteropArray(stringBufferVector);

    // Run simulation and write the output of the operation to the corresponding stream.
    Quantum__StandaloneSupportedInputs__ExerciseInputs(intValue, integerArray.get(), doubleValue, doubleArray.get(),
                                                       boolAsCharValue, boolArray.get(), pauliAsCharValue,
                                                       pauliArray.get(), rangeValue.get(), resultAsCharValue,
                                                       resultArray.get(), stringValue.c_str());

    FreePointerVector(rangeVector);
    cout.flush();
}
