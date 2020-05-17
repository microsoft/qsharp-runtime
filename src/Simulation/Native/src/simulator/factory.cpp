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

      //@@@DBG: added force and fusedSpan
      SimulatorInterface* createSimulator(unsigned maxlocal,int force=0,int fusedSpan=4)
      {
        if (force > 0) {
            switch (force) {
            case 1:
                printf("@@@DBG: Generic\n");
                return SimulatorGeneric::createSimulator(maxlocal);
            case 2: 
                printf("@@@DBG: AVX\n");
                return SimulatorAVX::createSimulator(maxlocal);
            case 3: 
                printf("@@@DBG: AVX2\n");
                return SimulatorAVX2::createSimulator(maxlocal);

            }
        }

        if (haveFMA() && haveAVX2())
        {
            return SimulatorAVX2::createSimulator(maxlocal);
        }
        else if(haveAVX())
        {
            return SimulatorAVX::createSimulator(maxlocal);
        }
        else
        {
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

      //@@@DBG: for benchmarks
      MICROSOFT_QUANTUM_DECL unsigned createDBG(unsigned maxlocal,int force,int fusedSpan)
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
              psis.push_back(std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal,force,fusedSpan)));
              emptySlot = psis.size() - 1;
          }
          else
          {
              psis[emptySlot] = std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal,force,fusedSpan));
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

