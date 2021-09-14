// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <memory>
#include <vector>
#include <cstdint>

#include "QirRuntimeApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    // Toffoli Simulator
    QIR_SHARED_API std::unique_ptr<IRuntimeDriver> CreateToffoliSimulator();

    // Full State Simulator
    QIR_SHARED_API std::unique_ptr<IRuntimeDriver> CreateFullstateSimulator();

    // Full State Simulator (C-API)
    extern "C" QIR_SHARED_API IRuntimeDriver* CreateFullstateSimulator(long userProvidedSeed);

} // namespace Quantum
} // namespace Microsoft
