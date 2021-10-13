// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "SparseSimulator.h"
#include <cmath>
#include <iostream>
#include <catch.hpp>

using namespace Microsoft::Quantum::SPARSESIMULATOR;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define TEST_TOLERANCE 1.e-10


namespace SparseSimulatorTestHelpers
{

	inline std::size_t make_mask(std::vector<logical_qubit_id> const& qs)
	{
		std::size_t mask = 0;
		for (std::size_t q : qs)
			mask = mask | (1ull << q);
		return mask;
	}
	// power of square root of -1
	inline amplitude iExp(int power)
	{
		using namespace std::literals::complex_literals;
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

	inline bool isDiagonal(std::vector<Gates::Basis> const& b)
	{
		for (auto x : b)
			if (x == Gates::Basis::PauliX || x == Gates::Basis::PauliY) return false;
		return true;
	}

	inline static void removeIdentities(std::vector<Gates::Basis>& b, std::vector<logical_qubit_id>& qs)
	{
		size_t i = 0;
		while (i != b.size())
		{
			if (b[i] == Gates::Basis::PauliI)
			{
				b.erase(b.begin() + i);
				qs.erase(qs.begin() + i);
			}
			else
				++i;
		}
	}

	// Taken from qsharp-runtime
	void apply_exp(
		std::vector<amplitude>& wfn,
		std::vector<Gates::Basis> b,
		double phi,
		std::vector<logical_qubit_id> qs)
	{
		removeIdentities(b, qs);
		if (qs.size() == 0) { return; }
		logical_qubit_id lowest = *std::min_element(qs.begin(), qs.end());

		std::size_t offset = 1ull << lowest;
		if (isDiagonal(b))
		{
			std::size_t mask = make_mask(qs);
			amplitude phase = std::exp(amplitude(0., -phi));

			for (std::intptr_t x = 0; x < static_cast<std::intptr_t>(wfn.size()); x++)
				wfn[x] *= (std::bitset<64>(x & mask).count() % 2 ? phase : std::conj(phase));
		}
		else {
			std::size_t xy_bits = 0;
			std::size_t yz_bits = 0;
			int y_count = 0;
			for (size_t i = 0; i < b.size(); ++i)
			{
				switch (b[i])
				{
				case Gates::Basis::PauliX:
					xy_bits |= (1ull << qs[i]);
					break;
				case Gates::Basis::PauliY:
					xy_bits |= (1ull << qs[i]);
					yz_bits |= (1ull << qs[i]);
					++y_count;
					break;
				case Gates::Basis::PauliZ:
					yz_bits |= (1ull << qs[i]);
					break;
				case Gates::Basis::PauliI:
					break;
				default:
					break;
				}
			}

			amplitude alpha = std::cos(phi);
			amplitude beta = std::sin(phi) * iExp(3 * y_count + 1);
			amplitude gamma = std::sin(phi) * iExp(y_count + 1);

			for (std::intptr_t x = 0; x < static_cast<std::intptr_t>(wfn.size()); x++)
			{
				std::intptr_t t = x ^ xy_bits;
				if (x < t)
				{
					bool parity = std::bitset<64>(x & yz_bits).count() % 2;
					auto a = wfn[x];
					auto b = wfn[t];
					wfn[x] = alpha * a + (parity ? -beta : beta) * b;
					wfn[t] = alpha * b + (parity ? -gamma : gamma) * a;
				}
			}
		}
	}

	// Assertions for equality of amplitude types
	inline void assert_double_equality_with_tolerance(double value1, double value2) {
		REQUIRE(value1 == Approx(value2).margin(TEST_TOLERANCE));
	}

	void assert_amplitude_equality(amplitude amp, double real, double imag) {
		assert_double_equality_with_tolerance(real, amp.real());
		assert_double_equality_with_tolerance(imag, amp.imag());
	}

	void assert_amplitude_equality(amplitude expected_amp, amplitude actual_amp) {
		assert_amplitude_equality(actual_amp, expected_amp.real(), expected_amp.imag());
	}
}