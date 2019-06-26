#define HAVE_INTRINSICS

#include "simulator/simulator.hpp"


namespace sim = Microsoft::Quantum::SimulatorAVX;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* sim::createSimulator(unsigned maxlocal)
{
  return new sim::SimulatorType(maxlocal);
}
