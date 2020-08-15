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
      Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
    namespace SimulatorAVX
    {
      Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
    namespace SimulatorAVX2
    {
      Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
    namespace SimulatorAVX512
    {
      Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned);
    }
  }
}

namespace Microsoft
{
  namespace Quantum
  {
      //@@@DBG+
      int dbgFusedSpan  = -1;
      int dbgFusedLimit = 99;
      int dbgNumThreads = 0;
      int dbgReorder    = 2; // bit0: doReorder bit1: Schedule

    namespace Simulator
    {
      std::shared_mutex _mutex;
      std::vector<std::shared_ptr<SimulatorInterface>> _psis;

      //@@@DBG- SimulatorInterface* createSimulator(unsigned maxlocal)
      //@@@DBG+
            SimulatorInterface* createSimulator(unsigned maxlocal,int force=0,int fusedSpan=-1, int fusedLimit=99, int numThreads=0,int reorder=0)

      {
          //@@@DBG+ vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          dbgFusedSpan = fusedSpan;
          dbgFusedLimit = fusedLimit;
          dbgNumThreads = numThreads;
          dbgReorder = reorder;

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
            case 4:
                printf("@@@DBG: AVX512\n");
                return SimulatorAVX512::createSimulator(maxlocal);
            }
          //@@@DBG+ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        }


       if (haveAVX512())
        {
            return SimulatorAVX512::createSimulator(maxlocal);
        }
        else if (haveFMA() && haveAVX2())
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

     //@@@DBG+: for benchmarks vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
      MICROSOFT_QUANTUM_DECL unsigned createDBG(unsigned maxlocal,int force,int fusedSpan,int fusedLimit,int numThreads,int reorder)
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
              _psis.push_back(std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal,force,fusedSpan,fusedLimit,numThreads,reorder)));
              emptySlot = _psis.size() - 1;
          }
          else
          {
              _psis[emptySlot] = std::shared_ptr<SimulatorInterface>(createSimulator(maxlocal,force,fusedSpan,fusedLimit,numThreads,reorder));
          }

          return static_cast<unsigned>(emptySlot);
      }
      //@@@DBG+: for benchmarks ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

