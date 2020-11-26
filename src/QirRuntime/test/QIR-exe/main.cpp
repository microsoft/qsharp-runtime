#include <iostream>

#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include "SimulatorStub.hpp"
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
// Declaration of entrypoint, provided in QIR file
extern "C" double Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(double theta1, double theta2, double theta3, int64_t nSamples); // NOLINT
using namespace std;
using namespace Microsoft::Quantum;
int main(int argc, char* argv[]) noexcept
{
    try
    {
        if (argc != 5)
        {
            // argv[0] should contain the program name
            std::cout << "usage: " << argv[0] << " <number of iterations>\n";
            return 1;
        }

        unique_ptr<ISimulator> qapi = CreateFullstateSimulator();
        SetSimulatorForQIR(qapi.get());

        const double theta1 = atof(argv[1]);
        const double theta2 = atof(argv[2]);
        const double theta3 = atof(argv[3]);
        const int64_t iters = atol(argv[4]);
        
        const double ret = Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(theta1, theta2, theta3, iters);
        std::cout << ret << std::endl;
    }
    catch (const std::exception& e)
    {
        std::cerr << "Failed to run VQE: " << e.what() << std::endl;
        return 2;
    }

    return 0;
}