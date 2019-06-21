// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#include "simulator/factory.hpp"
#include <iostream>

using namespace Microsoft::Quantum::Simulator;

int main(int argc, char** argv)
{
  auto& sim = psis[create()];

  unsigned q=0; // qubit number
  sim->allocateQubit(q);

    // produce random bits using H gates
    for (int i = 0; i < 100; i++)
    {
        sim->H(q);
        int result = sim->M(q);

            std::cout << result << std::endl;
    }

    sim->release(q);

    return 0;
}
