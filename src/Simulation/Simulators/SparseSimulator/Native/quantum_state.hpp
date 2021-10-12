// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <string>
#include <unordered_map>
#include <random>
#include <cmath>
#include <functional>
#include <algorithm>
#include <list>
#include <iostream>
#include <memory>

#include "basic_quantum_state.hpp"

#include "types.h"
#include "gates.h"

using namespace std::literals::complex_literals;

namespace Microsoft::Quantum::SPARSESIMULATOR
{

// power of square root of -1
inline amplitude iExp(int power)
{
    int p = ((power % 4) + 8) % 4;
    switch (p)
    {
    case 0:
        return 1;
    case 1:
        return 1i;
    case 2:
        return -1;
    case 3:
        return -1i;
    default:
        return 0;
    }
    return 0;
}

template<size_t num_qubits>
bool get_parity(std::bitset<num_qubits> const& bitstring){
    return bitstring.count() % 2;
}

// Compares two bitsets as through they were bitstrings
// Used to enforce an ordering on bitsets, though currently not referenced

template<size_t N>
inline bool operator<(const std::bitset<N>& lhs, const std::bitset<N>& rhs) {
    std::bitset<N> mask = lhs ^ rhs;
    std::bitset<N> const ull_mask = std::bitset<N>((unsigned long long) -1);
    for (int i = static_cast<int>(N - 8*sizeof(unsigned long long)); i > 0; i-= static_cast<int>(8*sizeof(unsigned long long))){
        if (((mask >> i) & ull_mask).to_ullong() > 0){
            return ((lhs >> i) & ull_mask).to_ullong() < ((rhs >> i) & ull_mask).to_ullong();
        }
    }
    return ((lhs) & ull_mask).to_ullong() < ((rhs) & ull_mask).to_ullong();
}

// Transforms a vector of indices into a bitset where the indices indicate precisely
// which bits are non-zero
template<size_t num_qubits>
std::bitset<num_qubits> get_mask(std::vector<logical_qubit_id> const& indices){
    std::bitset<num_qubits> mask;
    for (logical_qubit_id index : indices) {
        mask.set(index);
    }
    return mask;
}

template<size_t num_qubits>
class QuantumState : public BasicQuantumState
{
public:
    // Type for qubit labels, with a specific size built-in
    using qubit_label = qubit_label_type<num_qubits>;

    // Type of hash maps with the required labels
    using wavefunction = abstract_wavefunction<qubit_label>;

    QuantumState() {
        _qubit_data = wavefunction();
        _qubit_data.max_load_factor(_load_factor);
        // Create an initial all-zeros state
        _qubit_data.emplace((logical_qubit_id)0, 1);
        // Initialize randomness
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<double> dist(0, 1);
        _rng = [gen, dist]() mutable { return dist(gen); };
    }

    // Copy data from an existing simulator
    // This is used to move between different qubit sizes
    // without needing a lot of templated functions
    QuantumState(std::shared_ptr<BasicQuantumState> old_state) {
        // Copy any needed data
        _rng = old_state->get_rng();
        // Outputs the previous data with labels as strings
        universal_wavefunction old_qubit_data = old_state->get_universal_wavefunction();
        _qubit_data = wavefunction(old_qubit_data.size());
        _load_factor = old_state->get_load_factor();
        _qubit_data.max_load_factor(_load_factor);
        // Writes this into the current wavefunction as qubit_label types
        for (auto current_state = old_qubit_data.begin(); current_state != old_qubit_data.end(); ++current_state) {
            _qubit_data.emplace(qubit_label(current_state->first), current_state->second);
        }
    }

    logical_qubit_id get_num_qubits() { 
        return (logical_qubit_id)num_qubits;
    }

    // Outputs all states and amplitudes to the console
    void DumpWavefunction(size_t indent = 0){
        DumpWavefunction(_qubit_data, indent);
    }

    // Outputs all states and amplitudes from an input wavefunction to the console
    void DumpWavefunction(wavefunction &wfn, size_t indent = 0){
        std::string spacing(indent, ' ');
        std::cout << spacing << "Wavefunction:\n";
        auto line_dump = [spacing](qubit_label label, amplitude val){
            std::cout << spacing << "  " << label.to_string() << ": ";
            std::cout << val.real();
            std::cout  << (val.imag() < 0 ? " - " : " + ") <<  std::abs(val.imag()) << "i\n";
        };
        _DumpWavefunction_base(wfn, line_dump);
        std::cout << spacing << "--end wavefunction\n";
    }


    void set_random_seed(std::mt19937::result_type seed) {
         std::mt19937 gen(seed);
        std::uniform_real_distribution<double> dist(0, 1);
        _rng = [gen, dist]() mutable { return dist(gen); };
    }

    // Used to decide when an amplitude is close enough to 0 to discard
    void set_precision(double new_precision) {
         _precision = new_precision;
         _precision_squared = _precision *_precision;
    }

    // Load factor of the underlying hash map
    float get_load_factor() {
     return _load_factor;
    }

    void set_load_factor(float new_load_factor) {
         _load_factor = new_load_factor;
    }

    // Returns the number of states in superposition
    size_t get_wavefunction_size() {
         return _qubit_data.size();
    }



    // Applies the operator id_coeff*I + pauli_coeff * P
    // where P is the Pauli operators defined by axes applied to the qubits in qubits.
    void PauliCombination(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits, amplitude id_coeff, amplitude pauli_coeff) {
        // Bit-vectors indexing where gates of each type are applied
        qubit_label XYs = 0;
        qubit_label YZs = 0;
        logical_qubit_id ycount = 0;
        for (int i=0; i < axes.size(); i++){
            switch (axes[i]){
                case Gates::Basis::PauliY:
                    YZs.set(qubits[i]);
                    XYs.set(qubits[i]);
                    ycount++;
                    break;
                case Gates::Basis::PauliX:
                    XYs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliZ:
                    YZs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliI:
                    break;
                default:
                    throw std::runtime_error("Bad Pauli basis");
            }
        }	
        
        // All identity
        if (XYs.none() && YZs.none()) {
            return;
        }
        
        // This branch handles purely Z Pauli vectors
        // Purely Z has no addition, which would cause
        // problems in the comparison in the next section
        if (XYs.none()) {
            // 0 terms get the sum of the coefficients
            // 1 terms get the difference
            pauli_coeff += id_coeff; // id_coeff + pauli_coeff
            id_coeff *= 2;
            id_coeff -= pauli_coeff; // id_coeff - pauli_coeff

            // To avoid saving states of zero amplitude, these if/else 
            // check for when one of the coefficients is 
            // close enough to zero to regard as zero
            if (std::norm(pauli_coeff) > _rotation_precision_squared ){
                if (std::norm(id_coeff) > _rotation_precision_squared){
                    // If both coefficients are non-zero, we can just modify the state in-place
                    for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                        current_state->second *= (get_parity(current_state->first & YZs) ? id_coeff : pauli_coeff);
                    }
                } else {
                    // If id_coeff = 0, then we make a new wavefunction and only add in those that will be multiplied
                    // by the pauli_coeff
                    wavefunction new_qubit_data = make_wavefunction(_qubit_data.size());
                    for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                        if (!get_parity(current_state->first & YZs)){
                            new_qubit_data.emplace(current_state->first, current_state->second * pauli_coeff);
                        }
                    }
                    _qubit_data = std::move(new_qubit_data);
                }
            } else {
                // If pauli_coeff=0, don't add states multiplied by the pauli_coeff
                wavefunction new_qubit_data = make_wavefunction(_qubit_data.size());
                for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                    if (get_parity(current_state->first & YZs)){
                        new_qubit_data.emplace(current_state->first, current_state->second * id_coeff);
                    }
                }
                _qubit_data = std::move(new_qubit_data);
            }
        } else { // There are some X or Y gates

            // Each Y Pauli adds a global phase of i
            switch (ycount % 4) {
            case 1:
                pauli_coeff *= 1i;
                break;
            case 2:
                pauli_coeff *= -1;
                break;
            case 3:
                pauli_coeff *= -1i;
                break;
            default:
                break;
            }
            // When both the state and flipped state are in superposition, when adding the contribution of
            // the flipped state, we add phase depending on the 1s in the flipped state 
            // This phase would be the parity of (flipped_state->first ^ YZs) 
            // However, we know that flipped_state->first = current_state->first ^ YXs
            // So the parity of the flipped state will be the parity of the current state, plus
            // the parity of YZs & YXs, i.e., the parity of the number of Ys 
            // Since this is constant for all states, we compute it once here and save it
            // Then we only compute the parity of the current state
            amplitude pauli_coeff_alt = ycount % 2 ? -pauli_coeff : pauli_coeff;
            wavefunction new_qubit_data = make_wavefunction(_qubit_data.size() * 2);
            amplitude new_state;
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                auto alt_state = _qubit_data.find(current_state->first ^ XYs);
                if (alt_state == _qubit_data.end()) { // no matching value
                    new_qubit_data.emplace(current_state->first, current_state->second * id_coeff);
                    new_qubit_data.emplace(current_state->first ^ XYs, current_state->second * (get_parity(current_state->first & YZs) ? -pauli_coeff : pauli_coeff));
                }
                else if (current_state->first < alt_state->first) {
                    // Each Y and Z gate adds a phase (since Y=iXZ)
                    bool parity = get_parity(current_state->first & YZs);
                    new_state = current_state->second * id_coeff + alt_state->second * (parity ? -pauli_coeff_alt : pauli_coeff_alt);
                    if (std::norm(new_state) > _rotation_precision_squared) {
                        new_qubit_data.emplace(current_state->first, new_state);
                    }

                    new_state = alt_state->second * id_coeff + current_state->second * (parity ? -pauli_coeff : pauli_coeff);
                    if (std::norm(new_state) > _rotation_precision_squared) {
                        new_qubit_data.emplace(alt_state->first, new_state);
                    }
                }
            }
            _qubit_data = std::move(new_qubit_data);
        }
    }

    // Applies the operator id_coeff*I + pauli_coeff * P
    // where P is the Pauli operators defined by axes applied to the qubits in qubits.
    // Controlled version
    void MCPauliCombination(std::vector<logical_qubit_id> const& controls, std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits, amplitude id_coeff, amplitude pauli_coeff) {
        // Bit-vectors indexing where gates of each type are applied
        qubit_label cmask = _get_mask(controls);
        qubit_label XYs = 0;
        qubit_label YZs = 0;
        logical_qubit_id ycount = 0;
        // Used for comparing pairs 
        logical_qubit_id any_xy = -1;
        for (int i=0; i < axes.size(); i++){
            switch (axes[i]){
                case Gates::Basis::PauliY:
                    YZs.set(qubits[i]);
                    XYs.set(qubits[i]);
                    ycount++;
                    any_xy = qubits[i];
                    break;
                case Gates::Basis::PauliX:
                    XYs.set(qubits[i]);
                    any_xy = qubits[i];
                    break;
                case Gates::Basis::PauliZ:
                    YZs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliI:
                    break;
                default:
                    throw std::runtime_error("Bad Pauli basis");
            }
        }

        // This branch handles purely Z Pauli vectors
        // Purely Z has no addition, which would cause
        // problems in the comparison in the next section
        if (XYs.none()) {
            // 0 terms get the sum of the coefficients
            // 1 terms get the difference
            pauli_coeff += id_coeff; // <- id_coeff + pauli_coeff
            id_coeff *= 2;
            id_coeff -= pauli_coeff; // <- id_coeff - pauli_coeff

            // To avoid saving states of zero amplitude, these if/else 
            // check for when one of the coefficients is 
            // close enough to zero to regard as zero
            if (std::norm(pauli_coeff) > _rotation_precision_squared ){
                if (std::norm(id_coeff) > _rotation_precision_squared){
                    // If both coefficients are non-zero, we can just modify the state in-place
                    for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                        if ((current_state->first & cmask)==cmask) {
                            current_state->second *= (get_parity(current_state->first & YZs) ? id_coeff : pauli_coeff);
                        }
                    }
                } else {
                    // If id_coeff = 0, then we make a new wavefunction and only add in those that will be multiplied
                    // by the pauli_coeff
                    wavefunction new_qubit_data = make_wavefunction(_qubit_data.size());
                    for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                        if (!get_parity(current_state->first & YZs) && (current_state->first & cmask)==cmask){
                            new_qubit_data.emplace(current_state->first, current_state->second * pauli_coeff);
                        }
                    }
                    _qubit_data = std::move(new_qubit_data);
                }
            } else {
                // If pauli_coeff=0, don't add states multiplied by the pauli_coeff
                wavefunction new_qubit_data = make_wavefunction(_qubit_data.size());
                for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                    if (get_parity(current_state->first & YZs) && (current_state->first & cmask)==cmask){
                        new_qubit_data.emplace(current_state->first, current_state->second * id_coeff);
                    }
                }
                _qubit_data = std::move(new_qubit_data);
            }
        } else { // There are some X or Y gates
            // Each Y Pauli adds a global phase of i
            switch (ycount % 4) {
            case 1:
                pauli_coeff *= 1i;
                break;
            case 2:
                pauli_coeff *= -1;
                break;
            case 3:
                pauli_coeff *= -1i;
                break;
            default:
                break;
            }
            // When both the state and flipped state are in superposition, when adding the contribution of
            // the flipped state, we add phase depending on the 1s in the flipped state 
            // This phase would be the parity of (flipped_state->first ^ YZs) 
            // However, we know that flipped_state->first = current_state->first ^ YXs
            // So the parity of the flipped state will be the parity of the current state, plus
            // the parity of YZs & YXs, i.e., the parity of the number of Ys 
            // Since this is constant for all states, we compute it once here and save it
            // Then we only compute the parity of the current state
            amplitude pauli_coeff_alt = ycount % 2 ? -pauli_coeff : pauli_coeff;
            wavefunction new_qubit_data = make_wavefunction(_qubit_data.size() * 2);
            amplitude new_state;
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                if ((current_state->first & cmask)==cmask) {
                    auto alt_state = _qubit_data.find(current_state->first ^ XYs);
                    if (alt_state == _qubit_data.end()) { // no matching value
                        new_qubit_data.emplace(current_state->first, current_state->second * id_coeff);
                        new_qubit_data.emplace(current_state->first ^ XYs, current_state->second * (get_parity(current_state->first & YZs) ? -pauli_coeff : pauli_coeff));
                    }
                    else if (current_state->first < alt_state->first) { //current_state->first[any_xy]){//
                        // Each Y and Z gate adds a phase (since Y=iXZ)
                        bool parity = get_parity(current_state->first & YZs);
                        new_state = current_state->second * id_coeff + alt_state->second * (parity ? -pauli_coeff_alt : pauli_coeff_alt);
                        if (std::norm(new_state) > _rotation_precision_squared) {
                            new_qubit_data.emplace(current_state->first, new_state);
                        }

                        new_state = alt_state->second * id_coeff + current_state->second * (parity ? -pauli_coeff : pauli_coeff);
                        if (std::norm(new_state) > _rotation_precision_squared) {
                            new_qubit_data.emplace(alt_state->first, new_state);
                        }
                    }
                } else {
                    new_qubit_data.emplace(current_state->first, current_state->second);
                }
            }
            _qubit_data = std::move(new_qubit_data);
        }
    }


    bool M(logical_qubit_id target) {
        qubit_label flip = qubit_label();
        flip.set(target);

        bool result = _qubit_data.begin()->first[target];
        
        double zero_probability = 0.0;
        double one_probability = 0.0;

        // Writes data into a ones or zeros wavefunction
        // as it adds up probability
        // Once it's finished, it picks one randomly, normalizes
        // then keeps that one as the new wavefunction
        wavefunction ones = make_wavefunction(_qubit_data.size()/2);
        wavefunction zeros = make_wavefunction(_qubit_data.size()/2);
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            double square_amplitude = std::norm(current_state->second);
            if (current_state->first[target]) {
                one_probability += square_amplitude;
                ones.emplace(current_state->first, current_state->second);
            }
            else {
                zero_probability += square_amplitude;
                zeros.emplace(current_state->first, current_state->second);
            }
        }
        // Randomly select
        result = (_rng() <= one_probability);

        wavefunction &new_qubit_data = result ? ones : zeros;
        // Create a new, normalized state
        double normalizer = 1.0/std::sqrt((result) ? one_probability : zero_probability);
        for (auto current_state = (new_qubit_data).begin(); current_state != (new_qubit_data).end(); ++current_state) {
            current_state->second *= normalizer;
        }
        _qubit_data = std::move(new_qubit_data);

        return result;
    }

    void Reset(logical_qubit_id target) {
        qubit_label flip = qubit_label(0);
        flip.set(target);

        double zero_probability = 0.0;
        double one_probability = 0.0;

        // Writes data into a ones or zeros wavefunction
        // as it adds up probability
        // Once it's finished, it picks one randomly, normalizes
        // then keeps that one as the new wavefunction

        // Used to set the qubit to 0 in the measured result
        qubit_label new_mask = qubit_label();
        new_mask.set(); // sets all bits to 1
        new_mask.set(target, 0);
        wavefunction ones = make_wavefunction(_qubit_data.size()/2);
        wavefunction zeros = make_wavefunction(_qubit_data.size()/2);
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            double square_amplitude = std::norm(current_state->second);
            if (current_state->first[target]) {
                one_probability += square_amplitude;
                ones.emplace(current_state->first & new_mask, current_state->second);
            }
            else {
                zero_probability += square_amplitude;
                zeros.emplace(current_state->first & new_mask, current_state->second);
            }
        }
        // Randomly select
        bool result = (_rng() <= one_probability);

        wavefunction &new_qubit_data = result ? ones : zeros;
        // Create a new, normalized state
        double normalizer = 1.0/std::sqrt((result) ? one_probability : zero_probability);
        for (auto current_state = (new_qubit_data).begin(); current_state != (new_qubit_data).end(); ++current_state) {
            current_state->second *= normalizer;
        }
        _qubit_data = std::move(new_qubit_data);
    }


    // Samples a state from the superposition with probably proportion to
    // the amplitude, returning a string of the bits of that state.
    // Unlike measurement, this does not modify the state
    std::string Sample() {
        double probability = _rng();
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            double square_amplitude = std::norm(current_state->second);
            probability -= square_amplitude;
            if (probability <= 0){
                return current_state->first.to_string();
            }
        }
        return _qubit_data.begin()->first.to_string();
    }

    void Assert(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits, bool result) {
        // Bit-vectors indexing where gates of each type are applied
        qubit_label XYs = 0;
        qubit_label YZs = 0;
        logical_qubit_id ycount = 0;
        for (int i=0; i < axes.size(); i++){
            switch (axes[i]){
                case Gates::Basis::PauliY:
                    YZs.set(qubits[i]);
                    XYs.set(qubits[i]);
                    ycount++;
                    break;
                case Gates::Basis::PauliX:
                    XYs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliZ:
                    YZs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliI:
                    break;
                default:
                    throw std::runtime_error("Bad Pauli basis");
            }
        }
        
        amplitude phaseShift = result ? -1 : 1;
        // Each Y Pauli adds a global phase of i
        switch (ycount % 4) {
        case 1:
            phaseShift *= 1i;
            break;
        case 2:
            phaseShift *= -1;
            break;
        case 3:
            phaseShift *= -1i;
            break;
        default:
            break;
        }
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            // The amplitude of current_state should always be non-zero, if the data structure
            // is properly maintained. Since the flipped state should match the amplitude (up to phase),
            // if the flipped state is not in _qubit_data, it implicitly has an ampltude of 0.0, which
            // is *not* a match, so the assertion should fail. 
            auto flipped_state = _qubit_data.find(current_state->first ^ XYs);
            if (flipped_state == _qubit_data.end() ||
                std::norm(flipped_state->second -  current_state->second * (get_parity(current_state->first & YZs) ? -phaseShift : phaseShift)) > _precision_squared) {
                qubit_label label = current_state->first;
                amplitude val = current_state->second;
                std::cout << "Problematic state: " << label << "\n";
                std::cout << "Expected " << val * (get_parity(label & YZs) ? -phaseShift : phaseShift);
                std::cout << ", got " << (flipped_state == _qubit_data.end() ? 0.0 : flipped_state->second) << "\n";
                std::cout << "Wavefunction size: " << _qubit_data.size() << "\n";
                throw std::runtime_error("Not an eigenstate");
            }
        }
    }

    // Returns the probability of a given measurement in a Pauli basis
    // by decomposing each pair of computational basis states into eigenvectors
    // and adding the coefficients of the respective components
    double MeasurementProbability(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits) {
        // Bit-vectors indexing where gates of each type are applied
        qubit_label XYs = 0;
        qubit_label YZs = 0;
        logical_qubit_id ycount = 0;
        for (int i=0; i < axes.size(); i++){
            switch (axes[i]){
                case Gates::Basis::PauliY:
                    YZs.set(qubits[i]);
                    XYs.set(qubits[i]);
                    ycount++;
                    break;
                case Gates::Basis::PauliX:
                    XYs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliZ:
                    YZs.set(qubits[i]);
                    break;
                case Gates::Basis::PauliI:
                    break;
                default:
                    throw std::runtime_error("Bad Pauli basis");
            }
        }
        amplitude phaseShift = 1;

        // Each Y Pauli adds a global phase of i
        switch (ycount % 4) {
        case 1:
            phaseShift *= amplitude(0, 1);
            break;
        case 2:
            phaseShift *= -1;
            break;
        case 3:
            phaseShift *= amplitude(0, -1);
            break;
        default:
            break;
        }
        // Let P be the pauli operation, |psi> the state
        // projection = <psi|P|psi>

        // _qubit_data represents |psi> as sum_x a_x |x>,
        // where all |x> are orthonormal. Thus, the projection
        // will be the product of a_x and a_P(x), where P|x>=|P(x)>
        // Thus, for each |x>, we compute P(x) and look for that state
        // If there is a match, we add the product of their coefficients
        // to the projection, times a phase dependent on how many Ys and Zs match
        // the 1 bits of x
        amplitude projection = 0.0;
        auto flipped_state = _qubit_data.end();
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            flipped_state = _qubit_data.find(current_state->first ^ XYs); // no match returns _qubit_data.end()
            projection += current_state->second * (flipped_state == _qubit_data.end() ? 0 : std::conj(flipped_state->second)) * (get_parity(current_state->first & YZs) ? -phaseShift : phaseShift);
        }
        // The projector onto the -1 eigenspace (a result of "One") is 0.5 * (I - P)
        // So <psi| 0.5*(I - P)|psi> = 0.5 - 0.5*<psi|P|psi>
        // <psi|P|psi> should always be real so this only takes the real part
        return 0.5 - 0.5 * projection.real();
    }

    bool Measure(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits){
        // Find a probability to get a specific result
        double probability = MeasurementProbability(axes, qubits);
        bool result = _rng() <= probability;
        probability = std::sqrt(probability);
        // This step executes immediately so that we reduce the number of states in superposition
        PauliCombination(axes, qubits, 0.5/probability, (result ? -0.5 : 0.5)/probability);
        return result;
    }


    // Probe the amplitude of a single basis state
    amplitude probe(qubit_label const& label) {
        auto qubit = _qubit_data.find(label);
        // States not in the hash map are assumed to be 0
        if (qubit == _qubit_data.end()) {
            return amplitude(0.0, 0.0);
        }
        else {
            return qubit->second;
        }
    }

    amplitude probe(std::string const& label) {
        qubit_label bit_label = qubit_label(label);
        return probe(bit_label);
    }

    // Dumps the state of a subspace of particular qubits, if they are not entangled
    // This requires it to detect if the subspace is entangled, construct a new 
    // projected wavefunction, then call the `callback` function on each state.
    bool dump_qubits(std::vector<logical_qubit_id> const& qubits, void (*callback)(char*, double, double)) {
        // Create two wavefunctions
        // check if they are tensor products
        wavefunction dump_wfn;
        wavefunction leftover_wfn;
        if (!_split_wavefunction(_get_mask(qubits), dump_wfn, leftover_wfn)){
            return false;
        } else {
            _DumpWavefunction_base(dump_wfn, [qubits, callback](qubit_label label, amplitude val){ 
                std::string label_string(qubits.size(), '0');
                for (size_t i=0; i < qubits.size(); i++){
                    label_string[i] = label[qubits[i]] ? '1' : '0';
                }
                callback(const_cast<char *>(label_string.c_str()), val.real(), val.imag());
            });
            return true;
        }
    }

    // Dumps all the states in superposition via a callback function
    void dump_all(logical_qubit_id max_qubit_id, void (*callback)(char*, double, double)) {
        _DumpWavefunction_base(_qubit_data, [max_qubit_id, callback](qubit_label label, amplitude val){
            callback(const_cast<char *>(label.to_string().substr(num_qubits - 1 - max_qubit_id, max_qubit_id + 1).c_str()), val.real(), val.imag());
        });
    }

    // Execute a queue of phase/permutation gates
    void phase_and_permute(std::list<operation> const &operation_list){
        if (operation_list.size()==0){return;}

        // Condense the list into a memory-efficient vector with qubit labels
        // TODO: Is this still needed after multithreading is removed? Can we work off operation_list?
        std::vector<internal_operation> operation_vector;
        operation_vector.reserve(operation_list.size());

        for (auto op : operation_list){
            switch (op.gate_type) { 
                case OP::X:
                case OP::Y:
                case OP::Z:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target));
                    break;
                case OP::MCX:
                case OP::MCY:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, _get_mask(op.controls)));
                    break;
                case OP::MCZ:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, _get_mask(op.controls).set(op.target)));
                    break;
                case OP::Phase:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, op.phase));
                    break;
                case OP::MCPhase:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, _get_mask(op.controls).set(op.target), op.phase));
                    break;
                case OP::SWAP:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, op.target_2));
                    break;
                case OP::MCSWAP:
                    operation_vector.push_back(internal_operation(op.gate_type, op.target, _get_mask(op.controls), op.target_2));
                    break;
                case OP::Assert:
                    operation_vector.push_back(internal_operation(op.gate_type, _get_mask(op.controls), op.result));
                    break;
                default:
                    throw std::runtime_error("Unsupported operation");
                    break;
            }
        }

        wavefunction new_qubit_data = make_wavefunction();
        
        // Iterates through and applies all operations
        for (auto current_state = _qubit_data.begin(); current_state != _qubit_data.end(); ++current_state){
            qubit_label label = current_state->first;
            amplitude val = current_state->second;
            // Iterate through vector of operations and apply each gate
            for (int i=0; i < operation_vector.size(); i++) { 
                auto &op = operation_vector[i];
                switch (op.gate_type) { 
                    case OP::X:
                        label.flip(op.target);
                        break;
                    case OP::MCX:
                        if ((op.controls & label) == op.controls){
                            label.flip(op.target);
                        }
                        break;
                    case OP::Y:
                        label.flip(op.target);
                        val *= (label[op.target]) ? 1i : -1i;
                        break;
                    case OP::MCY:
                        if ((op.controls & label) == op.controls){
                            label.flip(op.target);
                            val *= (label[op.target]) ? 1i : -1i;
                        }
                        break;
                    case OP::Z:
                        val *= (label[op.target] ? -1 : 1);
                        break;
                    case OP::MCZ:
                        val *= ((op.controls & label) == op.controls) ? -1 : 1;
                        break;
                    case OP::Phase:
                        val *= label[op.target] ? op.phase : 1;
                        break;
                    case OP::MCPhase:
                        val *= ((op.controls & label) == op.controls) ? op.phase : 1;
                        break;
                    case OP::SWAP:
                        if (label[op.target] != label[op.target_2]){
                            label.flip(op.target);
                            label.flip(op.target_2);
                        }
                        break;
                    case OP::MCSWAP:
                        if (((label & op.controls) == op.controls) && (label[op.target] != label[op.target_2])){
                            label.flip(op.target);
                            label.flip(op.target_2);
                        } 
                        break;
                    case OP::Assert:
                        if (get_parity(label & op.controls) != op.result && std::norm(val) > _precision_squared){
                            std::cout << "Problematic state: " << label << "\n";
                            std::cout << "Amplitude: " << val << "\n";
                            std::cout << "Wavefunction size: " << _qubit_data.size() << "\n";
                            throw std::runtime_error("Assert failed");
                        }
                        break;
                    default:
                        throw std::runtime_error("Unsupported operation");
                        break;
                }
            }
            // Insert the new state into the new wavefunction
            new_qubit_data.emplace(label, val);
        }
        _qubit_data = std::move(new_qubit_data);
        operation_vector.clear();
    }

    void R(Gates::Basis b, double phi, logical_qubit_id index){
        // Z rotation can be done in-place
        if (b == Gates::Basis::PauliZ) {
            amplitude exp_0 = amplitude(std::cos(phi / 2.0), -std::sin(phi / 2.0));
            amplitude exp_1 = amplitude(std::cos(phi / 2.0), std::sin(phi / 2.0));
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                current_state->second *= current_state->first[index] ? exp_1 : exp_0;
            }
        }
        else if (b == Gates::Basis::PauliX || b == Gates::Basis::PauliY) {
            amplitude M00 = std::cos(phi / 2.0);
            amplitude M01 = -std::sin(phi / 2.0) * (b == Gates::Basis::PauliY ? 1 : 1i);
            if (std::norm(M00) < _rotation_precision_squared){
                // This is just a Y or X gate
                phase_and_permute(std::list<operation>{operation(b==Gates::Basis::PauliY ? OP::Y : OP::X, index)});
                return;
            } else if (std::norm(M01) < _rotation_precision_squared){
                // just an identity
                return;
            }

            amplitude M10 = M01 * amplitude(b == Gates::Basis::PauliY ? -1 : 1);
            // Holds the amplitude of the new state to make it easier to check if it's non-zero
            amplitude new_state;
            qubit_label flip(0);
            flip.set(index);
            wavefunction new_qubit_data = make_wavefunction();
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                auto flipped_state = _qubit_data.find(current_state->first ^ flip);
                if (flipped_state == _qubit_data.end()) { // no matching value
                    if (current_state->first[index]) {// 1 on that qubit
                        new_qubit_data.emplace(current_state->first ^ flip, current_state->second * M01);
                        new_qubit_data.emplace(current_state->first, current_state->second * M00);
                    }
                    else {
                        new_qubit_data.emplace(current_state->first, current_state->second * M00);
                        new_qubit_data.emplace(current_state->first ^ flip, current_state->second * M10);
                    }
                }
                // Add up the two values, only when reaching the zero value
                else if (!(current_state->first[index])) {
                    new_state = current_state->second * M00 + flipped_state->second * M01; // zero state
                    if (std::norm(new_state) > _rotation_precision_squared	) {
                        new_qubit_data.emplace(current_state->first, new_state);
                    }
                    new_state = current_state->second * M10 + flipped_state->second * M00; // one state
                    if (std::norm(new_state) > _rotation_precision_squared) {
                        new_qubit_data.emplace(flipped_state->first, new_state);
                    }
                }
            }
            _qubit_data = std::move(new_qubit_data);
        }
    }

    // Multi-controlled rotation
    void MCR (std::vector<logical_qubit_id> const& controls, Gates::Basis b, double phi, logical_qubit_id target) {
        qubit_label checks = _get_mask(controls);
        // A Z-rotation can be done without recreating the wavefunction
        if (b == Gates::Basis::PauliZ) {
            amplitude exp_0 = amplitude(std::cos(phi / 2.0), -std::sin(phi / 2.0));
            amplitude exp_1 = amplitude(std::cos(phi / 2.0), std::sin(phi / 2.0));
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                if ((current_state->first & checks)==checks){
                    current_state->second *= current_state->first[target] ? exp_1 : exp_0;
                }
            }
        }
        // X or Y requires a new wavefunction
        else if (b == Gates::Basis::PauliX || b == Gates::Basis::PauliY) {
            amplitude M00 = std::cos(phi / 2.0);
            amplitude M01 = -std::sin(phi / 2.0) * (b == Gates::Basis::PauliY ? 1 : 1i);
            amplitude M10 = (b == Gates::Basis::PauliY ? -1.0 : 1.0) * M01;

            if (std::norm(M00) < _rotation_precision_squared){
                // This is just an MCY or MCX gate, but with a phase
                // So we need to preprocess with a multi-controlled phase
                if (b==Gates::Basis::PauliY){
                    amplitude phase = -1i/M01;
                    phase_and_permute(std::list<operation>{
                        operation(OP::MCPhase, controls[0], controls, phase),
                        operation(OP::MCY, target, controls)
                    });
                } else {
                    amplitude phase = 1.0/M01;
                    phase_and_permute(std::list<operation>{
                        operation(OP::MCPhase, controls[0], controls, phase),
                        operation(OP::MCY, target, controls)
                    });
                }
                return;
            } else if (std::norm(M01) < _rotation_precision_squared){
                // This is equivalent to a multi-controlled Z if the rotation is -1
                if (std::norm(M01 + 1.0) < _rotation_precision_squared){
                    phase_and_permute(std::list<operation>{operation(OP::MCZ, controls[0], controls)});
                }
                return;
            }

            amplitude new_state;
            qubit_label flip(0);
            flip.set(target);
            wavefunction new_qubit_data = make_wavefunction();
            for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
                if ((current_state->first & checks)==checks){
                    auto flipped_state = _qubit_data.find(current_state->first ^ flip);
                    if (flipped_state == _qubit_data.end()) { // no matching value
                        if (current_state->first[target]) {// 1 on that qubit
                            new_qubit_data.emplace(current_state->first ^ flip, current_state->second * M01);
                            new_qubit_data.emplace(current_state->first, current_state->second * M00);
                        }
                        else {
                            new_qubit_data.emplace(current_state->first, current_state->second * M00);
                            new_qubit_data.emplace(current_state->first ^ flip, current_state->second * M10);
                        }
                    }
                    // Add up the two values, only when reaching the zero val
                    else if (!(current_state->first[target])) {
                        new_state = current_state->second * M00 + flipped_state->second * M01; // zero state
                        if (std::norm(new_state) > _rotation_precision_squared) {
                            new_qubit_data.emplace(current_state->first, new_state);
                        }
                        new_state = current_state->second * M10 + flipped_state->second * M00; // one state
                        if (std::norm(new_state) > _rotation_precision_squared) {
                            new_qubit_data.emplace(current_state->first | flip, new_state);
                        }
                    }
                } else {
                    new_qubit_data.emplace(current_state->first, current_state->second);
                }
            }
            _qubit_data = std::move(new_qubit_data);
        }
    }

    void H(logical_qubit_id index){
        // Initialize a new wavefunction, which will store the modified state
        // We initialize with twice as much space as the current one,
        // as this is the worst case result of an H gate
        wavefunction new_qubit_data = make_wavefunction(_qubit_data.size() * 2);
        // This label makes it easier to find associated labels (where the index is flipped)
        qubit_label flip(0);
        flip.set(index);
        // The amplitude for the new state
        amplitude new_state;
        // Loops over all states in the wavefunction _qubit_data
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            // An iterator pointing to the state labelled by the flip
            auto flipped_state = _qubit_data.find(current_state->first ^ flip);
            // Checks for whether it needs to add amplitudes from matching states
            // or create two new states
            if (flipped_state == _qubit_data.end()) { // no matching value
                new_qubit_data.emplace(current_state->first & (~flip), current_state->second * _normalizer);
                // Flip the value if the second bit, depending on whether the original had 1 or 0
                new_qubit_data.emplace(current_state->first | flip, current_state->second * (current_state->first[index] ? -_normalizer : _normalizer));
            }
            else if (!(current_state->first[index])) {
                new_state = current_state->second + flipped_state->second; // zero state
                if (std::norm(new_state) > _rotation_precision_squared) {
                    new_qubit_data.emplace(current_state->first, new_state * _normalizer);
                }

                new_state = current_state->second - flipped_state->second; // one state
                if (std::norm(new_state) > _rotation_precision_squared) {
                    new_qubit_data.emplace(current_state->first | flip, new_state * _normalizer);
                }
            }
        }
        // Moves the new data back into the old one (thus destroying
        // the old data)
        _qubit_data = std::move(new_qubit_data);
    }

    void MCH(std::vector<logical_qubit_id> const& controls, logical_qubit_id index){
        wavefunction new_qubit_data = make_wavefunction(_qubit_data.size() * 2);
        qubit_label flip(0);
        flip.set(index);
        amplitude new_state;
        qubit_label checks = _get_mask(controls);
        for (auto current_state = (_qubit_data).begin(); current_state != (_qubit_data).end(); ++current_state) {
            if ((checks & current_state->first) == checks){
                auto flipped_state = _qubit_data.find(current_state->first ^ flip);
                if (flipped_state == _qubit_data.end()) { // no matching value
                    new_qubit_data.emplace(current_state->first & (~flip), current_state->second * _normalizer);
                    // Flip the value if the second bit, depending on whether the original had 1 or 0
                    new_qubit_data.emplace(current_state->first | flip, current_state->second * (current_state->first[index] ? -_normalizer : _normalizer));
                }
                else if (!(current_state->first[index])) {
                    new_state = current_state->second + flipped_state->second; // zero state
                    if (std::norm(new_state) > _rotation_precision_squared) {
                        new_qubit_data.emplace(current_state->first, new_state * _normalizer);
                    }

                    new_state = current_state->second - flipped_state->second; // one state
                    if (std::norm(new_state) > _rotation_precision_squared) {
                        new_qubit_data.emplace(current_state->first | flip, new_state * _normalizer);
                    }
                }
            } else {
                new_qubit_data.emplace(current_state->first, current_state->second);
            }
        }
        _qubit_data = std::move(new_qubit_data);
    }

    // Checks whether a qubit is 0 in all states in the superposition
    bool is_qubit_zero(logical_qubit_id target){
        for (auto current_state = _qubit_data.begin(); current_state != _qubit_data.end(); ++current_state){
            if (current_state->first[target] && std::norm(current_state->second) > _precision_squared) {
                return false;
            }
        }
        return true;
    }

    // Creates a new wavefunction hash map indexed by strings
    // Not intended for computations but as a way to transfer between
    // simulators templated with different numbers of qubits
    universal_wavefunction get_universal_wavefunction() {
        universal_wavefunction universal_qubit_data = universal_wavefunction(_qubit_data.bucket_count());
        for (auto current_state = _qubit_data.begin(); current_state != _qubit_data.end(); ++current_state) {
            universal_qubit_data.emplace(current_state->first.to_string(), current_state->second);
        }
        return universal_qubit_data;
    }
        
    // Returns the rng from this simulator
    std::function<double()> get_rng() { return _rng; }

private:
    // Internal type used to store operations with bitsets 
    // instead of vectors of qubit ids
    using internal_operation = condensed_operation<num_qubits>;

    // Hash table of the wavefunction
    wavefunction _qubit_data;

    // Internal random numbers
    std::function<double()> _rng;

    // Threshold to assert that something is zero when asserting it is 0
    double _precision = 1e-5;
    // Threshold at which something is zero when
    // deciding whether to add it into the superposition
    double _rotation_precision = 1e-6;
    // Often we compare to norms, so the precision must be squared
    double _precision_squared = _precision * _precision;
    double _rotation_precision_squared = _rotation_precision*_rotation_precision;

    // Normalizer for H and T gates (1/sqrt(2) as an amplitude)
    const amplitude _normalizer = amplitude(1.0, 0.0) / std::sqrt(2.0);

    // The default for bytell_hash_map
    // Used when allocating new wavefunctions
    float _load_factor = 0.9375;

    // Makes a wavefunction that is preallocated to the right size
    // and has the correct load factor
    wavefunction make_wavefunction() {
        wavefunction data((size_t)(_qubit_data.size() / _load_factor));
        data.max_load_factor(_load_factor);
        return data;
    }
    wavefunction make_wavefunction(uint64_t	 n_states) {
        wavefunction data((size_t)(n_states / _load_factor));
        data.max_load_factor(_load_factor);
        return data;
    }

    // Creates a qubit_label as a bit mask from a set of indices
    qubit_label _get_mask(std::vector<logical_qubit_id> const& indices){
        return get_mask<num_qubits>(indices);
    }
   
    // Split the wavefunction if separable, otherwise return false
    // Idea is that if we have a_bb|b1>|b2> as the first state, then for
    // any other state a_xx|x1>|x2>, we must also have a_xb|x1>|b2> and a_bx|b1>|x2>
    // in superposition.
    // Also, the coefficients must separate as a_bb=c_b*d_b and a_xx = c_x*d_x, implying
    // that a_xb = c_x*d_b and a_bx = c_b * d_x, and thus we can check this holds if
    // a_bb*a_xx = a_bx * a_xb. 
    // If this holds: we write (a_xx/a_bx)|x1> into the first wavefunction and (a_xx/a_xb)|x2>
    // into the second. 
    // This means the coefficients of wfn1 are all of the form (c_x/c_b); 
    // Thus, the norm of wfn1 will be 1/|c_b|^2; thus the norm of wfn2 is 1/|d_b|^2 = |c_b|^2/|a_bb|^2
    // So we iterate through the smaller wavefunction, to get the normalizing constant, 
    // then normalize both
    bool _split_wavefunction(qubit_label const& first_mask, wavefunction &wfn1, wavefunction &wfn2){
        qubit_label second_mask = ~first_mask;
        // Guesses size
        wfn1 = wavefunction((int)std::sqrt(_qubit_data.size()));
        wfn2 = wavefunction((int)std::sqrt(_qubit_data.size()));
        // base_label_1 = b1 and base_label_2 = b2 in the notation above
        auto base_state = _qubit_data.begin();
        qubit_label base_label_1 = base_state->first & first_mask;
        qubit_label base_label_2 = base_state->first & second_mask;
        // base_val = a_bb
        amplitude base_val = base_state->second;
        double normalizer_1 = 0.0;
        double normalizer_2 = 0.0;
        // From here on, base_state is |x1>|x2>
        ++base_state;
        for (; base_state != _qubit_data.end(); ++base_state){
            qubit_label label_1 = base_state->first & first_mask;
            qubit_label label_2 = base_state->first & second_mask;
            // first_state is |x1>|b2>, second_state is |b1>|x2>
            auto first_state = _qubit_data.find(label_1 | base_label_2);
            auto second_state = _qubit_data.find(base_label_1 | label_2);
            // Ensures that both |x1>|b2> and |b1>|x2> are in the superposition
            if (first_state == _qubit_data.end() || second_state == _qubit_data.end()){
                // state does not exist
                // therefore states are entangled
                return false;
            } else { // label with base label exists
                // Checks that a_bba_xx = a_xb*a_bx
                if (std::norm(first_state->second * second_state->second - base_val * base_state->second) > _precision_squared*_precision_squared){
                    return false;
                } else {
                    // Not entangled so far, save the two states, with amplitudes a_xx/a_bx and a_xx/a_xb, respectively
                    wfn1[label_1] =  base_state->second / second_state->second;
                    wfn2[label_2] =  base_state->second / first_state->second;
                }
            }
        }
        // Normalize
        // This cannot be done in the previous loop, as that loop will encounter the same data several times
        wavefunction &smaller_wfn = (wfn1.size() < wfn2.size()) ? wfn1 : wfn2;
        wavefunction &larger_wfn  = (wfn1.size() < wfn2.size()) ? wfn2 : wfn1;
        for (auto current_state = smaller_wfn.begin(); current_state != smaller_wfn.end(); ++current_state){
            normalizer_1 += std::norm(current_state->second);
        }
        normalizer_2 = normalizer_1/std::norm(base_val);
        normalizer_1 = 1.0/normalizer_1;
        for (auto current_state = smaller_wfn.begin(); current_state != smaller_wfn.end(); ++current_state){
            current_state->second *= normalizer_1;
        }
        for (auto current_state = larger_wfn.begin(); current_state != larger_wfn.end(); ++current_state){
            current_state->second *= normalizer_2;
        }
        return true;
    }

    // Iterates through a wavefunction and calls the output function on each value
    // It first sorts the labels before outputting
    void _DumpWavefunction_base(wavefunction &wfn, std::function<void(qubit_label,amplitude)> output){
        if (wfn.size() == 0){ return; }
        std::vector<qubit_label> sortedLabels;
        sortedLabels.reserve(wfn.size());
        for (auto current_state = (wfn).begin(); current_state != (wfn).end(); ++current_state) {
            sortedLabels.push_back(current_state->first);
        }
        std::sort(
            sortedLabels.begin(), 
            sortedLabels.end(),
            [](const qubit_label& lhs, const qubit_label& rhs){return lhs < rhs;});
        amplitude val;
        for (qubit_label label : sortedLabels){
            output(label, _qubit_data.find(label)->second);
            
        }
    }

};


} // namespace Microsoft::Quantum::SPARSESIMULATOR
