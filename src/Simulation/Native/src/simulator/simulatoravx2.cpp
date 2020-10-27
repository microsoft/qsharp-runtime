// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#define HAVE_INTRINSICS
#define HAVE_FMA

#include "simulator/simulator.hpp"

namespace sim = Microsoft::Quantum::SimulatorAVX2;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* sim::createSimulator(unsigned maxlocal)
{
    return new sim::SimulatorType(maxlocal);
}
