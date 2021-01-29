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
MICROSOFT_QUANTUM_DECL unsigned create(unsigned = 0u);
MICROSOFT_QUANTUM_DECL void destroy(unsigned);
MICROSOFT_QUANTUM_DECL std::shared_ptr<SimulatorInterface>& get(unsigned);
} // namespace Simulator
} // namespace Quantum
} // namespace Microsoft
