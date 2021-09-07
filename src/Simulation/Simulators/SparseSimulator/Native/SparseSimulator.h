// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <string>
#include <random>
#include <cmath>
#include <functional>
#include <algorithm>
#include <iomanip>
#include <iostream>
#include <list>
#include <set>

#include "quantum_state.hpp"
#include "basic_quantum_state.hpp"
#include "types.h"
#include "gates.h"

using namespace std::literals::complex_literals;

namespace Microsoft::Quantum::SPARSESIMULATOR
{

constexpr logical_qubit_id MAX_QUBITS = 1024;
constexpr logical_qubit_id MIN_QUBITS = 64;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// Recrusively compiles sizes of QuantumState types between MIN_QUBITS and MAX_QUBITS
// qubits large, growing by powers of 2
template<size_t max_num_bits>
std::shared_ptr<BasicQuantumState> construct_wfn_helper(logical_qubit_id nqubits) {
	return (nqubits > max_num_bits / 2) ?
		std::shared_ptr<BasicQuantumState>(new QuantumState<max_num_bits>())
		: (nqubits > MIN_QUBITS ? construct_wfn_helper<max_num_bits / 2>(nqubits) :
			std::shared_ptr<BasicQuantumState>(new QuantumState<MIN_QUBITS>()));
}

// Constructs a new quantum state, templated to use enough qubits to hold `nqubits`,
// with the same state as `old_sim`
template<size_t max_num_bits>
std::shared_ptr<BasicQuantumState> expand_wfn_helper(std::shared_ptr<BasicQuantumState> old_sim, logical_qubit_id nqubits) {
	return (nqubits > max_num_bits / 2) ? std::shared_ptr<BasicQuantumState>(new QuantumState<max_num_bits>(old_sim)): expand_wfn_helper<max_num_bits / 2>(old_sim, nqubits);
}

class SparseSimulator
{
public:

	std::set<std::string> operations_done;

	SparseSimulator(logical_qubit_id num_qubits)  {
		// Constructs a quantum state templated to the right number of qubits
		// and returns a pointer to it as a basic_quantum_state
		_quantum_state = construct_wfn_helper<MAX_QUBITS>(num_qubits);
		// Return the number of qubits this actually produces
		num_qubits = _quantum_state->get_num_qubits();
		// Initialize with no qubits occupied
		_occupied_qubits = std::vector<bool>(num_qubits, 0);
		_max_num_qubits_used = 0;
		_current_number_qubits_used = 0;

		_queue_Ry = std::vector<bool>(num_qubits, 0);
		_queue_Rx = std::vector<bool>(num_qubits, 0);
		_queue_H  = std::vector<bool>(num_qubits, 0);
		_angles_Rx = std::vector<double>(num_qubits, 0.0);
		_angles_Ry = std::vector<double>(num_qubits, 0.0);

	}


	~SparseSimulator() {
		_execute_queued_ops();
	}

	// Outputs the wavefunction to the console, after
	// executing any queued operations
	void DumpWavefunction(size_t indent = 0){
		_execute_queued_ops();
		_quantum_state->DumpWavefunction(indent);
	}

	// Outputs the wavefunction as it is currently,
	// without executing any operations
	void DumpWavefunctionQuietly(size_t indent = 0){
		_quantum_state->DumpWavefunction(indent);
	}

	void set_random_seed(unsigned seed = std::mt19937::default_seed){
		_quantum_state->set_random_seed(seed);
	}

	// Returns the number of qubits currently available
	// to the simulator, including those already used
	logical_qubit_id get_num_qubits() {
		return _quantum_state->get_num_qubits();
	}

	// Allocates a qubit at a specific location
	// Implies that the caller of this function is tracking
	// free qubits
	void allocate_specific_qubit(logical_qubit_id qubit) {
		size_t num_qubits = _quantum_state->get_num_qubits();
		// Checks that there are enough qubits
		if (qubit >= num_qubits){
			// We create a new wavefunction and reallocate
			std::shared_ptr<BasicQuantumState> old_state = _quantum_state;
			_quantum_state = expand_wfn_helper<MAX_QUBITS>(old_state, qubit+1);

			num_qubits = _quantum_state->get_num_qubits();
			_occupied_qubits.resize(num_qubits, 0);
			_queue_Ry.resize(num_qubits, 0);
			_queue_Rx.resize(num_qubits, 0);
			_queue_H.resize(num_qubits, 0);
			_angles_Rx.resize(num_qubits, 0.0);
			_angles_Ry.resize(num_qubits, 0.0);
		}
		// The external qubit manager should prevent this, but this checks anyway
		if (_occupied_qubits[qubit]) {
			throw std::runtime_error("Qubit " + std::to_string(qubit) +  " is already occupied");
		}
		// There is actually nothing to do to "allocate" a qubit, as every qubit
		// is already available for use with this data structure
	}

	

	// Removes a qubit in the zero state from the list
	// of occupied qubits
	bool release(logical_qubit_id qubit_id) {
		// Quick check if it's zero
		if (_occupied_qubits[qubit_id]) {
			// If not zero here, we must execute any remaining operations
			// Then check if the result is all zero
			_execute_queued_ops(qubit_id);
			
			if (!_quantum_state->is_qubit_zero(qubit_id)){
				throw std::runtime_error("Released qubit not in zero state");
			}

		}
		_set_qubit_to_zero(qubit_id);
		return true;	
	}


	void X(logical_qubit_id index) {
		// XY = - YX
		if (_queue_Ry[index]){
			_angles_Ry[index] *= -1.0;
		}
		// Rx trivially commutes
		if (_queue_H[index]) {
			_queued_operations.push_back(operation(OP::Z, index));
			return;
		}
		_queued_operations.push_back(operation(OP::X, index));
		_set_qubit_to_nonzero(index);
	}


	// For both CNOT and all types of C*NOT
	// If a control index is repeated, it just treats it as one control
	//     (Q# will throw an error in that condition)
	void MCX(std::vector<logical_qubit_id> const& controls, logical_qubit_id  target) {
		// Check for anything on the controls
		if (controls.size() > 1){
			_execute_if(controls);
		} else {
			// An H on the control but not the target forces execution
			if (_queue_Ry[controls[0]] || _queue_Rx[controls[0]] || (_queue_H[controls[0]] && !_queue_H[target])){
				_execute_queued_ops(controls, OP::Ry);
			}
		}
		// Ry on the target causes issues
		if (_queue_Ry[target]){
			_execute_queued_ops(target, OP::Ry);
		}
		// Rx on the target trivially commutes

		// An H on the target flips the operation
		if (_queue_H[target]){
			// If it is a CNOT and there is also an H on the control, we swap control and target
			if (controls.size() == 1 && _queue_H[controls[0]]){
				_queued_operations.push_back(operation(OP::MCX, controls[0], std::vector<logical_qubit_id>{target}));
				_set_qubit_to_nonzero(controls[0]);
			} else {
				_queued_operations.push_back(operation(OP::MCZ, target, controls));
			}
			return;
		}
		// Queue the operation at this point
		_queued_operations.push_back(operation(OP::MCX, target, controls));
		_set_qubit_to_nonzero(target);
	}

	// Same as MCX, but we assert that the target is 0 before execution
	void MCApplyAnd(std::vector<logical_qubit_id> const& controls, logical_qubit_id  target) {
		Assert(std::vector<Gates::Basis>{Gates::Basis::PauliZ}, std::vector<logical_qubit_id>{target}, 0);
		MCX(controls, target);
	}
	// Same as MCX, but we assert that the target is 0 after execution
	void MCApplyAndAdj(std::vector<logical_qubit_id> const& controls, logical_qubit_id  target) {
		MCX(controls, target);
		Assert(std::vector<Gates::Basis>{Gates::Basis::PauliZ}, std::vector<logical_qubit_id>{target}, 0);
		_set_qubit_to_zero(target);
	}

	void Y(logical_qubit_id index) {
		// XY = -YX
		if (_queue_Rx[index]){
			_angles_Rx[index] *= -1.0;
		}
		// commutes with H up to phase, so we ignore the H queue
		_queued_operations.push_back(operation(OP::Y, index));	
		_set_qubit_to_nonzero(index);
	}

	void MCY(std::vector<logical_qubit_id> const& controls, logical_qubit_id target) {
		_execute_if(controls);
		// Commutes with Ry on the target, not Rx
		if (_queue_Rx[target]){
			_execute_queued_ops(target, OP::Rx);
		}
		// YH = -YH, so we add a phase to track this
		if (_queue_H[target]){
			// The phase added does not depend on the target
			// Thus we use one of the controls as a target
			_queued_operations.push_back(operation(OP::MCZ, controls[0], controls));
		}
		_queued_operations.push_back(operation(OP::MCY, target, controls));
		_set_qubit_to_nonzero(target);
	}

	
	void Z(logical_qubit_id index) {
		// ZY = -YZ
		if (_queue_Ry[index]){
			_angles_Ry[index] *= -1;
		}
		// XZ = -ZX
		if (_queue_Rx[index]){
			_angles_Rx[index] *= -1;
		}
		// HZ = XH
		if (_queue_H[index]) {
			_queued_operations.push_back(operation(OP::X, index));
			_set_qubit_to_nonzero(index);
			return;
		}
		// No need to modified _occupied_qubits, since if a qubit is 0
		// a Z will not change that
		_queued_operations.push_back(operation( OP::Z, index ));
	}

	void MCZ(std::vector<logical_qubit_id> const& controls, logical_qubit_id target) {
		// If the only thing on the controls is one H, we can switch
		// this to an MCX. Any Rx or Ry, or more than 1 H, means we 
		// must execute. 
		size_t count = 0;
		for (auto control : controls) {
			if (_queue_Ry[control] || _queue_Rx[control]){
				count += 2;
			}
			if (_queue_H[control]){
				count++;
			}
		}
		if (_queue_Ry[target] || _queue_Rx[target]){
			count +=2;
		}
		if (_queue_H[target]) {count++;}
		if (count > 1) {
			_execute_queued_ops(controls, OP::Ry);
			_execute_queued_ops(target, OP::Ry);
		} else if (count == 1){
			// Transform to an MCX, but we need to swap one of the controls
			// with the target
			std::vector<logical_qubit_id> new_controls(controls);
			for (logical_qubit_id control : controls){
				if (_queue_H[control]){
					std::swap(new_controls[control], target);
				}
			}
			_queued_operations.push_back(operation(OP::MCX, target, new_controls));
			_set_qubit_to_nonzero(target);
			return;
		}
		_queued_operations.push_back(operation(OP::MCZ, target, controls));
	}


	// Any phase gate
	void Phase(amplitude const& phase, logical_qubit_id index) {
		// Rx, Ry, and H do not commute well with arbitrary phase gates
		if (_queue_Ry[index] || _queue_Ry[index] || _queue_H[index]){
			_execute_queued_ops(index, OP::Ry);
		}
		_queued_operations.push_back(operation(OP::Phase, index, phase));
	}

	void MCPhase(std::vector<logical_qubit_id> const& controls, amplitude const& phase, logical_qubit_id target){
		_execute_if(controls);
		_execute_if(target);
		_queued_operations.push_back(operation(OP::MCPhase, target, controls, phase));
	}

	void T(logical_qubit_id index) {
		Phase(amplitude(_normalizer_double, _normalizer_double), index);
	}

	void AdjT(logical_qubit_id index) {
		Phase(amplitude(_normalizer_double, -_normalizer_double), index);
	}
	

	void R1(double const& angle, logical_qubit_id index) {
		Phase(amplitude(std::cos(angle), std::sin(angle)), index);
	}

	void MCR1(std::vector<logical_qubit_id> const& controls, double const& angle, logical_qubit_id target){
		MCPhase(controls, amplitude(std::cos(angle), std::sin(angle)), target);
	}

	void R1Frac(std::int64_t numerator, std::int64_t power, logical_qubit_id index) {
		R1((double)numerator * pow(0.5, power)*M_PI, index);
	}

	void MCR1Frac(std::vector<logical_qubit_id> const& controls, std::int64_t numerator, std::int64_t power, logical_qubit_id target){
		MCR1(controls, (double)numerator * pow(0.5, power) * M_PI, target);
	}

	void S(logical_qubit_id index) {
		Phase(1i, index);
	}

	void AdjS(logical_qubit_id index) {	
		Phase(-1i, index);
	}



	void R(Gates::Basis b, double phi, logical_qubit_id index)
	{
		if (b == Gates::Basis::PauliI){
			return;
		}

		// Tries to absorb the rotation into the existing queue,
		// if it hits a different kind of rotation, the queue executes
		if (b == Gates::Basis::PauliY){
			_queue_Ry[index] = true;
			_angles_Ry[index] += phi;
			_set_qubit_to_nonzero(index);
			return;
		} else if (_queue_Ry[index]) {
			_execute_queued_ops(index, OP::Ry);
		}

		if (b == Gates::Basis::PauliX){
			_queue_Rx[index] = true;
			_angles_Rx[index] += phi;
			_set_qubit_to_nonzero(index);
			return;
		} else if (_queue_Rx[index]){
			_execute_queued_ops(index, OP::Rz);
		}

		// An Rz is just a phase
		if (b == Gates::Basis::PauliZ){
			// HRz = RxH, but that's the wrong order for this structure
			// Thus we must execute the H queue
			if (_queue_H[index]){
				_execute_queued_ops(index, OP::H);
			}
			// Rz(phi) = RI(phi)*R1(-2*phi)
			// Global phase from RI is ignored
			R1(phi, index);
		}
	}

	void MCR (std::vector<logical_qubit_id> const& controls, Gates::Basis b, double phi, logical_qubit_id target) {
		if (b == Gates::Basis::PauliI){
			// Controlled I rotations are equivalent to controlled phase gates
			if (controls.size() > 1){
				MCPhase(controls, amplitude(std::cos(phi),std::sin(phi)), controls[0]);
			} else {
				Phase(amplitude(std::cos(phi),std::sin(phi)), controls[0]);
			}
			return;
		}

		_execute_if(controls);
		// The target can commute with rotations of the same type
		if (_queue_Ry[target] && b != Gates::Basis::PauliY){
			_execute_queued_ops(target, OP::Ry);
		} 
		if (_queue_Rx[target] && b != Gates::Basis::PauliX){
			_execute_queued_ops(target, OP::Rx);
		}
		if (_queue_H[target]){
			_execute_queued_ops(target, OP::H);
		}
		// Execute any phase and permutation gates
		// These are not indexed by qubit so it does 
		// not matter what the qubit argument is
		_execute_queued_ops(0, OP::PermuteLarge);
		_quantum_state->MCR(controls, b, phi, target);
		_set_qubit_to_nonzero(target);		
	}
	
	void RFrac(Gates::Basis axis, std::int64_t numerator, std::int64_t power, logical_qubit_id index) {
		// Opposite sign convention
		R(axis, -(double)numerator * std::pow(0.5, power-1 )*M_PI, index);
	}

	void MCRFrac(std::vector<logical_qubit_id> const& controls, Gates::Basis axis, std::int64_t numerator, std::int64_t power, logical_qubit_id target) {	
		// Opposite sign convention
		MCR(controls, axis, -(double)numerator * pow(0.5, power - 1) * M_PI, target);
	}

	void Exp(std::vector<Gates::Basis> const& axes, double angle, std::vector<logical_qubit_id> const& qubits){
		amplitude cosAngle = std::cos(angle);
		amplitude sinAngle = 1i*std::sin(angle);
		// This does not commute nicely with anything, so we execute everything
		_execute_queued_ops(qubits);
		_quantum_state->PauliCombination(axes, qubits, cosAngle, sinAngle);
		for (auto qubit : qubits){
			_set_qubit_to_nonzero(qubit);
		}
	}

	void MCExp(std::vector<logical_qubit_id> const& controls, std::vector<Gates::Basis> const& axes, double angle, std::vector<logical_qubit_id> const& qubits){
		amplitude cosAngle = std::cos(angle);
		amplitude sinAngle = 1i*std::sin(angle);
		// This does not commute nicely with anything, so we execute everything
		_execute_queued_ops(qubits);
		_execute_queued_ops(controls);
		_quantum_state->MCPauliCombination(controls, axes, qubits, cosAngle, sinAngle);
		for (auto qubit : qubits){
			_set_qubit_to_nonzero(qubit);
		}
	}

	
	
	void H(logical_qubit_id index) {
		// YH = -HY
		_angles_Ry[index] *= (_queue_Ry[index] ? -1.0 : 1.0);
		// Commuting with Rx creates a phase, but on the wrong side
		// So we execute any Rx immediately
		if (_queue_Rx[index]){
			_execute_queued_ops(index, OP::Rx);
		}
		_queue_H[index] = !_queue_H[index];
		_set_qubit_to_nonzero(index);
	}

	void MCH(std::vector<logical_qubit_id> const& controls, logical_qubit_id target) {
		// No commutation on controls
		_execute_if(controls);
		// No Ry or Rx commutation on target
		if (_queue_Ry[target] || _queue_Rx[target]){
			_execute_queued_ops(target, OP::Ry);
		} 
		// Commutes through H gates on the target, so it does not check
		_execute_phase_and_permute();
		_quantum_state->MCH(controls, target);
		_set_qubit_to_nonzero(target);
	}


	

	void SWAP(logical_qubit_id index_1, logical_qubit_id index_2){
		// This is necessary for the "shift" to make sense
		if (index_1 > index_2){
			std::swap(index_2, index_1);
		} 
		// Everything commutes nicely with a swap
		_queue_Ry.swap(_queue_Ry[index_1],  _queue_Ry[index_2]);
		std::swap(_angles_Ry[index_1], _angles_Ry[index_2]);
		_queue_Rx.swap(_queue_Rx[index_1],  _queue_Rx[index_2]);
		std::swap(_angles_Rx[index_1], _angles_Rx[index_2]);
		_queue_H.swap(_queue_H[index_1],  _queue_H[index_2]);
		_occupied_qubits.swap(_occupied_qubits[index_1], _occupied_qubits[index_2]);
		logical_qubit_id shift = index_2 - index_1;
		_queued_operations.push_back(operation(OP::SWAP, index_1, shift, index_2));
	}

	void CSWAP(std::vector<logical_qubit_id> const& controls, logical_qubit_id index_1, logical_qubit_id index_2){
		if (index_1 > index_2){
			std::swap(index_2, index_1);
		}
		// Nothing commutes nicely with a controlled swap
		_execute_if(controls);
		_execute_if(index_1);
		_execute_if(index_2);	

		logical_qubit_id shift = index_2 - index_1;
		_queued_operations.push_back(operation(OP::MCSWAP, index_1, shift, controls, index_2));
		// If either qubit is occupied, then set them both to occupied
		if(_occupied_qubits[index_1] || _occupied_qubits[index_2]){
			_set_qubit_to_nonzero(index_1);
			_set_qubit_to_nonzero(index_2);
		}
	}

	bool M(logical_qubit_id target) {
		// Do nothing if the qubit is known to be 0
		if (!_occupied_qubits[target]){ 
			return false;
		}
		// If we get a measurement, we take it as soon as we can
		_execute_queued_ops(target, OP::Ry);
		// If we measure 0, then this resets the occupied qubit register
		if (_quantum_state->M(target)){
			_set_qubit_to_nonzero(target);
		} else {
			_set_qubit_to_zero(target);
		}
		return _occupied_qubits[target];

	}

	void Reset(logical_qubit_id target) {
		if (!_occupied_qubits[target]){ return; }
		// If we get a measurement, we take it as soon as we can
			_execute_queued_ops(target, OP::Ry);
		_quantum_state->Reset(target);
		_set_qubit_to_zero(target);
	}

	void Assert(std::vector<Gates::Basis> axes, std::vector<logical_qubit_id> const& qubits, bool result) {
		// Assertions will not commute well with Rx or Ry
		for (auto qubit : qubits) {
			if (_queue_Rx[qubit] || _queue_Ry[qubit]){
				_execute_queued_ops(qubits, OP::Ry);
			}
		}
		bool isAllZ = true;
		bool isEmpty = true;
		// Process each assertion by H commutation
		for (int i = 0; i < qubits.size(); i++) { 		
			switch (axes[i]){
				case Gates::Basis::PauliY:
					// HY=YH, so we switch the eigenvalue
					if (_queue_H[qubits[i]]){
						result ^= _queue_H[qubits[i]];
					}
					isAllZ = false;
					isEmpty = false;
					break; 
				case Gates::Basis::PauliX:
					// HX = ZH
					if (_queue_H[qubits[i]]){
						axes[i] = Gates::Basis::PauliZ;
					} else {
						isAllZ = false;
					}
					isEmpty = false;
					break;
				case Gates::Basis::PauliZ:
					// HZ = XH
					if (_queue_H[qubits[i]]){
						axes[i] = Gates::Basis::PauliX;
						isAllZ = false;
					}
					isEmpty = false;
					break;
				default:
					break;
			}
		}
		if (isEmpty) {
			return;
		}
		// Z assertions are like phase gates
		// If it's in release mode, it will queue them
		// as a phase/permutation gate
		// This means if an assert fails, it will fail
		// at some future point, not at the point of failure
		#if NDEBUG
			if (isAllZ) {
				_queued_operations.push_back(operation(OP::Assert, qubits, result));
				return;
			}
		#endif
		// X or Y assertions require execution
		_execute_queued_ops(qubits, OP::PermuteLarge);
		_quantum_state->Assert(axes, qubits, result);
	}

	// Returns the probability of a given measurement in a Pauli basis
	// by decomposing each pair of computational basis states into eigenvectors
	// and adding the coefficients of the respective components
	double MeasurementProbability(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits) {
		_execute_queued_ops(qubits, OP::Ry);
		return _quantum_state->MeasurementProbability(axes, qubits);
	}



	bool Measure(std::vector<Gates::Basis> const& axes, std::vector<logical_qubit_id> const& qubits){
		_execute_queued_ops(qubits, OP::Ry);
		bool result = _quantum_state->Measure(axes, qubits);
		// Switch basis to save space
		// Idea being that, e.g., HH = I, but if we know 
		// that the qubit is in the X-basis, we can apply H
		// and execute, and this will send that qubit to all ones
		// or all zeros; then we leave the second H in the queue
		// Ideally we would also do that with Y, but HS would force execution,
		// rendering it pointless
		std::vector<logical_qubit_id> measurements;
		for (int i =0; i < axes.size(); i++){
			if (axes[i]==Gates::Basis::PauliX){
				H(qubits[i]);
				measurements.push_back(qubits[i]);
			} 
		}
		_execute_queued_ops(measurements, OP::H);
		// These operations undo the previous operations, but they will be 
		// queued 
		for (int i =0; i < axes.size(); i++){
			if (axes[i]==Gates::Basis::PauliX){
				H(qubits[i]);
			} 
		}
		return result;
	}

	// Returns the amplitude of a given bitstring
	amplitude probe(std::string label) {
		_execute_queued_ops();
		return _quantum_state->probe(label);
	}

	std::string Sample() {
		_execute_queued_ops();
		return _quantum_state->Sample();
	}

	// Dumps the state of a subspace of particular qubits, if they are not entangled
	// This requires it to detect if the subspace is entangled, construct a new 
	// projected wavefunction, then call the `callback` function on each state.
	bool dump_qubits(std::vector<logical_qubit_id> qubits, void (*callback)(char*, double, double)) {
		_execute_queued_ops(qubits, OP::Ry);
		return _quantum_state->dump_qubits(qubits, callback);
	}

	// Dumps all the states in superposition via a callback function
	void dump_all(logical_qubit_id max_qubit_id, void (*callback)(char*, double, double)) {
		_execute_queued_ops();
		_quantum_state->dump_all(max_qubit_id, callback);
	}

	// Updates state to all queued gates
	void update_state() {
		_execute_queued_ops();
	}


private:

	// These indicate whether there are any H, Rx, or Ry gates
	// that have yet to be applied to the wavefunction. 
	// Since HH=I and Rx(theta_1)Rx(theta_2) = Rx(theta_1+theta_2)
	// it only needs a boolean to track them.
	std::vector<bool> _queue_H;
	std::vector<bool> _queue_Rx;
	std::vector<bool> _queue_Ry;

	std::vector<double> _angles_Rx;
	std::vector<double> _angles_Ry;

	// Store which qubits are non-zero as a bitstring
	std::vector<bool> _occupied_qubits;
	logical_qubit_id _max_num_qubits_used = 0;
	logical_qubit_id _current_number_qubits_used;

	// In a situation where we know a qubit is zero,
	// this sets the occupied qubit vector and decrements
	// the current number of qubits if necessary
	void _set_qubit_to_zero(logical_qubit_id index){
		if (_occupied_qubits[index]){
			--_current_number_qubits_used;
		}
		_occupied_qubits[index] = false;
	}

	// In a situation where a qubit may be non-zero,
	// we increment which qubits are used, and update the current
	// and maximum number of qubits
	void _set_qubit_to_nonzero(logical_qubit_id index){
		if (!_occupied_qubits[index]){
			++_current_number_qubits_used;
			_max_num_qubits_used = std::max(_max_num_qubits_used, _current_number_qubits_used);
		}
		_occupied_qubits[index] = true;
	}

	// Normalizer for T gates: 1/sqrt(2)
	const double _normalizer_double = 1.0 / std::sqrt(2.0);

	// Internal quantum state
	std::shared_ptr<BasicQuantumState> _quantum_state;

	// Queued phase and permutation operations
	std::list<operation> _queued_operations;

	// The next three functions execute the H, and/or Rx, and/or Ry 
	// queues on a single qubit
	void _execute_RyRxH_single_qubit(logical_qubit_id const &index){
		if (_queue_H[index]){
			_quantum_state->H(index);
			_queue_H[index] = false;
		}
		if (_queue_Rx[index]){
			_quantum_state->R(Gates::Basis::PauliX, _angles_Rx[index], index);
			_angles_Rx[index] = 0.0;
			_queue_Rx[index] = false;
		}
		if (_queue_Ry[index]){
			_quantum_state->R(Gates::Basis::PauliY, _angles_Ry[index], index);
			_angles_Ry[index] = 0.0;
			_queue_Ry[index] = false;
		}
	}

	void _execute_RxH_single_qubit(logical_qubit_id const &index){
		if (_queue_H[index]){
			_quantum_state->H(index);
			_queue_H[index] = false;
		}
		if (_queue_Rx[index]){
			_quantum_state->R(Gates::Basis::PauliX, _angles_Rx[index], index);
			_angles_Rx[index] = 0.0;
			_queue_Rx[index] = false;
		}
	}

	void _execute_H_single_qubit(logical_qubit_id const &index){
		if (_queue_H[index]){
			_quantum_state->H(index);
			_queue_H[index] = false;
		}
	}
	
	// Executes all phase and permutation operations, if any exist
	void _execute_phase_and_permute(){
		if (_queued_operations.size() != 0){
			_quantum_state->phase_and_permute(_queued_operations);
			_queued_operations.clear();
		}
	}

	// Executes all queued operations (including H and rotations)
	// on all qubits
	void _execute_queued_ops() { 
		_execute_phase_and_permute();
		logical_qubit_id num_qubits = _quantum_state->get_num_qubits();
		for (logical_qubit_id index =0; index < num_qubits; index++){
			_execute_RyRxH_single_qubit(index);
		}
	}

	// Executes all phase and permutation operations,
	// then any H, Rx, or Ry gates queued on the qubit index, 
	// up to the level specified (where H < Rx < Ry)
	void _execute_queued_ops(logical_qubit_id index, OP level = OP::Ry){
		_execute_phase_and_permute();
		switch (level){
			case OP::Ry:
				_execute_RyRxH_single_qubit(index);
				break;
			case OP::Rx:
				_execute_RxH_single_qubit(index);
				break;
			case OP::H:
				_execute_H_single_qubit(index);
				break;
			default:
				break;
		}
	}

	// Executes all phase and permutation operations,
	// then any H, Rx, or Ry gates queued on any of the qubit indices, 
	// up to the level specified (where H < Rx < Ry)
	void _execute_queued_ops(std::vector<logical_qubit_id> indices, OP level = OP::Ry){
		_execute_phase_and_permute();
		switch (level){
			case OP::Ry:
				for (auto index : indices){
					_execute_RyRxH_single_qubit(index);
				}
				break;
			case OP::Rx:
				for (auto index : indices){
					_execute_RxH_single_qubit(index);
				}
				break;
			case OP::H:
				for (auto index : indices){
					_execute_H_single_qubit(index);
				}
				break;
			default:
				break;
		}
	}


	// Executes if there is anything already queued on the qubit target
	// Used when queuing gates that do not commute well
	void _execute_if(logical_qubit_id &target){
		if (_queue_Ry[target] || _queue_Rx[target] || _queue_H[target]){
			_execute_queued_ops(target, OP::Ry);
		}
	}

	// Executes if there is anything already queued on the qubits in controls
	// Used when queuing gates that do not commute well
	void _execute_if(std::vector<logical_qubit_id> const &controls) {
		for (auto control : controls){
			if (_queue_Ry[control] || _queue_Rx[control] || _queue_H[control]){
				_execute_queued_ops(controls, OP::Ry);
				return;
			}
		}
	}

};

} // namespace Microsoft::Quantum::SPARSESIMULATOR
