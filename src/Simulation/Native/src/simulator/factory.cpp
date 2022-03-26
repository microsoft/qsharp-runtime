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
} // namespace Quantum
} // namespace Microsoft

namespace Microsoft
{
namespace Quantum
{
namespace Simulator
{

SimulatorInterface* createSimulator(unsigned maxlocal)
{
    if (haveAVX512())
    {
        return SimulatorAVX512::createSimulator(maxlocal);
    }
    else if (haveFMA() && haveAVX2())
    {
        return SimulatorAVX2::createSimulator(maxlocal);
    }
    else if (haveAVX())
    {
        return SimulatorAVX::createSimulator(maxlocal);
    }
    else
    {
        return SimulatorGeneric::createSimulator(maxlocal);
    }
}

MICROSOFT_QUANTUM_DECL uintptr_t create(unsigned maxlocal)
{
    return (uintptr_t)createSimulator(maxlocal);
}

MICROSOFT_QUANTUM_DECL void destroy(uintptr_t id)
{
    delete (SimulatorInterface*)id;
}

MICROSOFT_QUANTUM_DECL SimulatorInterface* get(uintptr_t id)
{
    return (SimulatorInterface*)id;
}

} // namespace Simulator
} // namespace Quantum
} // namespace Microsoft
