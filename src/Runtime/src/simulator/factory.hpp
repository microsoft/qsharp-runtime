// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#include "config.hpp"
#include "simulatorinterface.hpp"

namespace Microsoft
{
  namespace Quantum
  {
    namespace Simulator
    {
      MICROSOFT_QUANTUM_DECL unsigned create(unsigned =0u);
      MICROSOFT_QUANTUM_DECL void destroy(unsigned);
      
      extern MICROSOFT_QUANTUM_DECL std::vector<std::shared_ptr<SimulatorInterface>> psis;
    }
  }
}
