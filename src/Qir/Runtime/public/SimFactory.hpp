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
    extern "C" QIR_SHARED_API IRuntimeDriver* CreateToffoliSimulator();

    // Full State Simulator
    extern "C" QIR_SHARED_API IRuntimeDriver* CreateFullstateSimulator(long userProvidedSeed);

} // namespace Quantum
} // namespace Microsoft
