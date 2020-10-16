#pragma once

#include <memory>
#include <vector>

#include "IQuantumApi.hpp"

namespace Microsoft
{
namespace Quantum
{
    // Toffoli Simulator
    std::unique_ptr<IQuantumApi> CreateToffoliSimulator();

    // Full State Simulator
    std::unique_ptr<IQuantumApi> CreateFullstateSimulator();
} // namespace Quantum
} // namespace Microsoft