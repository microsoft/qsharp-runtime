// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <list>

#include "types.h"
#include "gates.h"

namespace Microsoft::Quantum::SPARSESIMULATOR
{

// Virtual class for QuantumState
// This is not templated, so it allows SparseSimulator types to avoid templates
class BasicQuantumState 
{
public:

    virtual logical_qubit_id get_num_qubits() = 0;

    virtual void DumpWavefunction(size_t indent = 0) = 0;

    virtual void set_random_seed(std::mt19937::result_type seed  = std::mt19937::default_seed) = 0;

    virtual void set_precision(double new_precision) = 0;

    virtual float get_load_factor() = 0;

    virtual void set_load_factor(float new_load_factor) = 0;

    virtual size_t get_wavefunction_size() = 0;

    virtual void PauliCombination(std::vector<Gates::Basis> const&, std::vector<logical_qubit_id> const&, amplitude, amplitude) = 0;
    virtual void MCPauliCombination(std::vector<logical_qubit_id> const&, std::vector<Gates::Basis> const&, std::vector<logical_qubit_id> const&, amplitude, amplitude) = 0;

    virtual bool M(logical_qubit_id) = 0;

    virtual void Reset(logical_qubit_id) = 0;

    

    virtual void Assert(std::vector<Gates::Basis> const&, std::vector<logical_qubit_id> const&, bool) = 0;

    virtual double MeasurementProbability(std::vector<Gates::Basis> const&, std::vector<logical_qubit_id> const&) = 0;
    virtual bool Measure(std::vector<Gates::Basis> const&, std::vector<logical_qubit_id> const&) = 0;


    virtual amplitude probe(std::string const& label) = 0;

    virtual bool dump_qubits(std::vector<logical_qubit_id> const& qubits, void (*callback)(char*, double, double)) = 0;

    virtual void dump_all(logical_qubit_id max_qubit_id, void (*callback)(char*, double, double)) = 0;

    virtual void phase_and_permute(std::list<operation>const &) = 0;

    virtual void R(Gates::Basis b, double phi, logical_qubit_id index) = 0;
    virtual void MCR (std::vector<logical_qubit_id> const&, Gates::Basis, double, logical_qubit_id) = 0;

    virtual void H(logical_qubit_id index) = 0;
    virtual void MCH(std::vector<logical_qubit_id> const& controls, logical_qubit_id index) = 0;

    virtual bool is_qubit_zero(logical_qubit_id)  = 0;

    virtual universal_wavefunction get_universal_wavefunction() = 0;

    virtual std::function<double()> get_rng() = 0;

    virtual std::string Sample()  = 0;
};

} // namespace Microsoft::Quantum::SPARSESIMULATOR
