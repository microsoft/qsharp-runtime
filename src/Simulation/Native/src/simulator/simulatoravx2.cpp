#define HAVE_INTRINSICS
#define HAVE_FMA

#include "simulator/simulator.hpp"


namespace sim = Microsoft::Quantum::SimulatorAVX2;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* sim::createSimulator(unsigned maxlocal)
{
  return new sim::SimulatorType(maxlocal);
}
