// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Manages simulators in a vector of pointers to simulators

#pragma once
#include "types.h"
#include "SparseSimulator.h"

namespace Microsoft
{
namespace Quantum
{
namespace SPARSESIMULATOR
{
unsigned createSimulator(logical_qubit_id);
void destroySimulator(unsigned);

std::shared_ptr<SparseSimulator>& getSimulator(unsigned);
} // namespace Simulator
} // namespace Quantum
} // namespace Microsoft
