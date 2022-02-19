// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <vector>
#include <complex>
#include <unordered_map>
#include <bitset>

namespace Microsoft::Quantum::SPARSESIMULATOR
{

// Runtime may use multiple simulators so a simulator id is used to identify the simulator needed.
using simulator_id_type = std::uint32_t;

// Logical qubit id is visible to the clients and is immutable during the lifetime of the qubit.
using logical_qubit_id = std::uint32_t;

using real_type = double;

using amplitude = std::complex<real_type>;

template <size_t num_qubits>
using qubit_label_type = std::bitset<num_qubits>;

// Wavefunctions are hash maps of some key (std::bitset or a string)
template <typename key>
using abstract_wavefunction = std::unordered_map<key, amplitude>;

// Wavefunctions with strings as keys are "universal" in that they do not depend
// on the total number of qubits
using universal_wavefunction = abstract_wavefunction<std::string>;

} // namespace Microsoft::Quantum::SPARSESIMULATOR
