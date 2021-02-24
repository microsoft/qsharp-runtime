// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "CLI11.hpp"
#include "QirContext.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include <iostream>

using namespace Microsoft::Quantum;

extern "C" void Quantum__StandaloneSupportedInputs__ExerciseInputs__body( // NOLINT
    int64_t anInt,
    double aDouble);

int main(int argc, char* argv[])
{
    try
    {
        CLI::App app("QIR Standalone Entry Point Inputs Reference");

        // Add the --simulator-output and --operation-output options.
        // N.B. These options should be present in all standalone drivers.
        std::string simulatorOutputFile;
        CLI::Option* simulatorOutputFileOpt = app.add_option(
            "-s,--simulator-output", simulatorOutputFile, "File to write the output of the simulator to");

        std::string operationOutputFile;
        CLI::Option* operationOutputFileOpt = app.add_option(
            "-o,--operation-output", operationOutputFile, "File to write the output of the Q# operation to");

        // Add the options that correspond to the parameters that the QIR entry-point needs.
        // Option for a Q# Int type.
        int64_t anInt = 0;
        CLI::Option* anIntOpt = app.add_option("--anint", anInt, "An integer");

        anIntOpt->required();

        // Option for a Q# Double type.
        double_t aDouble = 0.0;
        CLI::Option* aDoubleOpt = app.add_option("--adouble", aDouble, "A double");

        aDoubleOpt->required();

        // Option for a Q# Bool type.
        bool aBool = false;
        CLI::Option* aBoolOpt = app.add_option("--abool", aBool, "A bool");

        aBoolOpt->required();

        // TODO: Add option for Q# Pauli type.
        // TODO: Add option for Q# Result type.
        // TODO: Add option for Q# String type.

        // Option for a Q# Array<Int> type.
        std::vector<int64_t> anIntegerArray;
        CLI::Option* anIntegerArrayOpt = app.add_option("--anintegerarray", anIntegerArray, "An integer array");

        anIntegerArrayOpt->required();

        // TODO: Add option for Q# Tuple<T> type.

        // With all the options added, parse arguments from the command line.
        CLI11_PARSE(app, argc, argv);

        // Redirect the simulator output from std::cout if the --simulator-output option is present.
        std::ostream* simulatorOutputStream = &std::cout;
        std::filebuf simulatorOutputFileBuffer;
        if (!simulatorOutputFileOpt->empty())
        {
            simulatorOutputFileBuffer.open(simulatorOutputFile, std::ios::out);
            std::ostream simulatorOutputFileStream(&simulatorOutputFileBuffer);
            // TODO: Call into the QIR runtime API to redirect the output of the simulator.
            simulatorOutputStream = &simulatorOutputFileStream;
        }

        // Redirect the Q# opertion output from std::cout if the --operation-output option is present.
        std::ostream* operationOutputStream = &std::cout;
        std::filebuf operationOutputFileBuffer;
        if (!operationOutputFileOpt->empty())
        {
            operationOutputFileBuffer.open(operationOutputFile, std::ios::out);
            std::ostream operationOutputFileStream(&operationOutputFileBuffer);
            operationOutputStream = &operationOutputFileStream;
        }

        // TODO: Remove this after the Message Q# function is integrated into the QIR runtime.
        (*operationOutputStream) << "SIMULATOR OUTPUT\n----------------" << std::endl;

        // Start simulation.
        std::unique_ptr<ISimulator> sim = CreateFullstateSimulator();
        QirContextScope qirctx(sim.get(), false /*trackAllocatedObjects*/);
        Quantum__StandaloneSupportedInputs__ExerciseInputs__body(anInt, aDouble);
        simulatorOutputStream->flush();

        // This is for visualization purposes only and should not be part of the generated C++ code.
        // N.B. For examples on how other return values are shown, look at other samples.
        (*operationOutputStream) << "\nOPERATION OUTPUT\n----------------" << std::endl;
        operationOutputStream->flush();

        // Close opened file buffers;
        if (!simulatorOutputFileOpt->empty())
        {
            simulatorOutputFileBuffer.close();
        }

        if (!operationOutputFileOpt->empty())
        {
            operationOutputFileBuffer.close();
        }
    }
    catch (...)
    {
        std::cout << "An unexpected failure occurred." << std::endl;
        return 1;
    }
}
