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

// Ensures exclusive access to _simulators, the vector of simulators
std::shared_mutex _mutex;
std::vector<std::shared_ptr<SparseSimulator>> _simulators;

unsigned createSimulator(logical_qubit_id num_qubits)
{
    if (num_qubits > MAX_QUBITS)
        throw std::runtime_error("Max number of qubits is exceeded!");
    std::lock_guard<std::shared_mutex> lock(_mutex);
    size_t emptySlot = -1;
    for (auto const& s : _simulators)
    {
        if (s == nullptr)
        {
            emptySlot = &s - &_simulators[0];
            break;
        }
    }
    if (emptySlot == -1)
    {
        _simulators.push_back(std::make_shared<SparseSimulator>(num_qubits));
        emptySlot = _simulators.size() - 1;
    }
    else
    {
        _simulators[emptySlot] = std::make_shared<SparseSimulator>(num_qubits);
    }

    return static_cast<unsigned>(emptySlot);
}

// Deletes a simulator in the vector
void destroySimulator(unsigned id)
{
    std::lock_guard<std::shared_mutex> lock(_mutex);

    _simulators[id].reset(); // Set pointer to nullptr
}

// Returns a simulator at some id (used for the C++/C# API)
std::shared_ptr<SparseSimulator>& getSimulator(unsigned id)
{
    std::shared_lock<std::shared_mutex> shared_lock(_mutex);

    return _simulators[id];
}

} // namespace Microsoft::Quantum::SPARSESIMULATOR
