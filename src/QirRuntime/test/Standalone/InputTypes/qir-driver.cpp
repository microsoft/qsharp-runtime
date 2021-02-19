// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <iostream>
#include "../Shared/CLI11.hpp"

// Can manually add calls to DebugLog in the ll files for debugging.
extern "C" void DebugLog(int64_t value)
{
    std::cout << value << std::endl;
}
extern "C" void DebugLogPtr(char* value)
{
    std::cout << (const void*)value << std::endl;
}

extern "C" void SetupQirToRunOnFullStateSimulator();
extern "C" void Microsoft__Quantum__Testing__QIR__InputTypes__body( // NOLINT
    int64_t anInt,
    double_t aDouble,
    int64_t anArrayLength,
    int64_t* anArray);

int main(int argc, char *argv[])
{
    try{
        CLI::App app("Input Types");

        // Add the --simulator-output and --operation-output options.
        // N.B. These options should be present in all standalone drivers.
        std::string simulatorOutputFile;
        CLI::Option *simulatorOutputFileOpt = app.add_option(
            "-s,--simulator-output",
            simulatorOutputFile,
            "File to write the output of the simulator to");

        std::string operationOutputFile;
        CLI::Option *operationOutputFileOpt = app.add_option(
            "-o,--operation-output",
            operationOutputFile,
            "File to write the output of the Q# operation to");

        // Add the options that correspond to the parameters that the QIR entry-point needs.
        // Option for a Q# Int type.
        int64_t anInt = 0;
        CLI::Option *anIntOpt = app.add_option(
            "--anint",
            anInt,
            "An integer");

        anIntOpt->required();

        // Option for a Q# Double type.
        double_t aDouble = 0.0;
        CLI::Option *aDoubleOpt = app.add_option(
            "--adouble",
            aDouble,
            "A double");

        aDoubleOpt->required();

        // Option for a Q# Bool type.
        bool aBool = false;
        CLI::Option *aBoolOpt = app.add_option(
            "--abool",
            aBool,
            "A bool");

        aBoolOpt->required();

        // TODO: Add option for Q# Pauli type.
        // TODO: Add option for Q# Result type.
        // TODO: Add option for Q# String type.

        // Option for a Q# Array<Int> type.
        std::vector<int64_t> anIntegerArray;
        CLI::Option *anIntegerArrayOpt = app.add_option(
            "--anintegerarray",
            anIntegerArray,
            "An integer array");

        anIntegerArrayOpt->required();

        // TODO: Add option for Q# Tuple<T> type.

        // With all the options added, parse arguments from the command line.
        CLI11_PARSE(app, argc, argv);

        // Redirect the simulator output from std::cout if the --simulator-output option is present.
        std::ostream* simulatorOutputStream = &std::cout;
        std::filebuf simulatorOutputFileBuffer;
        if (!simulatorOutputFileOpt->empty()){
            std::cout << "Simulator Output File: " << simulatorOutputFile << std::endl;
            simulatorOutputFileBuffer.open(simulatorOutputFile, std::ios::out);
            std::ostream simulatorOutputFileStream(&simulatorOutputFileBuffer);
            // TODO: Call into the QIR runtime API to redirect the output of the simulator.
            simulatorOutputStream = &simulatorOutputFileStream;
        }

        // TODO: This is for testing purposes only.
        (*simulatorOutputStream) << "SIMULATOR OUTPUT:\nSample Output\n";

        // Redirect the Q# opertion output from std::cout if the --operation-output option is present.
        std::ostream* operationOutputStream = &std::cout;
        std::filebuf operationOutputFileBuffer;
        if (!operationOutputFileOpt->empty()){
            std::cout << "Operation Output File: " << operationOutputFile << std::endl;
            operationOutputFileBuffer.open(operationOutputFile, std::ios::out);
            std::ostream operationOutputFileStream(&operationOutputFileBuffer);
            operationOutputStream = &operationOutputFileStream;
        }

        // TODO: Remove this after the Message Q# function is integrated into the QIR runtime.
        (*simulatorOutputStream) << anInt << std::endl;
        (*simulatorOutputStream) << aDouble << std::endl;
        (*simulatorOutputStream) << aBool << std::endl;
        for (int64_t n : anIntegerArray) {
            (*simulatorOutputStream) << n << " ";
        }

        (*simulatorOutputStream) << std::endl;

        // Start simulation.
        // TODO: Use the pattern suggested by Irina.
        SetupQirToRunOnFullStateSimulator();
        // TODO: Pass the parsed arguments to the entry-point operation.
        Microsoft__Quantum__Testing__QIR__InputTypes__body(anInt, aDouble, 0, nullptr);
        simulatorOutputStream->flush();
        (*operationOutputStream) << "OPERATION OUTPUT:\n";
        operationOutputStream->flush();

        // Close opened file buffers;
        if (!simulatorOutputFileOpt->empty()){
            simulatorOutputFileBuffer.close();
        }

        if (!operationOutputFileOpt->empty()){
            operationOutputFileBuffer.close();
        }
    } catch(...) {
        return 1;
    }

    return 0;
}
