#pragma once

#include <memory>
#include <vector>

#include "QuantumApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    // Toffoli Simulator
    std::unique_ptr<ISimulator> CreateToffoliSimulator();

    // Full State Simulator
    std::unique_ptr<ISimulator> CreateFullstateSimulator();

} // namespace Quantum
} // namespace Microsoft