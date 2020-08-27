// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/factory.hpp"
#include <iostream>

using namespace Microsoft::Quantum::Simulator;

int main(int argc, char** argv)
{
  auto sim = get(create());

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
