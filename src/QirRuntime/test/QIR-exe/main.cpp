// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <bitset>
#include <iostream>
#include <memory>
#include <string>
#include <unordered_set>

#include "CoreTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include "SimulatorStub.hpp"
#include "context.hpp"
#include "qirTypes.hpp"
#include "quantum__rt.hpp"

// Can manually add calls to DebugLog in the ll files for debugging.
extern "C" void DebugLog(int64_t value)
{
    std::cout << value << std::endl;
}
extern "C" void DebugLogPtr(char* value)
{
    std::cout << (const void*)value << std::endl;
}

// This VQE sample is taken from https://github.com/msr-quarc/StandaloneVQE
// When executed in Q# it returns -1.0 with single decimal precision (the correct energy value is close to -1.3)
extern "C" double Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(); // NOLINT

using namespace std;
using namespace Microsoft::Quantum;
int main(int argc, char* argv[]) noexcept
{
    try
    {
        unique_ptr<ISimulator> qapi = CreateFullstateSimulator();
        QirContextScope qirctx(qapi.get());

        const long iters = atol(argv[1]);

        const double ret = Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body();
        std::cout << ret << std::endl;
    }
    catch (const std::exception& e)
    {
        std::cerr << "Failed to run VQE: " << e.what() << std::endl;
        return 2;
    }

    return 0;
}