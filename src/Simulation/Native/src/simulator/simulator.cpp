// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/simulator.hpp"

namespace sim = Microsoft::Quantum::SIMULATOR;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* sim::createSimulator(unsigned maxlocal)
{
  return new sim::SimulatorType(maxlocal);
}
