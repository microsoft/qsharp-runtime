// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/factory.hpp"
#include "config.hpp"
#include "util/cpuid.hpp"
#include <iostream>

namespace Microsoft
{
  namespace Quantum
  {
    namespace SimulatorGeneric
    {
      MICROSOFT_QUANTUM_DECL_IMPORT Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
    namespace SimulatorAVX
    {
      MICROSOFT_QUANTUM_DECL_IMPORT Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
    namespace SimulatorAVX2
    {
      MICROSOFT_QUANTUM_DECL_IMPORT Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
  }
}

namespace Microsoft
{
  namespace Quantum
  {
    namespace Simulator
    {
      mutex_type _mutex;

      SimulatorInterface* createSimulator(unsigned maxlocal)
      {
        if (haveFMA() && haveAVX2())
        {
            printf("@@@DBG: Using AVX2 kernel\n");
            return SimulatorAVX2::createSimulator(maxlocal);
        }
        else if(haveAVX())
        {
            printf("@@@DBG: Using AVX kernel\n");
            return SimulatorAVX::createSimulator(maxlocal);
        }
        else
        {
            printf("@@@DBG: Using Generic kernel\n");
            return SimulatorGeneric::createSimulator(maxlocal);
        }

      }

      MICROSOFT_QUANTUM_DECL unsigned create(unsigned maxlocal)
      {
        std::lock_guard<mutex_type> lock(_mutex);

        size_t emptySlot = -1;
        for (auto const& s : psis) 
        {
            if (s == NULL) 
            {
                emptySlot = &s - &psis[0];
                break;
            }
        }

        if (emptySlot == -1) 
        {
            psis.push_back(std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal)));
            emptySlot = psis.size() - 1;
        }
        else 
        {
            psis[emptySlot] = std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal));
        }

        return static_cast<unsigned>(emptySlot);
      }

      MICROSOFT_QUANTUM_DECL void destroy(unsigned id)
      {
        std::lock_guard<mutex_type> lock(_mutex);

        psis[id].reset();
      }

      MICROSOFT_QUANTUM_DECL std::vector<std::shared_ptr<SimulatorInterface>> psis;

    }
  }
}

