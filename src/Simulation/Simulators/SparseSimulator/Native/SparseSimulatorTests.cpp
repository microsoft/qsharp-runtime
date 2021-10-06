// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#define CATCH_CONFIG_MAIN
#include <catch.hpp>

#include "SparseSimulator.h"
#include "TestHelpers.hpp"
#include <cmath>
#include <iostream>

using namespace Microsoft::Quantum::SPARSESIMULATOR;
using namespace SparseSimulatorTestHelpers;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif



template<size_t num_qubits>
void MultiExpTest(
    std::function<void(SparseSimulator&)> qubit_prep,
    std::function<void(SparseSimulator&)> qubit_clear
) {
    for (int intPaulis = 0; intPaulis < 4 * 4 * 4; intPaulis++) {
        std::vector<Gates::Basis> Paulis{
            (Gates::Basis)(intPaulis % 4),
            (Gates::Basis)((intPaulis / 4) % 4),
            (Gates::Basis)(intPaulis / 16)
        };
        for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
            SparseSimulator sim = SparseSimulator(num_qubits);
            std::vector<unsigned> qubits{ 0,1,2 };
            qubit_prep(sim);
            std::vector<amplitude> vector_rep(8, 0.0);
            for (unsigned i = 0; i < 8; i++) {
                vector_rep[i] = sim.probe(std::bitset<3>(i).to_string());
            }
            // New simulator Exp
            sim.Exp(Paulis, angle, qubits);
            // Old simulator Exp
            apply_exp(vector_rep, Paulis, angle, std::vector<unsigned>{ 0, 1, 2 });
            for (unsigned i = 0; i < 8; i++) {
                amplitude result = sim.probe(std::bitset<3>(i).to_string());
                assert_amplitude_equality(vector_rep[i], result);
            }
            sim.Exp(Paulis, -angle, qubits);
            qubit_clear(sim);
        }
    }
}

// Tests comparisons of bitstrings
TEST_CASE("LabelComparisonTest") {
    const logical_qubit_id num_qubits = 1024;
    SparseSimulator sim = SparseSimulator(num_qubits);
    uint64_t i = 0;
    uint64_t j;
    uint64_t k = 0;
    qubit_label_type<num_qubits> label1(0);
    qubit_label_type<num_qubits> label2(1);

    for (i = 0; i < 500; i++){
        k += i * i * i * i;
        uint64_t m = 0;
        label1 = qubit_label_type<num_qubits>(k);
        for (j = 0; j < 500; j++){
            m += j * j * j * j;
            label2 = qubit_label_type<num_qubits>(m);
            REQUIRE((k < m) == (label1 < label2));
        }
    }
}
// Tests that the X gate flips the computational basis states
TEST_CASE("XGateTest") {
    const logical_qubit_id num_qubits = 32;
    SparseSimulator sim = SparseSimulator(num_qubits);
    sim.X(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
    sim.X(0);
    assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
}

// Tests Z on computational basis states
TEST_CASE("ZGateTest") {
    const logical_qubit_id num_qubits = 32;
    SparseSimulator sim = SparseSimulator(num_qubits);
    sim.Z(0);
    assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
    sim.Z(0);
    assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
    sim.X(0);
    sim.Z(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), -1.0, 0.0);
    sim.Z(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
}

// Tests H on computational basis states
TEST_CASE("HGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    sim.H(0);
    assert_amplitude_equality(sim.probe("0"), 1.0 / sqrt(2.0), 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0 / sqrt(2.0), 0.0);
    sim.H(0);
    assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
    sim.X(0);
    sim.H(0);
    assert_amplitude_equality(sim.probe("0"), 1.0 / sqrt(2.0), 0.0);
    assert_amplitude_equality(sim.probe("1"), -1.0 / sqrt(2.0), 0.0);
    sim.H(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
}

// Tests powers of T on computational basis states
TEST_CASE("TGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
    sim.X(0);
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0 / sqrt(2.0), 1.0 / sqrt(2.0));
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, 1.0);
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), -1.0 / sqrt(2.0), 1.0 / sqrt(2.0));
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), -1.0, 0.0);
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), -1.0 / sqrt(2.0), -1.0 / sqrt(2.0));
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 0.0, -1.0);
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0 / sqrt(2.0), -1.0 / sqrt(2.0));
    sim.T(0);
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
}

// Tests Rx on computational basis states, for angles between 0 and pi/2
TEST_CASE("RxGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
        SparseSimulator sim = SparseSimulator(num_qubits);
        sim.R(Gates::Basis::PauliX, angle, 0);
        assert_amplitude_equality(sim.probe("0"), cos(angle / 2.0), 0.0);
        assert_amplitude_equality(sim.probe("1"), 0.0, -sin(angle / 2.0));
        sim.R(Gates::Basis::PauliX, -angle, 0);
        assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
        sim.X(0);
        sim.R(Gates::Basis::PauliX, angle, 0);
        assert_amplitude_equality(sim.probe("0"), 0.0, -sin(angle / 2.0));
        assert_amplitude_equality(sim.probe("1"), cos(angle / 2.0), 0.0);
        sim.R(Gates::Basis::PauliX, -angle, 0);
        assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
    }
}

// Tests Ry on computational basis states, for angles between 0 and pi/2
TEST_CASE("RyGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
        SparseSimulator sim = SparseSimulator(num_qubits);
        sim.R(Gates::Basis::PauliY, angle, 0);
        assert_amplitude_equality(sim.probe("0"), cos(angle / 2.0), 0.0);
        assert_amplitude_equality(sim.probe("1"), sin(angle / 2.0), 0.0);
        sim.R(Gates::Basis::PauliY, -angle, 0);
        assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
        sim.X(0);
        sim.R(Gates::Basis::PauliY, angle, 0);
        assert_amplitude_equality(sim.probe("0"), -sin(angle / 2.0), 0.0);
        assert_amplitude_equality(sim.probe("1"), cos(angle / 2.0), 0.0);
        sim.R(Gates::Basis::PauliY, -angle, 0);
        assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
    }
}

// Tests Rz on computational basis states, for angles between 0 and pi/2
TEST_CASE("RzGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
        SparseSimulator sim = SparseSimulator(num_qubits);
        logical_qubit_id qubit = 0;
        sim.R(Gates::Basis::PauliZ, angle, qubit);
        assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
        sim.R(Gates::Basis::PauliZ, -angle, qubit);
        assert_amplitude_equality(sim.probe("0"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 0.0, 0.0);
        sim.X(qubit);
        assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
        sim.R(Gates::Basis::PauliZ, angle, qubit);
        assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), cos(angle), sin(angle));
        sim.R(Gates::Basis::PauliZ, -angle, qubit);
        assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
    }
}

// Tests CNOT on all 2-qubit computational basis stats
TEST_CASE("CNOTGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    logical_qubit_id qubits[2]{ 0, 1 };
    sim.MCX({ qubits[0] }, qubits[1]);
    assert_amplitude_equality(sim.probe("00"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
    sim.X(qubits[0]);
    sim.MCX({ qubits[0] }, qubits[1]);
    assert_amplitude_equality(sim.probe("00"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 1.0, 0.0);
    sim.MCX({ qubits[0] }, qubits[1]);
    assert_amplitude_equality(sim.probe("00"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
    sim.X(qubits[0]);
    sim.X(qubits[1]);
    sim.MCX({ qubits[0] }, qubits[1]);
    assert_amplitude_equality(sim.probe("00"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
}



// Tests all possible computational basis states
// for some number of controls and one target
TEST_CASE("MCXGateTest") {
    const size_t n_qubits = 7;
    const qubit_label_type<n_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(n_qubits);
    std::vector<logical_qubit_id> qubits(n_qubits);
    std::generate(qubits.begin(), qubits.end(), [] { static int i{ 0 }; return i++; });
    std::vector<logical_qubit_id> controls(qubits.begin() + 1, qubits.end());
    logical_qubit_id target = qubits[0];
    for (logical_qubit_id i = 0; i < pow(2, n_qubits - 1); i++) { // the bitstring of the controls
        sim.MCX(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) { // bitstring to test
            std::bitset<n_qubits> j_bits = j; // a bitset for the string to test, with the target as 0
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits; // same as j, but with the target as 1
            j_odd_bits.set(0);
            if (j != i) { // The controls are not in this state, so the amplitude should be 0
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else if (i == pow(2, n_qubits - 1) - 1) { // All controls are 1, so this should flip the output
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 1.0, 0.0);
            }
            else { // This is the state of the controls, but they are not all 1, so nothing should have happened
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
        }
        // Since MCX^2 = I, this should undo anything previously
        sim.MCX(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) {
            std::bitset<n_qubits> j_bits = j;
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits;
            j_odd_bits.set(0);
            if (j != i) { // The controls are not in this state, so the amplitude should be 0
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else { // This is the state of the controls, but the final qubit should be 0
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
        }
        // Update the controls
        std::bitset<n_qubits> diff = i ^ (i + 1);
        for (logical_qubit_id j = 0; j < n_qubits - 1; j++) {
            if (diff[j]) sim.X(controls[j]);
        }
    }
}


// Tests a controlled Y
// Same logic as the MCXGateTest
TEST_CASE("MCYGateTest") {
    const size_t n_qubits = 7;
    const qubit_label_type<n_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(n_qubits);
    std::vector<logical_qubit_id> qubits(n_qubits);
    std::generate(qubits.begin(), qubits.end(), [] { static int i{ 0 }; return i++; });
    std::vector<logical_qubit_id> controls(qubits.begin() + 1, qubits.end());
    logical_qubit_id target = qubits[0];
    for (logical_qubit_id i = 0; i < pow(2, n_qubits - 1); i++) {
        sim.MCY(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) {
            std::bitset<n_qubits> j_bits = j;
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits;
            j_odd_bits.set(0);
            if (j != i) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else if (i == pow(2, n_qubits - 1) - 1) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 1.0);
            }
            else {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
        }
        sim.MCY(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) {
            std::bitset<n_qubits> j_bits = j;
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits;
            j_odd_bits.set(0);
            if (j != i) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
        }
        std::bitset<n_qubits> diff = i ^ (i + 1);
        for (logical_qubit_id j = 0; j < n_qubits - 1; j++) {
            if (diff[j]) sim.X(controls[j]);
        }
    }
}
// Tests a controlled Z
// Same logic as the MCXGateTest
TEST_CASE("MCZGateTest") {
    const size_t n_qubits = 7;
    const qubit_label_type<n_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(n_qubits);
    std::vector<logical_qubit_id> qubits(n_qubits);
    std::generate(qubits.begin(), qubits.end(), [] { static int i{ 0 }; return i++; });
    std::vector<logical_qubit_id> controls(qubits.begin() + 1, qubits.end());
    logical_qubit_id target = qubits[0];
    sim.H(target);
    for (logical_qubit_id i = 0; i < pow(2, n_qubits - 1); i++) {
        sim.MCZ(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) {
            std::bitset<n_qubits> j_bits = j;
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits;
            j_odd_bits.set(0);
            if (j != i) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else if (i == pow(2, n_qubits - 1) - 1) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0/sqrt(2.0), 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), -1.0 / sqrt(2.0), 0.0);
            }
            else {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0 / sqrt(2.0), 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 1.0 / sqrt(2.0), 0.0);
            }
        }
        sim.MCZ(controls, target);
        for (logical_qubit_id j = 0; j < pow(2, n_qubits - 1); j++) {
            std::bitset<n_qubits> j_bits = j;
            j_bits = j_bits << 1;
            std::bitset<n_qubits> j_odd_bits = j_bits;
            j_odd_bits.set(0);
            if (j != i) {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 0.0, 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 0.0, 0.0);
            }
            else {
                assert_amplitude_equality(sim.probe(j_bits.to_string()), 1.0 / sqrt(2.0), 0.0);
                assert_amplitude_equality(sim.probe(j_odd_bits.to_string()), 1.0 / sqrt(2.0), 0.0);
            }
        }
        std::bitset<n_qubits> diff = i ^ (i + 1);
        for (logical_qubit_id j = 0; j < n_qubits - 1; j++) {
            if (diff[j]) sim.X(controls[j]);
        }
    }
}

    

// Tests the multi-exp on a uniform superposition
TEST_CASE("MultiExpWithHTest") {
    const int num_qubits = 32;
    auto qubit_prep = [](SparseSimulator& sim) {
        sim.H(0);
        sim.H(1);
        sim.H(2);
    };
    auto qubit_clear = [](SparseSimulator& sim) {
        sim.H(2);
        sim.release(2);
        sim.H(1);
        sim.release(1);
        sim.H(0);
        sim.release(0);
    };
    MultiExpTest<num_qubits>(qubit_prep, qubit_clear);
}

// Tests the MultiExp on all computational basis states of 3 qubits
TEST_CASE("MultiExpBasisTest") {
    const int num_qubits = 32;
    auto qubit_prep = [](SparseSimulator& sim, int index) {
        if ((index & 1) == 0) { sim.X(0); }
        if ((index & 2) == 0) { sim.X(1); }
        if ((index & 4) == 0) { sim.X(2); }
    };
    auto qubit_clear = [](SparseSimulator& sim, int index) {
        if ((index & 1) == 0) { sim.X(0); }
        sim.release(0);
        if ((index & 2) == 0) { sim.X(1); }
        sim.release(1);
        if ((index & 4) == 0) { sim.X(2); }
        sim.release(2);
    };
    for (int i = 0; i < 8; i++) {
        MultiExpTest<num_qubits>([=](SparseSimulator& sim) {qubit_prep(sim, i); }, [=](SparseSimulator& sim) {qubit_clear(sim, i); });
    }
}

// Tests a SWAP gate on all 2-qubit computational basis states
TEST_CASE("SWAPGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    std::vector<logical_qubit_id> qubits{ 0,1 };
    sim.SWAP({ qubits[0] }, qubits[1]); // 00 -> 00
    assert_amplitude_equality(sim.probe("00"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
    sim.X(qubits[0]);
    sim.SWAP( qubits[0] , qubits[1]); // 10 -> 01
    assert_amplitude_equality(sim.probe("00"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
    sim.SWAP( qubits[0] , qubits[1]); // 01 -> 10
    assert_amplitude_equality(sim.probe("0"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 0.0, 0.0);
    sim.X(qubits[1]);
    sim.SWAP( qubits[0] , qubits[1]); // 11 -> 11
    assert_amplitude_equality(sim.probe("00"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("01"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("10"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("11"), 1.0, 0.0);
}

// Tests multi-controlled swap on all computational basis states of 4 qubits
// (2 controls, 2 targets)
TEST_CASE("CSWAPGateTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    std::vector<logical_qubit_id> target_qubits{ 0,1 };
    std::vector<logical_qubit_id> control_qubits{ 2,3 };
    // Lambda to test when controls should cause no swap
    auto no_swap_test = [&](std::string controls) {
        sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 00 -> 00
        assert_amplitude_equality(sim.probe(controls+"00"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "01"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "10"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "11"), 0.0, 0.0);
        sim.X(target_qubits[0]);
        sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 01 -> 01
        assert_amplitude_equality(sim.probe(controls + "00"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "01"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "10"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "11"), 0.0, 0.0);
        sim.X(target_qubits[1]);
        sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 11 -> 11
        assert_amplitude_equality(sim.probe(controls + "00"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "01"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "10"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "11"), 1.0, 0.0);
        sim.X(target_qubits[0]);
        sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 10 -> 10
        assert_amplitude_equality(sim.probe(controls + "00"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "01"), 0.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "10"), 1.0, 0.0);
        assert_amplitude_equality(sim.probe(controls + "11"), 0.0, 0.0);
        sim.X(target_qubits[1]);
    };
    // Controls are 00, no swap
    no_swap_test("00");
    sim.X(control_qubits[0]);
    // Controls are 01, no swap
    no_swap_test("01");
    sim.X(control_qubits[1]);
    // Controls are 11, test for swap
    sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 00 -> 00
    assert_amplitude_equality(sim.probe("1100"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1101"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1110"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1111"), 0.0, 0.0);
    sim.X(target_qubits[0]);
    sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 10 -> 01
    assert_amplitude_equality(sim.probe("1100"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1101"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1110"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1111"), 0.0, 0.0);
    sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]);// 01 -> 10
    assert_amplitude_equality(sim.probe("1100"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1101"), 1.0, 0.0);
    assert_amplitude_equality(sim.probe("1110"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1111"), 0.0, 0.0);
    sim.X(target_qubits[1]);
    sim.CSWAP(control_qubits, target_qubits[0], target_qubits[1]); // 11 -> 11
    assert_amplitude_equality(sim.probe("1100"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1101"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1110"), 0.0, 0.0);
    assert_amplitude_equality(sim.probe("1111"), 1.0, 0.0);
    sim.X(target_qubits[1]);
    sim.X(target_qubits[0]);
    sim.X(control_qubits[0]);
    // Controls are 10, test for no swap
    no_swap_test("10");
}

// Tests measurement probabilistically
// Based on the expected measurement probabilities for a Pauli Y
// rotation
// It samples a lot of measurements, and based on the 
// current variance (of a binomial distrbution):
//  - if it's very close to the expected distribution,
//	  it considers this a success
//  - if it's very far from the expected distribution,
//    it throws an exception
//  - if it's in between, it runs more samples
// While this run-time is undetermined, the threshold
// for an exception shrinks with the number of tests
TEST_CASE("MTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    const int n_tests = 5000;
    const double log_false_positive_threshold = 0.1;
    const double log_false_negative_threshold = 100.0;
    for (double angle = 0.0; angle < M_PI / 2.0; angle += 0.1) {
        SparseSimulator sim = SparseSimulator(num_qubits);
        sim.set_random_seed(12345);
        double expected_ratio = sin(angle / 2.0) * sin(angle / 2.0);
        double ratio = 0.0;
        unsigned long total_tests = 0;
        unsigned long  ones = 0;
        double std_dev = 0.0;
        double log_prob = 0.0;
        logical_qubit_id qubit = 0;
        do {
            for (int i = 0; i < n_tests; i++) {
                sim.R(Gates::Basis::PauliY, angle, qubit);
                if (sim.M(qubit)) {
                    ones++;
                    sim.X(qubit);
                }
            }
            total_tests += n_tests;
            ratio = (double)ones / (double)total_tests;
            double abs_diff = abs(expected_ratio - ratio);
            // Based on Chernoff bounds
            log_prob = abs_diff * abs_diff * expected_ratio * (double)total_tests;
            std_dev = sqrt(expected_ratio * (1.0 - expected_ratio)) / (double)total_tests;
            // Using variance of the binomial distribution
            if (log_false_positive_threshold >= log_prob) {
                break;
            }
        } while (log_false_negative_threshold >= log_prob);
        if (log_false_negative_threshold < log_prob) {
            throw std::runtime_error("Statistically improbable measurement results");
        }
    }

}

// Tests an assortment of assertions to both pass and to throw exceptions
TEST_CASE("AssertTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    using namespace Gates;
    std::vector<Basis> basis{ Basis::PauliZ, Basis::PauliZ, Basis::PauliZ };
    std::vector<logical_qubit_id> qubits{ 0,1,2 };
    sim.Assert(basis, qubits, false);
    sim.update_state();
    // These require forcing the simulator to update the state for it to actually throw the exception
    
    auto sim_assert = [&](std::vector<Basis> const& basis, bool val) {
            sim.Assert(basis, qubits, val);
            sim.update_state();
        };
    REQUIRE_THROWS_AS(sim_assert(basis, true), std::exception);
    
    basis = { Basis::PauliZ, Basis::PauliZ, Basis::PauliI };
    REQUIRE_THROWS_AS(sim_assert(basis, true), std::exception);
    
    basis = { Basis::PauliX, Basis::PauliI, Basis::PauliI };
    REQUIRE_THROWS_AS(sim_assert(basis, false), std::exception);
    REQUIRE_THROWS_AS(sim_assert(basis, true), std::exception);
    
    basis = { Basis::PauliY, Basis::PauliI, Basis::PauliI };
    REQUIRE_THROWS_AS(sim_assert(basis, false), std::exception);
    REQUIRE_THROWS_AS(sim_assert(basis, true), std::exception);
}

// Tests an assortment of assertions on GHZ states
TEST_CASE("AssertGHZTest") {
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    SparseSimulator sim = SparseSimulator(num_qubits);
    using namespace Gates;
    std::vector<Basis> basis(3, Basis::PauliX);
    std::vector<logical_qubit_id> qubits{ 0,1,2 };
    sim.H(0);
    sim.MCX({ 0 }, 1);
    sim.MCX({ 0 }, 2);
    
    sim.Assert(basis, qubits, false);
    REQUIRE_THROWS_AS(sim.Assert(basis, qubits, true), std::exception);
    sim.Z(0);
    sim.Assert(basis, qubits, true);
    REQUIRE_THROWS_AS(sim.Assert(basis, qubits, false), std::exception);
    sim.S(0);
    basis = { Basis::PauliY, Basis::PauliY, Basis::PauliY };
    sim.Assert(basis, qubits, false);
    REQUIRE_THROWS_AS(sim.Assert(basis, qubits, true), std::exception);
    sim.Z(0);
    sim.Assert(basis, qubits, true);
    REQUIRE_THROWS_AS(sim.Assert(basis, qubits, false), std::exception);
    sim.probe("0");
}

// Basic test of quantum teleportation
TEST_CASE("TeleportationTest")
{
    const logical_qubit_id num_qubits = 32;
    const qubit_label_type<num_qubits> zero(0);
    for (double test_angle = 0; test_angle < 1.0; test_angle += 0.34) {
        SparseSimulator sim = SparseSimulator(num_qubits);
        sim.set_random_seed(12345);
        std::vector<logical_qubit_id> qubits{ 0,1,2 };
        sim.H(qubits[1]);
        sim.MCX({ qubits[1] }, qubits[2]);

        sim.R(Gates::Basis::PauliY, test_angle, 0);

        sim.MCX({ qubits[0] }, qubits[1]);
        sim.H(qubits[0]);
        bool result0 = sim.M(qubits[0]);
        bool result1 = sim.M(qubits[1]);
        if (result1) {
            sim.X(qubits[2]);
            sim.X(qubits[1]);
        }
        if (result0) {
            sim.Z(qubits[2]);
            sim.X(qubits[0]);
        }

        amplitude teleported_qubit_0 = sim.probe("000");
        amplitude teleported_qubit_1 = sim.probe("100");
        REQUIRE((float)cos(test_angle / 2.0) == (float)teleported_qubit_0.real());
        REQUIRE((float)0.0 == (float)teleported_qubit_0.imag());
        REQUIRE((float)sin(test_angle / 2.0) == (float)teleported_qubit_1.real());
        REQUIRE((float)0.0 == (float)teleported_qubit_1.imag());
    }
}


// Tests that H gates properly cancel when executed
TEST_CASE("HCancellationTest") {
    const int n_qubits = 128;
    SparseSimulator sim = SparseSimulator(n_qubits);
    sim.set_random_seed(12345);
    std::vector<logical_qubit_id> qubits(n_qubits);
    std::generate(qubits.begin(), qubits.end(), [] { static int i{ 0 }; return i++; });
    size_t buckets = 0;
    // Will cause a huge memory problem if there is no cancellation
    const int n_samples = 16;
    for (int i = 0; i < n_qubits; i += n_samples) {
        for (int ii = 0; ii < n_samples; ii++) {
            sim.H(qubits[i + ii]);
        }
        sim.update_state();
        for (int ii = n_samples - 1; ii >= 0; ii--) {
            sim.H(qubits[i + ii]);
        }
        sim.update_state();
    }
}

// Checks that X and Z gates commute with H
TEST_CASE("HXZCommutationTest") {
    const int n_qubits = 16;
    SparseSimulator sim = SparseSimulator(n_qubits);
    sim.set_random_seed(12345);
    std::vector<logical_qubit_id> qubits(n_qubits);
    std::generate(qubits.begin(), qubits.end(), [] { static int i{ 0 }; return i++; });
    for (int i = 0; i < n_qubits; i++) {
        sim.H(qubits[i]);
    }
    // Here it will actually just commute the X and Z through the H in the queue
    // without actually executing anything
    std::bitset<n_qubits> one_state = 0;
    for (int i = 0; i < n_qubits - 1; i += 2) {
        sim.Z(qubits[i]);
        sim.X(qubits[i + 1]);
        one_state.set(i);
    }
    for (int i = n_qubits - 1; i >= 0; i--) {
        sim.H(qubits[i]);
    }
    for (__int64 i = 0; i < pow(2, n_qubits); i++) {
        amplitude state = sim.probe(std::bitset<n_qubits>(i).to_string());
        if (i == one_state.to_ulong()) {
            assert_amplitude_equality(state, 1.0, 0.0);
        }
        else {
            assert_amplitude_equality(state, 0.0, 0.0);
        }
    }
}
