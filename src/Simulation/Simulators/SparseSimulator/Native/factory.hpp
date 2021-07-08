// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Manages simulators in a vector of pointers to simulators

#pragma once
#include "types.h"
#include "SparseSimulator.h"

namespace Microsoft::Quantum::SPARSESIMULATOR
{

unsigned createSimulator(logical_qubit_id);
void destroySimulator(unsigned);

std::shared_ptr<SparseSimulator>& getSimulator(unsigned);

} // namespace Microsoft::Quantum::SPARSESIMULATOR
