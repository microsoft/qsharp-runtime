// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/simulator.hpp"
#include "util/bititerator.hpp"
#include "util/bitops.hpp"

#include <cmath>

using namespace Microsoft::Quantum::SIMULATOR;

namespace Microsoft {
    namespace Quantum {
        int dbgFusedSpan = 4; //@@@DBG
        int dbgFusedLimit = 99;
        int dbgNumThreads = 0;
        int dbgReorder = 0;
    }
}
void test_exp()
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
    for (auto q : qs) {
        bool m = sim.M(q);
        assert(!m);
    }

    sim.release(qs);
}

void test_teleport()
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
    
    assert(sim.M(q1)==false);

    sim.release(q1);
    sim.release(q2);
    sim.release(q3);
}

void test_gates()
{
    SimulatorType sim;

    auto q1 = sim.allocate();
    auto q2 = sim.allocate();

    sim.CRx(1.0, q1, q2);

    assert(sim.M(q2)==false);

    sim.X(q1);
    sim.CRx(1.0, q1, q2);
    assert(!sim.isclassical(q2));

    sim.H(q2);
    sim.CRz(-1.0, q1, q2);
    sim.H(q2);

    assert(sim.M(q2)==false);

    sim.X(q2);

    assert(sim.M(q2)==true);

    sim.X(q2);

    sim.release(q1);
    sim.release(q2);
}


void test_allocate()
{
    SimulatorType sim;

    auto const q1 = sim.allocate();
    auto q2 = sim.allocate();
    assert(q1 == 0);
    assert(sim.qubit(q1) == 0);
    assert(q2 == 1);
    assert(sim.qubit(q2) == 1);

    auto q3 = sim.allocate();
    assert(q3 == 2);
    assert(sim.qubit(q3) == 2);

    sim.release(q2);
    assert(sim.qubit(q1) == 0);
    assert(sim.qubit(q3) == 1);

    q2 = sim.allocate();
    assert(q2 == 1);
    assert(sim.qubit(q2) == 2);

    assert(sim.num_qubits() == 3);

    sim.release(q1);
    sim.release(q2);
    sim.release(q3);
  
    assert(sim.num_qubits() == 0);

}

template <class SIM>
void set(SIM& sim, bool val, unsigned qubit)
{
    bool is = sim.M(qubit);
    if (val != is)
        sim.X(qubit);
}

void test_multicontrol()
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
                set(sim,((i & (1 << j)) != 0), ctrls[j]);

            // controlled is enabled only when all ctrls are 1 (e.g. last one):
            unsigned enabled = (i == ((1 << n) - 1));
            set(sim,0, q);
            assert(sim.M(q) == 0);

            sim.CX(ctrls, q);
            assert(sim.M(q) == (enabled ? 1 : 0));
        }

        sim.release(qbits);
        sim.release(ctrls);

        assert(sim.num_qubits() == 0);
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
                assert(std::norm(res[0] * std::conj(s2) + res[1] * std::conj(is2)) > 1 - tol * tol);
            }
            else
            {
                assert(std::norm(res[0]) > 1 - tol * tol);
            }
            assert(issep);
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
    assert(abs(norm(wfn[0]) - 0.5) < tol);
    assert(abs(norm(wfn[(1ull << total_qubits) - 1]) - 0.5) < tol);
    assert(norm(wfn[(1ull << total_qubits) - 1] / wfn[0] - std::complex<double>(1, 0)) < tol * tol);
}

void test_extract_qubits_cat_state(unsigned qubits_number,
                                   std::vector<unsigned> const& subset,
                                   std::vector<unsigned> const& negative_test)
{
    SimulatorType sim;
    double tol = 1e-5;

    assert(subset.size() >= 2);
    assert(qubits_number - subset.size() >= 2);

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

    assert(issep1);
    assert(issep2);
    assert(!issep3);
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

void test_extract_qubits_state()
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

int main()
{
    std::cerr << "Testing allocate\n";
    test_allocate();
    std::cerr << "Testing gates\n";
    test_gates();
    std::cerr << "Testing Exp\n";
    test_exp();
    std::cerr << "Testing Multicontrol\n";
    test_multicontrol();
    std::cerr << "Testing teleport\n";
    test_teleport();
    std::cerr << "Testing state extraction\n";
    test_extract_qubits_state();
    return 0;
}
