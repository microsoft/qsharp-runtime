// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/factory.hpp"
#include "config.hpp"
#include "util/cpuid.hpp"
#include <iostream>
#include <shared_mutex>

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
      std::shared_mutex _mutex;
      std::vector<std::shared_ptr<SimulatorInterface>> _psis;

      SimulatorInterface* createSimulator(unsigned maxlocal)
      {
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
        std::lock_guard<std::shared_mutex> lock(_mutex);

        size_t emptySlot = -1;
        for (auto const& s : _psis) 
        {
            if (s == NULL) 
            {
                emptySlot = &s - &_psis[0];
                break;
            }
        }

        if (emptySlot == -1) 
        {
            _psis.push_back(std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal)));
            emptySlot = _psis.size() - 1;
        }
        else 
        {
            _psis[emptySlot] = std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal));
        }

        return static_cast<unsigned>(emptySlot);
      }

      MICROSOFT_QUANTUM_DECL void destroy(unsigned id)
      {
        std::lock_guard<std::shared_mutex> lock(_mutex);

        _psis[id].reset();
      }

      MICROSOFT_QUANTUM_DECL std::shared_ptr<SimulatorInterface>& get(unsigned id)
      {
        std::shared_lock<std::shared_mutex> shared_lock(_mutex);

        return _psis[id];
      }

    }
  }
}

