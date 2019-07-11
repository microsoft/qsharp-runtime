// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#define HAVE_INTRINSICS

#include "simulator/simulator.hpp"


namespace sim = Microsoft::Quantum::SimulatorAVX;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* sim::createSimulator(unsigned maxlocal)
{
  return new sim::SimulatorType(maxlocal);
}
