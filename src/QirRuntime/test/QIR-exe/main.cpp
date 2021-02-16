#include <iostream>

#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"
#include "SimulatorStub.hpp"
#include "qirTypes.hpp"
#include "quantum__rt.hpp"
#include "context.hpp"
#include "CoreTypes.hpp"

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
extern "C" double Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(double theta1, double theta2, double theta3, int nSamples); // NOLINT

using namespace std;
using namespace Microsoft::Quantum;

int main(int argc, char* argv[]) noexcept
{
    try
    {
        if (argc != 6)
        {
            // argv[0] should contain the program name
            std::cout << "usage: " << argv[0] << " <number of iterations> <theta1> <theta2> <theta3> <number of samples>\n";
            return 1;
        }

        // Create a full state simulator and link it to the QIR context scope
        unique_ptr<ISimulator> qapi = CreateFullstateSimulator();
        QirContextScope qirctx(qapi.get());

        const long iters = atol(argv[1]);
        const double theta1 = 0.001;
        const double theta2 = -0.001;
        const double theta3 = 0.001;
        const int nsamples = 1;

        std::cout << "*** Starting VQE example with " << iters << " iterations***\n";
        std::cout << "*** theta1 = " << theta1 << "\n";
        std::cout << "*** theta2 = " << theta2 << "\n";
        std::cout << "*** theta3 = " << theta3 << "\n";
        std::cout << "*** nsamples = " << nsamples << "\n";

        for (long i = 0; i < iters; i++)
        {
            const double ret = Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(theta1, theta2, theta3, nsamples);
            std::cout << ret << std::endl;
        }
    }
    catch (const std::exception& e)
    {
        std::cerr << "Failed to run VQE: " << e.what() << std::endl;
        return 2;
    }

    return 0;
}
