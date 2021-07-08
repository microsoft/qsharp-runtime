// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "../SparseQuantumSimulator/SparseSimulator.h"
#include "../SparseQuantumSimulator/capi.hpp"
#include "../SparseQuantumSimulator/capi.cpp" // yes really
#include "../SparseQuantumSimulator/factory.hpp"
#include "../SparseQuantumSimulator/factory.cpp"
#include "TestHelpers.hpp"

#include "CppUnitTest.h"
#include <cmath>
#include <iostream>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;
using namespace Microsoft::Quantum::SPARSESIMULATOR;
using namespace SparseSimulatorTestHelpers;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace CSharpIntegrationTests
{
	TEST_CLASS(CSharpIntegrationTests)
	{
		template<size_t num_qubits>
		void MultiExpReferenceTest(
			std::function<void(unsigned)> qubit_prep,
			std::function<void(unsigned)> qubit_clear
		) {
			const qubit_label_type<num_qubits> zero(0);
			logical_qubit_id* qubits = new logical_qubit_id[3];
			qubits[0] = 0;
			qubits[1] = 1;
			qubits[2] = 2;
			int* Paulis = new int[3];
			for (int intPaulis = 0; intPaulis < 4 * 4 * 4; intPaulis++) {
				Paulis[0] = intPaulis % 4;
				Paulis[1] = (intPaulis / 4 ) % 4;
				Paulis[2] = intPaulis / 16;
				
				for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
					unsigned sim = init_cpp(32);
					qubit_prep(sim);
					
					std::vector<amplitude> vector_rep(8, 0.0);
					for (unsigned i = 0; i < 8; i++) {
						vector_rep[i] = getSimulator(sim)->probe(std::bitset<3>(i).to_string());
					}
					// New simulator Exp
					Exp_cpp(sim, 3, Paulis, angle, qubits);
					// Old simulator Exp
					std::vector<Gates::Basis> actualPaulis = { (Gates::Basis)Paulis[0],(Gates::Basis)Paulis[1], (Gates::Basis)Paulis[2] };
					apply_exp(vector_rep, actualPaulis, angle, std::vector<unsigned>{ 0, 1, 2 });
					for (unsigned i = 0; i < 8; i++) {
						amplitude result = getSimulator(sim)->probe(std::bitset<3>(i).to_string());
						assert_amplitude_equality(vector_rep[i], result);
					}
					Exp_cpp(sim, 3, Paulis, -angle, qubits);
					qubit_clear(sim);
				}
			}
		}
	public:
		TEST_METHOD(initializationTest) {
			unsigned sim = init_cpp(32);
		}

		TEST_METHOD(AllocationTest) {
			unsigned sim = init_cpp(32);
			allocateQubit_cpp(sim, 0);
			releaseQubit_cpp(sim, 0);
		}
		TEST_METHOD(AllocateRebuildTest) {
			unsigned sim = init_cpp(64);
			for (int i = 0; i < 1024; i++) {
				allocateQubit_cpp(sim, i);
				getSimulator(sim)->X(i);
				getSimulator(sim)->update_state();
			}
			for (int i = 0; i < 1024; i++) {
				getSimulator(sim)->X(i);
				releaseQubit_cpp(sim, i);
			}
		}

		TEST_METHOD(XTest) {
			unsigned sim = init_cpp(32);
			allocateQubit_cpp(sim, 0);
			X_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0, 0.0);
			X_cpp(sim, 0);
			releaseQubit_cpp(sim, 0);
		}
		TEST_METHOD(ZTest) {
			unsigned sim = init_cpp(32);
			allocateQubit_cpp(sim, 0);
			Z_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, 0.0);
			Z_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, 0.0);
			X_cpp(sim, 0);
			Z_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), -1.0, 0.0);
			Z_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0, 0.0);
			X_cpp(sim, 0);
			releaseQubit_cpp(sim, 0);
		}
		TEST_METHOD(HTest) {
			unsigned sim = init_cpp(32);
			allocateQubit_cpp(sim, 0);
			H_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0 / sqrt(2.0), 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0 / sqrt(2.0), 0.0);
			H_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, 0.0);
			X_cpp(sim, 0);
			H_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0 / sqrt(2.0), 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), -1.0 / sqrt(2.0), 0.0);
			H_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0, 0.0);
			X_cpp(sim, 0);
			releaseQubit_cpp(sim, 0);
		}

		TEST_METHOD(TGateTest) {
			unsigned sim = init_cpp(32);
			allocateQubit_cpp(sim, 0);
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 1.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, 0.0);
			X_cpp(sim, 0);
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0 / sqrt(2.0), 1.0 / sqrt(2.0));
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, 1.0);
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), -1.0 / sqrt(2.0), 1.0 / sqrt(2.0));
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), -1.0, 0.0);
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), -1.0 / sqrt(2.0), -1.0 / sqrt(2.0));
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 0.0, -1.0);
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0 / sqrt(2.0), -1.0 / sqrt(2.0));
			T_cpp(sim, 0);
			assert_amplitude_equality(getSimulator(sim)->probe("0"), 0.0, 0.0);
			assert_amplitude_equality(getSimulator(sim)->probe("1"), 1.0, 0.0);
			X_cpp(sim, 0);
			releaseQubit_cpp(sim, 0);
		}

		TEST_METHOD(HCancellationTest)
		{
			int n_qubits = 16;
			unsigned sim = init_cpp(n_qubits);
			size_t buckets = 0;
			for (int i = 0; i < n_qubits; i++) {
				allocateQubit_cpp(sim, i);
				H_cpp(sim, i);
			}
			for (int i = n_qubits - 1; i >= 0; i--) {
				H_cpp(sim, i);
				// If the H do not cancel out, release will fail in an opaque way
				releaseQubit_cpp(sim, i);
			}
		}

		TEST_METHOD(HXZCommutationTest)
		{
			const int n_qubits = 16;
			unsigned sim = init_cpp(n_qubits);
			for (int i = 0; i < n_qubits; i++) {
				allocateQubit_cpp(sim, i);
				H_cpp(sim, i);
			}
			std::bitset<n_qubits> one_state = 0;
			for (int i = 0; i < n_qubits - 1; i += 2) {
				Z_cpp(sim, i);
				X_cpp(sim, i+1);
				one_state.set(i);
			}
			for (int i = n_qubits - 1; i >= 0; i--) {
				H_cpp(sim, i);
			}
			for (__int64 i = 0; i< pow(2, n_qubits); i++) {
				amplitude state = getSimulator(sim)->probe(std::bitset<n_qubits>(i).to_string());
				if (i == one_state.to_ulong()) {
					assert_amplitude_equality(state, 1.0, 0.0);
				}
				else {
					assert_amplitude_equality(state, 0.0, 0.0);
				}
			}
		}

		TEST_METHOD(ResetTest)
		{
			const int n_qubits = 16;
			unsigned sim = init_cpp(n_qubits);
			allocateQubit_cpp(sim, 0);
			Reset_cpp(sim, 0);
			amplitude state = getSimulator(sim)->probe("0");
			assert_amplitude_equality(state, 1.0, 0.0);
			X_cpp(sim, 0);
			Reset_cpp(sim, 0);
			state = getSimulator(sim)->probe("0");
			// No qubit exists; should have amplitude 0
			assert_amplitude_equality(state, 1.0, 0.0);
			allocateQubit_cpp(sim, 1);
			X_cpp(sim, 0);
			logical_qubit_id* controls = new logical_qubit_id{ 0 };
			MCX_cpp(sim, 1, controls, 1);
			Reset_cpp(sim, 0);
			state = getSimulator(sim)->probe("00");
			assert_amplitude_equality(state, 0.0, 0.0);
			state = getSimulator(sim)->probe("10");
			assert_amplitude_equality(state, 1.0, 0.0);
			Reset_cpp(sim, 1);
			state = getSimulator(sim)->probe("00");
			assert_amplitude_equality(state, 1.0, 0.0);
			state = getSimulator(sim)->probe("10");
			assert_amplitude_equality(state, 0.0, 0.0);
			releaseQubit_cpp(sim, 1);
			releaseQubit_cpp(sim, 0);
		}
		
		TEST_METHOD(MultiExpWithHTest) {
			const int num_qubits = 32;
			auto qubit_prep = [](unsigned sim ) {
				H_cpp(sim, 0);
				H_cpp(sim, 1);
				H_cpp(sim, 2);
			};
			auto qubit_clear = [](unsigned sim) {
				H_cpp(sim, 2);
				releaseQubit_cpp(sim, 2);
				H_cpp(sim, 1);
				releaseQubit_cpp(sim, 1);
				H_cpp(sim, 0);
				releaseQubit_cpp(sim, 0);
			};
			MultiExpReferenceTest<num_qubits>(qubit_prep, qubit_clear);
		}

		TEST_METHOD(MultiExpBasisTest) {
			const int num_qubits = 32;
			auto qubit_prep = [](unsigned sim, int index) {
				if ((index & 1) == 0) { X_cpp(sim, 0); }
				if ((index & 2) == 0) { X_cpp(sim, 1); }
				if ((index & 4) == 0) { X_cpp(sim, 2); }
			};
			auto qubit_clear = [](unsigned sim, int index) {
				if ((index & 1) == 0) { X_cpp(sim, 0); }
				releaseQubit_cpp(sim, 0);
				if ((index & 2) == 0) { X_cpp(sim, 1); }
				releaseQubit_cpp(sim, 1);
				if ((index & 4) == 0) { X_cpp(sim, 2); }
				releaseQubit_cpp(sim, 2);
			};
			for (int i = 0; i < 8; i++) {
				MultiExpReferenceTest<num_qubits>([=](unsigned sim) {qubit_prep(sim, i); }, [=](unsigned sim) {qubit_clear(sim, i); });
			}
		}

		TEST_METHOD(R1Test) {
			const int num_qubits = 32;
			amplitude result0;
			amplitude result1;
			for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
				unsigned sim = init_cpp(num_qubits);
				H_cpp(sim, 0);
				R1_cpp(sim, angle, 0);
				result0 = getSimulator(sim)->probe("0");
				result1 = getSimulator(sim)->probe("1");
				assert_amplitude_equality(result0, 1.0 / sqrt(2.0));
				assert_amplitude_equality(result1, amplitude(cos(angle), sin(angle))/sqrt(2.0));
				R1_cpp(sim, -angle, 0);
				result0 = getSimulator(sim)->probe("0");
				result1 = getSimulator(sim)->probe("1");
				assert_amplitude_equality(result0, 1.0 / sqrt(2.0));
				assert_amplitude_equality(result1, 1.0 / sqrt(2.0));
				H_cpp(sim, 0);
				releaseQubit_cpp(sim, 0);
				destroy_cpp(sim);
			}
		}
	};
}