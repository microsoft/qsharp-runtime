// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Manages simulators in a vector of pointers to simulators

#pragma once

#include "types.h"
#include "SparseSimulator.h"

namespace Microsoft::Quantum::SPARSESIMULATOR
{

simulator_id_type createSimulator(logical_qubit_id);
void destroySimulator(simulator_id_type);

std::shared_ptr<SparseSimulator>& getSimulator(simulator_id_type);

} // namespace Microsoft::Quantum::SPARSESIMULATOR
