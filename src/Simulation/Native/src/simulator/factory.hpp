// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "config.hpp"
#include "simulatorinterface.hpp"

namespace Microsoft
{
namespace Quantum
{
namespace Simulator
{
MICROSOFT_QUANTUM_DECL uintptr_t create(unsigned = 0u);
MICROSOFT_QUANTUM_DECL void destroy(uintptr_t);
MICROSOFT_QUANTUM_DECL SimulatorInterface* get(uintptr_t);
} // namespace Simulator
} // namespace Quantum
} // namespace Microsoft
