// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Manages simulators in a vector of pointers to simulators

#include <iostream>
#include <shared_mutex>

#include "factory.hpp"
#include "SparseSimulator.h"
#include "types.h"

namespace Microsoft::Quantum::SPARSESIMULATOR
{

simulator_id_type createSimulator(logical_qubit_id num_qubits)
{
    return (simulator_id_type)(new SparseSimulator(num_qubits));
}

// Deletes a simulator in the vector
void destroySimulator(simulator_id_type id)
{
    delete (SparseSimulator*)id;
}

// Returns a simulator at some id (used for the C++/C# API)
SparseSimulator* getSimulator(simulator_id_type id)
{
    return (SparseSimulator*)id;
}

} // namespace Microsoft::Quantum::SPARSESIMULATOR
