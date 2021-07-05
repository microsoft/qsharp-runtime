#pragma once

#include "pch.h"
#include "CppUnitTest.h"
#include "../SparseQuantumSimulator/SparseSimulator.h"
#include <cmath>
#include <iostream>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;
using namespace Microsoft::Quantum::SPARSESIMULATOR;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif




namespace SparseSimulatorTestHelpers
{

	void apply_exp(
		std::vector<amplitude>& wfn,
		std::vector<Gates::Basis> b,
		double phi,
		std::vector<unsigned>  qs);

	void assert_amplitude_equality(amplitude amp, double real, double imag);

	void assert_amplitude_equality(amplitude expected_amp, amplitude actual_amp);

	// Prepares some qubits, then checks whether various Pauli exponentials work
	
}