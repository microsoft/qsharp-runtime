#pragma once

#include <memory>
#include <vector>

#include "IQuantumApi.hpp"

namespace quantum
{
    // Toffoli Simulator
    std::unique_ptr<IQuantumApi> CreateToffoliSimulator();

    // Full State Simulator
    std::unique_ptr<IQuantumApi> CreateFullstateSimulator();
} // namespace quantum