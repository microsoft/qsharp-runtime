// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <vector>
#include <complex>
#include <unordered_map>
#include <bitset>
#include "quantum_hash_map.hpp"
#include <shared_mutex>
#include <mutex>

namespace Microsoft::Quantum::SPARSESIMULATOR
{

using mutex_type = std::mutex;
using recursive_mutex_type = std::recursive_mutex;
using lock_type = std::lock_guard<mutex_type>;
using recursive_lock_type = std::lock_guard<recursive_mutex_type>;

#ifndef USE_SINGLE_PRECISION
	using RealType = double;
#else
	using RealType = float;
#endif

// Logical qubit id is visible to the clients and is immutable during the lifetime of the qubit.
using logical_qubit_id = unsigned;

using amplitude = std::complex<RealType>;

template <size_t num_qubits>
using qubit_label_type = std::bitset<num_qubits>;

// Wavefunctions are hash maps of some key (std::bitset or a string)
template <typename key>
using abstract_wavefunction = ska::bytell_hash_map<key, amplitude, std::hash<key>>;

// Wavefunctions with strings as keys are "universal" in that they do not depend
// on the total number of qubits
using universal_wavefunction = abstract_wavefunction<std::string>;

} // namespace Microsoft::Quantum::SPARSESIMULATOR
