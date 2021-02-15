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
extern "C" bool Microsoft__Quantum__Testing__QIR__RandomBit__body(); // NOLINT

int main(int argc, char *argv[])
{
    try{
        CLI::App app("Random Bit");

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

        // Start simulation.
        SetupQirToRunOnFullStateSimulator();
        bool bit = Microsoft__Quantum__Testing__QIR__RandomBit__body();
        simulatorOutputStream->flush();
        (*operationOutputStream) << "OPERATION OUTPUT:\n";
        (*operationOutputStream) << (bit ? "true" : "false");
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
