// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "catch.hpp"

#include "simulator/simulator.hpp"
#include "util/bititerator.hpp"
#include "util/bitops.hpp"

#include <bitset>
#include <chrono>
#include <cmath>

using namespace Microsoft::Quantum::SIMULATOR;

TEST_CASE("test_exp", "[local_test]")
{
    SimulatorType sim;

    // prepare a test state
    auto qs = sim.allocate(4);
    for (auto q : qs)
        sim.H(q);

    // apply the Exp gate
    std::vector<Gates::Basis> bs = {
        Gates::Basis::PauliZ, Gates::Basis::PauliX, Gates::Basis::PauliY, Gates::Basis::PauliZ};

    sim.Exp(bs, 1.1, qs);

    // undo the Exp gate manually
    sim.H(qs[1]);
    sim.AdjHY(qs[2]);
    for (unsigned i = 0; i < 3; ++i)
        sim.CX(qs[i], qs[i + 1]);
    sim.Rz(2.2, qs[3]);
    for (unsigned i = 3; i > 0; --i)
        sim.CX(qs[i - 1], qs[i]);
    sim.HY(qs[2]);
    sim.H(qs[1]);

    // undo the preparation
    for (auto q : qs)
        sim.H(q);

    // measure and test
    for (auto q : qs)
    {
        bool m = sim.M(q);
        CHECK(!m);
    }

    sim.release(qs);
}

TEST_CASE("test_teleport", "[local_test]")
{
    SimulatorType sim;

    auto q1 = sim.allocate();
    auto q2 = sim.allocate();

    // create a Bell pair
    sim.H(q1);
    sim.CX(q1, q2);

    auto q3 = sim.allocate();
    // create quantum state
    sim.H(q3);
    sim.Rz(1.1, q3);

    // teleport
    sim.CX(q3, q2);
    sim.H(q3);
    sim.M(q3);
    sim.M(q2);
    sim.CX(q2, q1);
    sim.CZ(q3, q1);

    // check teleportation success
    sim.Rz((-1.1), q1);
    sim.H(q1);

    CHECK_FALSE(sim.M(q1));

    sim.release(q1);
    sim.release(q2);
    sim.release(q3);
}

TEST_CASE("test_gates", "[local_test]")
{
    SimulatorType sim;

    auto q1 = sim.allocate();
    auto q2 = sim.allocate();

    sim.CRx(1.0, q1, q2);

    CHECK_FALSE(sim.M(q2));

    sim.X(q1);
    sim.CRx(1.0, q1, q2);
    CHECK_FALSE(sim.isclassical(q2));

    sim.H(q2);
    sim.CRz(-1.0, q1, q2);
    sim.H(q2);

    CHECK_FALSE(sim.M(q2));

    sim.X(q2);

    CHECK(sim.M(q2));

    sim.X(q2);

    sim.release(q1);
    sim.release(q2);
}

TEST_CASE("test_allocate", "[local_test]")
{
    SimulatorType sim;

    auto const q1 = sim.allocate();
    auto q2 = sim.allocate();
    CHECK(q1 == 0);
    CHECK(q2 == 1);

    auto q3 = sim.allocate();
    CHECK(q3 == 2);

    sim.release(q2);
    q2 = sim.allocate();
    CHECK(q2 == 1);

    CHECK(sim.num_qubits() == 3);

    sim.release(q1);
    sim.release(q2);
    sim.release(q3);

    CHECK(sim.num_qubits() == 0);
}

// This test is poking at the implementation detail of the wave function store and might not be the best idea as the
// positions of qubits aren't guaranteed to be maintained in specific order and can be optimized by the wave function as
// it sees fit. However, for simple allocate/release pattern the test is useful to document the difference between
// logical and positional qubit ids.
TEST_CASE("Logical vs positional qubit ids", "[local_test]")
{
    Wavefunction<ComplexType> psi;

    logical_qubit_id q1 = psi.allocate_qubit();
    logical_qubit_id q2 = psi.allocate_qubit();
    REQUIRE(q1 == 0);
    REQUIRE(psi.get_qubit_position(q1) == 0);
    REQUIRE(q2 == 1);
    REQUIRE(psi.get_qubit_position(q2) == 1);

    logical_qubit_id q3 = psi.allocate_qubit();
    REQUIRE(q3 == 2);
    REQUIRE(psi.get_qubit_position(q3) == 2);

    // After release the qubits after the released one should be compacted forward.
    psi.release(q2);
    REQUIRE(psi.get_qubit_position(q1) == 0);
    REQUIRE(psi.get_qubit_position(q3) == 1);

    // We expect the released id to be reused but the position of the new qubit to be at the end.
    q2 = psi.allocate_qubit();
    REQUIRE(q2 == 1);
    REQUIRE(psi.get_qubit_position(q2) == 2);

    REQUIRE(psi.num_qubits() == 3);

    psi.release(q1);
    psi.release(q2);
    psi.release(q3);

    REQUIRE(psi.num_qubits() == 0);
}

TEST_CASE("Clustering", "[local_test]")
{
    TinyMatrix<ComplexType, 2> ignore;
    const int unlimited = 99;

    DeferredGate g_n_1({} /*controls*/, 1 /*target*/, ignore);
    DeferredGate g_n_2({} /*controls*/, 2 /*target*/, ignore);
    DeferredGate g_n_3({} /*controls*/, 3 /*target*/, ignore);
    DeferredGate g_n_4({} /*controls*/, 4 /*target*/, ignore);
    DeferredGate g_1_2({1} /*controls*/, 2 /*target*/, ignore);
    DeferredGate g_1_3({1} /*controls*/, 3 /*target*/, ignore);
    DeferredGate g_2_3({2} /*controls*/, 3 /*target*/, ignore);
    DeferredGate g_3_4({3} /*controls*/, 4 /*target*/, ignore);

    SECTION("Single qubit gates only") // {X(q1), Y(q1), X(q2), Z(q1), Y(q2)}
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_1, g_n_2, g_n_1, g_n_2};
        auto cls = Cluster::make_clusters(1 /*cluster qubit width*/, unlimited /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 2);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1});
        CHECK(it->get_gates().size() == 3);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{2});
        CHECK(it->get_gates().size() == 2);
    }

    SECTION("CNOT as barrier") // {X(q1), Y(q1), CNOT(q1, q2), Z(q1)}
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_1, g_1_2, g_n_1};
        auto cls = Cluster::make_clusters(1 /*cluster qubit width*/, unlimited /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 3);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1});
        CHECK(it->get_gates().size() == 2);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 2});
        CHECK(it->get_gates().size() == 1);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1});
        CHECK(it->get_gates().size() == 1);
    }

    SECTION("Pull gate through a CNOT (width 1)") // X(q1), X(q2), CNOT(q2, q3), Y(q1)
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_2, g_2_3, g_n_1};
        auto cls = Cluster::make_clusters(2 /*cluster qubit width*/, unlimited /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 2);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 2});
        CHECK(it->get_gates().size() == 3);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{2, 3});
        CHECK(it->get_gates().size() == 1);
    }

    // X(q1), X(q2), CNOT(q2, q3), Y(q2), X(q3), Y(q1)
    // Our clustering algorithm starts by clustering at width 1, which allows to combine Y(q1) and X(q1):
    // {X(q1), Y(q1)}, {X(q2)}, {CNOT(q2, q3)}, {Y(q2)}, {X(q3)}
    // The next step would create clusters of width 2:
    // {X(q1), Y(q1), X(q2)}, {CNOT(q2, q3), Y(q2), X(q3)}
    SECTION("Pull gate through a CNOT (width 2)")
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_2, g_2_3, g_n_2, g_n_3, g_n_1};
        auto cls = Cluster::make_clusters(2 /*cluster qubit width*/, unlimited /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 2);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 2});
        CHECK(it->get_gates().size() == 3);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{2, 3});
        CHECK(it->get_gates().size() == 3);
    }

    // X(q1), X(q2), X(q3), CNOT(q1, q2), CNOT(q1, q3), Y(q1), Y(q2), Y(q3)
    // For width 2 clustering our algorithm gets:
    // {X(q1), X(q2), CNOT(q1, q2)}, {X(q3), CNOT(q1, q3), Y(q1), Y(q3)}, {Y(q2)}
    // !and not this one: {X(q1), X(q2), CNOT(q1, q2), Y(q2)}, {X(q3), CNOT(q1, q3), Y(q1), Y(q3)} (because CNOT(q1, q3)
    // cannot be merged into the first cluster and terminates it, preventing addition of Y(q2))
    SECTION("Many CNOT gates")
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_2, g_n_3, g_1_2, g_1_3, g_n_1, g_n_2, g_n_3};
        auto cls = Cluster::make_clusters(2 /*cluster qubit width*/, unlimited /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 3);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 2});
        CHECK(it->get_gates().size() == 3);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 3});
        CHECK(it->get_gates().size() == 4);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{2});
        CHECK(it->get_gates().size() == 1);
    }

    SECTION("Fusion limit on single qubit")
    {
        std::vector<DeferredGate> gates{g_n_1, g_n_1, g_n_1, g_n_1};
        auto cls = Cluster::make_clusters(1 /*cluster qubit width*/, 2 /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 2);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1});
        CHECK(it->get_gates().size() == 2);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1});
        CHECK(it->get_gates().size() == 2);
    }

    SECTION("Fusion limit on multiple qubits")
    {
        std::vector<DeferredGate> gates{g_n_1, g_1_2, g_3_4, g_n_3};
        auto cls = Cluster::make_clusters(unlimited /*cluster qubit width*/, 2 /*gates per cluster*/, gates);
        REQUIRE(cls.size() == 2);

        auto it = cls.begin();
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{1, 2});
        CHECK(it->get_gates().size() == 2);

        ++it;
        CHECK(it->get_qids() == std::vector<logical_qubit_id>{3, 4});
        CHECK(it->get_gates().size() == 2);
    }
}

TEST_CASE("isclassical", "[local_test")
{
    SimulatorType sim;
    constexpr int n = 2;
    logical_qubit_id q1 = sim.allocate();
    logical_qubit_id q2 = sim.allocate();

    CHECK(sim.isclassical(q1));
    CHECK(sim.isclassical(q2));

    sim.H(q1);
    sim.X(q2);
    CHECK_FALSE(sim.isclassical(q1));
    CHECK(sim.isclassical(q2));

    sim.CX({q1}, q2);
    CHECK_FALSE(sim.isclassical(q1));
    CHECK_FALSE(sim.isclassical(q2));
}

void CheckAllZeros(SimulatorType& sim, const std::vector<logical_qubit_id>& qs)
{
    for (size_t i = 0; i < qs.size(); i++)
    {
        INFO(std::string("qubit in non-zero state: ") + std::to_string(qs[i]));
        CHECK((sim.isclassical(qs[i]) && !sim.M(qs[i])));
    }
}

TEST_CASE("Inject total cat state", "[local_test]")
{
    SimulatorType sim;
    constexpr int n = 2;
    constexpr size_t N = (static_cast<size_t>(1) << n);

    std::vector<logical_qubit_id> qs;
    for (int i = 0; i < n; i++)
    {
        qs.push_back(sim.allocate());
    }

    const double amp = 1.0 / std::sqrt(n);
    std::vector<ComplexType> amplitudes = {{amp, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {amp, 0.0}};
    REQUIRE(amplitudes.size() == N);

    sim.InjectState(qs, amplitudes);

    // undo the injected state back to |00>
    sim.CX({qs[0]}, qs[1]);
    sim.H(qs[0]);
    CheckAllZeros(sim, qs);
}

TEST_CASE("Should fail to inject state if qubits aren't all |0>", "[local_test]")
{
    SimulatorType sim;
    constexpr int n = 3;

    std::vector<logical_qubit_id> qs;
    for (int i = 0; i < n; i++)
    {
        qs.push_back(sim.allocate());
    }

    const double amp = 1.0 / std::sqrt(n);
    std::vector<ComplexType> amplitudes = {{0.0, 0.0}, {amp, 0.0}, {amp, 0.0}, {0.0, 0.0},
                                           {amp, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}};

    std::vector<ComplexType> amplitudes_sub = {{amp, 0.0}, {amp, 0.0}, {amp, 0.0}, {0.0, 0.0}};

    // unentangled but not |0>
    sim.H(qs[1]);
    REQUIRE_THROWS(sim.InjectState(qs, amplitudes));
    REQUIRE_THROWS(sim.InjectState({qs[0], qs[1]}, amplitudes_sub));

    // entanglement doesn't make things any better
    sim.CX({qs[1]}, qs[2]);
    REQUIRE_THROWS(sim.InjectState(qs, amplitudes));
    REQUIRE_THROWS(sim.InjectState({qs[0], qs[1]}, amplitudes_sub));
}

TEST_CASE("Inject total state on reordered qubits", "[local_test]")
{
    SimulatorType sim;
    constexpr int n = 3;
    constexpr size_t N = (static_cast<size_t>(1) << n);

    std::vector<logical_qubit_id> qs;
    for (int i = 0; i < n; i++)
    {
        qs.push_back(sim.allocate());
    }

    const double amp = 1.0 / std::sqrt(2);
    std::vector<ComplexType> amplitudes = {{amp, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {amp, 0.0},
                                           {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}};
    REQUIRE(N == amplitudes.size());

    // Notice, that we are listing the qubits in order that doesn't match their allocation order. We are saying here,
    // that InjectState should create Bell pair from qs[1] and qs[2]!
    sim.InjectState({qs[1], qs[2], qs[0]}, amplitudes);
    REQUIRE((sim.isclassical(qs[0]) && !sim.M(qs[0])));

    // undo the state change and check that the whole system is back to |000>
    sim.CX({qs[1]}, qs[2]);
    sim.H(qs[1]);
    for (int i = 0; i < n; i++)
    {
        INFO(std::string("qubit in non-zero state: ") + std::to_string(qs[i]));
        CHECK((sim.isclassical(qs[i]) && !sim.M(qs[i])));
    }
}

TEST_CASE("Inject state on two qubits out of three", "[local_test]")
{
    SimulatorType sim;
    constexpr int n = 3;

    logical_qubit_id q0 = sim.allocate();
    logical_qubit_id q1 = sim.allocate();
    logical_qubit_id q2 = sim.allocate();

    const double amp = 1.0 / std::sqrt(2);
    std::vector<ComplexType> amplitudes = {{amp, 0.0}, {amp, 0.0}, {0.0, 0.0}, {0.0, 0.0}};
    // this state injections is the same as applying H to the first qubit in the subsystem list

    logical_qubit_id x;
    logical_qubit_id y;
    SECTION("q0 & q1")
    {
        x = q0;
        y = q1;
        sim.H(q2);
    }
    SECTION("q0 & q2")
    {
        x = q0;
        y = q2;
        sim.H(q1);
    }
    SECTION("q1 & q2")
    {
        x = q1;
        y = q2;
        sim.H(q0);
    }
    SECTION("q2 & q1")
    {
        x = q2;
        y = q1;
        sim.H(q0);
    }

    sim.InjectState({x, y}, amplitudes);

    // undo the state injection with quantum op and check that the qubits we injected state for are back to |0>
    sim.H(x);

    CHECK((sim.isclassical(x) && !sim.M(x)));
    CHECK((sim.isclassical(y) && !sim.M(y)));
}

TEST_CASE("Perf of injecting equal superposition state", "[micro_benchmark]")
{
    using namespace std::chrono;

    SimulatorType sim;
    constexpr int n = 20;
    std::vector<logical_qubit_id> qs;
    for (int i = 0; i < n - 1; i++)
    {
        qs.push_back(sim.allocate());
    }

    SECTION("Prepare the state with quantum operations")
    {
        qs.push_back(sim.allocate());

        auto start = high_resolution_clock::now();
        for (logical_qubit_id q : qs)
        {
            sim.H(q);
        }
        std::cout << "Quantum state preparation:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;
    }

    SECTION("Inject total state")
    {
        qs.push_back(sim.allocate());
        constexpr size_t N = (static_cast<size_t>(1) << n);
        const double amp = 1.0 / std::sqrt(N);
        std::vector<ComplexType> amplitudes(N, {amp, 0.0});

        auto start = high_resolution_clock::now();
        sim.InjectState(qs, amplitudes);
        std::cout << "    Total state injection:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;
    }

    SECTION("Inject partial state")
    {
        logical_qubit_id q_last = sim.allocate();
        constexpr size_t N = (static_cast<size_t>(1) << (n - 1));
        const double amp = 1.0 / std::sqrt(N);
        std::vector<ComplexType> amplitudes(N, {amp, 0.0});

        auto start = std::chrono::high_resolution_clock::now();
        sim.InjectState(qs, amplitudes);
        sim.H(q_last);
        std::cout << "  Partial state injection:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;

        // for the revert check to be uniform
        qs.push_back(q_last);
    }

    // revert back to |0...0> state using quantum operations (to confirm the state injection above is correct)
    for (logical_qubit_id q : qs)
    {
        sim.H(q);
    }
    for (logical_qubit_id q : qs)
    {
        CHECK((sim.isclassical(q) && !sim.M(q)));
    }
}

TEST_CASE("Perf of injecting cat state", "[micro_benchmark]")
{
    using namespace std::chrono;

    SimulatorType sim;
    constexpr int n = 20;
    std::vector<logical_qubit_id> qs;
    for (int i = 0; i < n - 1; i++)
    {
        qs.push_back(sim.allocate());
    }

    SECTION("Prepare the state with quantum operations")
    {
        qs.push_back(sim.allocate());

        auto start = std::chrono::high_resolution_clock::now();
        sim.H(qs[0]);
        for (size_t i = 1; i < n; i++)
        {
            sim.CX({qs[0]}, qs[i]);
        }
        std::cout << "Quantum cat state preparation:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;
    }

    SECTION("Inject total state")
    {
        qs.push_back(sim.allocate());
        constexpr size_t N = (static_cast<size_t>(1) << n);

        std::vector<ComplexType> amplitudes(N, {0.0, 0.0});
        const double amp = 1.0 / std::sqrt(2);
        amplitudes[0] = {amp, 0.0};
        amplitudes[N - 1] = {amp, 0.0};

        auto start = std::chrono::high_resolution_clock::now();
        sim.InjectState(qs, amplitudes);
        std::cout << "    Total cat state injection:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;
    }

    SECTION("Inject partial state")
    {
        logical_qubit_id q_last = sim.allocate();
        constexpr size_t N = (static_cast<size_t>(1) << (n - 1));
        std::vector<ComplexType> amplitudes(N, {0.0, 0.0});
        const double amp = 1.0 / std::sqrt(2);
        amplitudes[0] = {amp, 0.0};
        amplitudes[N - 1] = {amp, 0.0};

        auto start = std::chrono::high_resolution_clock::now();
        sim.InjectState(qs, amplitudes);
        sim.CX({qs[0]}, q_last);
        std::cout << "  Partial cat state injection:\t";
        std::cout << duration_cast<microseconds>(high_resolution_clock::now() - start).count();
        std::cout << std::endl;

        // for the revert check to be uniform
        qs.push_back(q_last);
    }

    // revert back to |0...0> state using quantum operations (to confirm the state injection above is correct)
    for (size_t i = 1; i < n; i++)
    {
        sim.CX({qs[0]}, qs[i]);
    }
    sim.H(qs[0]);
    for (logical_qubit_id q : qs)
    {
        CHECK((sim.isclassical(q) && !sim.M(q)));
    }
}

template <class SIM>
void set(SIM& sim, bool val, unsigned qubit)
{
    bool is = sim.M(qubit);
    if (val != is) sim.X(qubit);
}

TEST_CASE("test_multicontrol", "[local_test]")
{
    SimulatorType sim;
    for (unsigned n = 0; n < 4; ++n)
    {

        auto qbits = sim.allocate(1);
        auto ctrls = sim.allocate(n);

        auto q = qbits[0];

        // Iterate through all possible combinations of ctrl values:
        for (unsigned i = 0; i < (1u << n); i++)
        {
            // set control bits to match i:
            for (unsigned j = 0; j < n; j++)
                set(sim, ((i & (1 << j)) != 0), ctrls[j]);

            // controlled is enabled only when all ctrls are 1 (e.g. last one):
            bool enabled = (i == ((1 << n) - 1));
            set(sim, 0, q);
            CHECK_FALSE(sim.M(q));

            sim.CX(ctrls, q);
            CHECK(sim.M(q) == enabled);
        }

        sim.release(qbits);
        sim.release(ctrls);

        CHECK(sim.num_qubits() == 0);
    }
}

void test_extract_qubits_state_simple(int qubits_number)
{
    SimulatorType sim;
    auto const q1 = sim.allocate(qubits_number);

    // make sure we non-trivial a global phase
    sim.X(q1[0]);
    sim.S(q1[0]);
    sim.X(q1[0]);

    std::vector<unsigned> qubits{0};
    double tol = 1e-5;
    WavefunctionStorage res(1ull << qubits.size());

    for (size_t k = 0; k < 1ull << qubits_number; ++k)
    {
        std::bitset<64> bits(k);
        for (size_t j = 0; j < qubits_number; ++j)
        {
            if (bits[j])
            {
                sim.HY(q1[j]);
            }
        }

        for (int i = 0; i < qubits_number; ++i)
        {
            qubits[0] = i;
            bool issep = sim.subsytemwavefunction(qubits, res, tol);
            auto s2 = std::complex<double>(1.0 / sqrt(2.0));
            auto is2 = std::complex<double>(0, 1.0 / sqrt(2.0));
            if (bits[i])
            {
                CHECK(std::norm(res[0] * std::conj(s2) + res[1] * std::conj(is2)) > 1 - tol * tol);
            }
            else
            {
                CHECK(std::norm(res[0]) > 1 - tol * tol);
            }
            CHECK(issep);
        }

        for (size_t j = 0; j < qubits_number; ++j)
        {
            if (bits[j])
            {
                sim.AdjHY(q1[j]);
            }
        }
    }

    sim.release(q1);
}

void assert_cat_state(WavefunctionStorage const& wfn, double tol)
{
    std::size_t total_qubits = Microsoft::Quantum::ilog2(wfn.size());
    CHECK(abs(norm(wfn[0]) - 0.5) < tol);
    CHECK(abs(norm(wfn[(1ull << total_qubits) - 1]) - 0.5) < tol);
    CHECK(norm(wfn[(1ull << total_qubits) - 1] / wfn[0] - std::complex<double>(1, 0)) < tol * tol);
}

void test_extract_qubits_cat_state(
    unsigned qubits_number,
    std::vector<unsigned> const& subset,
    std::vector<unsigned> const& negative_test)
{
    SimulatorType sim;
    double tol = 1e-5;

    CHECK(subset.size() >= 2);
    CHECK(qubits_number - subset.size() >= 2);

    auto const q1 = sim.allocate(qubits_number);

    sim.H(q1[subset[0]]);
    for (int i = 1; i < subset.size(); ++i)
    {
        sim.CX(q1[subset[0]], q1[subset[i]]);
    }

    auto cmpl = Microsoft::Quantum::complement(subset, qubits_number);

    sim.H(q1[cmpl[0]]);
    for (int i = 1; i < cmpl.size(); ++i)
    {
        sim.CX(q1[cmpl[0]], q1[cmpl[i]]);
    }

    WavefunctionStorage wfn1(1ull << subset.size());
    WavefunctionStorage wfn2(1ull << cmpl.size());
    WavefunctionStorage wfn3(1ull << negative_test.size());

    bool issep1 = sim.subsytemwavefunction(subset, wfn1, tol);
    bool issep2 = sim.subsytemwavefunction(cmpl, wfn2, tol);
    bool issep3 = sim.subsytemwavefunction(negative_test, wfn3, tol);

    CHECK(issep1);
    CHECK(issep2);
    CHECK(!issep3);
    assert_cat_state(wfn1, tol);
    assert_cat_state(wfn2, tol);

    // return all qubits to zero state
    bool res = sim.M(q1[subset[0]]);
    if (res)
    {
        for (int i = 0; i < subset.size(); ++i)
        {
            sim.X(q1[subset[i]]);
        }
    }

    bool res_compl = sim.M(q1[cmpl[0]]);
    if (res_compl)
    {
        for (int i = 0; i < cmpl.size(); ++i)
        {
            sim.X(q1[cmpl[i]]);
        }
    }

    sim.release(q1);
}

TEST_CASE("test_extract_qubits_state", "[local_test]")
{
    test_extract_qubits_state_simple(5);
    test_extract_qubits_cat_state(4, {0, 1}, {0, 2});
    test_extract_qubits_cat_state(4, {0, 2}, {0, 3});
    test_extract_qubits_cat_state(4, {0, 3}, {0, 1});
    test_extract_qubits_cat_state(4, {1, 2}, {1, 3});
    test_extract_qubits_cat_state(4, {1, 3}, {0, 1});
    test_extract_qubits_cat_state(4, {2, 3}, {1, 2});
    test_extract_qubits_cat_state(12, {2, 4, 5, 6, 7}, {0, 1, 2});
    test_extract_qubits_cat_state(6, {0, 1, 3}, {0, 1});
    test_extract_qubits_cat_state(10, {0, 5}, {5, 6});
}
