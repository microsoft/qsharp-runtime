// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/capi.hpp"
#include <cassert>
#include <cmath>
#include <iostream>
#include <vector>
#include <complex>
#include <array>
#include <omp.h>
#include <chrono>

#include "util/cpuid.hpp" //@@@DBG

#include "capi.hpp"

// some convenience functions
void CX(unsigned sim_id, unsigned c, unsigned q)
{
    MCX(sim_id,1,&c,q);
}

void CZ(unsigned sim_id, unsigned c, unsigned q)
{
    MCZ(sim_id,1,&c,q);
}

void Ry(unsigned sim_id, double phi, unsigned q)
{
    R(sim_id,2,phi,q);
}

void CRz(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id,3,phi,1,&c,q);
}

void CRx(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id,1,phi,1,&c,q);
}


void dump(unsigned sim_id, const char* label)
{
    auto dump_callback = [](size_t idx, double r, double i) {
        std::cout << idx << ":\t" << r << '\t' << i << '\n';
        return true;
    };
    auto sim_ids_callback = [](unsigned idx) { std::cout << idx << " "; };

    std::cout << label << "\n" << "wave function for ids (least to most significant): ["; 
    DumpIds(sim_id, sim_ids_callback);
    std::cout << "]\n";
    Dump(sim_id, dump_callback);
}


void test_teleport()
{
    auto sim_id = init();

    unsigned qs[] = { 0, 1, 2 };

    dump(sim_id, "teleport-pre.txt");

    allocateQubit(sim_id, 0);
    allocateQubit(sim_id, 1);

    dump(sim_id, "teleport-start.txt");

    // create a Bell pair
    H(sim_id, 0);
    MCX(sim_id, 1, qs, 1);

    allocateQubit(sim_id, 2);
    // create quantum state
    H(sim_id, 2);
    R(sim_id, 3, 1.1, 2);

    // teleport
    MCX(sim_id, 1, &qs[2], 1);
    H(sim_id, 2);
    M(sim_id, 2);
    M(sim_id, 1);
    MCX(sim_id, 1, &qs[1], 0);
    MCZ(sim_id, 1, &qs[2], 0);

    dump(sim_id, "teleport-middle.txt");

    // check teleportation success
    R(sim_id, 3, (-1.1), 0);
    H(sim_id, 0);
    assert(M(sim_id, 0)==false);

    dump(sim_id, "teleport-end.txt");

    release(sim_id, 0);
    release(sim_id, 1);
    release(sim_id, 2);

    dump(sim_id, "teleport-post.txt");

    destroy(sim_id);
}

void test_gates()
{
    auto sim_id = init();

    allocateQubit(sim_id, 0);
    allocateQubit(sim_id, 1);

     CRx(sim_id, 1.0, 0, 1);

    assert(M(sim_id, 1)==false);

    X(sim_id, 0);
     CRx(sim_id, 1.0, 0, 1);

    H(sim_id, 1);
    CRx(sim_id, -1.0, 0, 1);
    H(sim_id, 1);

    assert(M(sim_id, 1)==false);

    X(sim_id, 1);

    assert(M(sim_id, 1)==true);

    X(sim_id, 1);

    release(sim_id, 0);
    release(sim_id, 1);

    destroy(sim_id);
}


void test_allocate()
{
    auto sim_id = init();

    allocateQubit(sim_id,0);
    allocateQubit(sim_id,1);
    allocateQubit(sim_id,2);
    release(sim_id,1);
    allocateQubit(sim_id,1);

    assert(num_qubits(sim_id) == 3);

    release(sim_id,0);
    release(sim_id,1);
    release(sim_id,2);

    assert(num_qubits(sim_id) == 0);
    destroy(sim_id);

}
/*
// We can't use a lambda with captures to pass to a callback with __stdcall signature,
// so we use a global variable/function for the check_state callback:
using wavefunction_type = std::vector<std::complex<double>>;
wavefunction_type _state;
bool check_state(size_t idx, double r, double i) {
    auto tol = 1e-5;
    if (!((abs(_state[idx].real() - r) <= tol) && (abs(_state[idx].imag() - i) <= tol))) throw 1;
    return true;
}


void test_dump()
{
  auto no_checks = [](size_t idx, double r, double i) { return true; };
  auto sim_id = init();

  unsigned int qs[3];
  qs[0] = 0;
  qs[1] = 1;
  qs[2] = 2;

  allocateQubit(sim_id, 0);
  allocateQubit(sim_id, 1);
  allocateQubit(sim_id, 2);

  // simple check:
  _state = wavefunction_type{ 1., 0., 0., 0., 0., 0., 0., 0. };
  dump(sim_id, "dump-start");
  Dump(sim_id, check_state);

  // Check an invalid state will throw.
  _state = wavefunction_type{ 0., 0., 0., 0., 0., 0., 0., 0. };
  dump(sim_id, "dump-01");
  try {
    Dump(sim_id, check_state);
    assert(false);
  }
  catch (int n) {
      std::cerr << n << std::endl;
    assert(n == 1);
  }

  // change state
  X(sim_id, 0);
  X(sim_id, 1);

  // check dump all returns as expected.
  _state = wavefunction_type{ 0., 0., 0., 1., 0., 0., 0., 0. };
  dump(sim_id, "dump-02");
  Dump(sim_id, check_state);

  // test for a subsystem.
  _state = wavefunction_type{ 0., 1., 0., 0. };
  qs[0] = 1;
  qs[1] = 2;
  assert(sim_DumpQubits(sim_id, 2, qs, check_state));

  // the dumped state should be consistent based on the qubits given.
  _state = wavefunction_type{ 0., 0., 1., 0. };
  qs[0] = 2;
  qs[1] = 1;
  assert(sim_DumpQubits(sim_id, 2, qs, check_state));

  // check that when we ask for a different order of all the qubits, 
  // the corresponding basis state is correct
  _state = wavefunction_type{ 0., 0., 0., 0., 0., 0., 1., 0. };
  qs[0] = 2;
  qs[1] = 1;
  qs[2] = 0;
  assert(sim_DumpQubits(sim_id, 3, qs, check_state));

  // however the overall state should not be affected
  _state = wavefunction_type{ 0., 0., 0., 1., 0., 0., 0., 0. };
  Dump(sim_id, check_state);

  // entangle two qubits:
  H(sim_id, 2);
  qs[0] = 2;
  MCX(sim_id, 1, qs, 1);

  // check entangle worked:
  _state = wavefunction_type{ 0., 0., 0., 0.7071, 0., 0.7071, 0., 0. };
  dump(sim_id, "dump-03");
  Dump(sim_id, check_state);

  // the subsystem of the two entangled qubits should work:
  _state = wavefunction_type{ 0., 0.7071, 0.7071, 0. };
  qs[0] = 1;
  qs[1] = 2;
  assert(sim_DumpQubits(sim_id, 2, qs, check_state));
  // since the qubit is externally entangled, it should return false.
  qs[0] = 0;
  qs[1] = 1;
  assert(sim_DumpQubits(sim_id, 2, qs, no_checks) == false);
  assert(sim_DumpQubits(sim_id, 1, &qs[1], no_checks) == false);

  // all done:
  M(sim_id, 0);
  M(sim_id, 1);
  M(sim_id, 2);

  release(sim_id, 0);
  release(sim_id, 1);
  release(sim_id, 2);

  // check that dump can be called if no more allocated qubits:
  _state = wavefunction_type{ 1., 0. };
  dump(sim_id, "dump-end");
  Dump(sim_id, check_state);

  destroy(sim_id);
}


void test_dump_qubits()
{
    auto sim_id = init();
    constexpr auto num_qubits = 4u;
    auto qs = std::array<unsigned, num_qubits>{};
    for (auto i = 0u; i < qs.size(); ++i) {
        qs[i] = i;
        allocateQubit(sim_id, i);
    }

    // change state
    X(sim_id, 1);
    X(sim_id, 2);

    // check permutations of qubits that should leave the wavefunction invariant
    _state = wavefunction_type{ 0., 0., 0., 0.,
                                0., 0., 1., 0.,
                                0., 0., 0., 0.,
                                0., 0., 0., 0. };
    DumpQubits(sim_id, num_qubits, qs.data(), check_state);
    std::swap(qs[1], qs[2]);
    DumpQubits(sim_id, num_qubits, qs.data(), check_state);
    std::swap(qs[0], qs[3]);
    DumpQubits(sim_id, num_qubits, qs.data(), check_state);
    std::swap(qs[1], qs[2]);
    DumpQubits(sim_id, num_qubits, qs.data(), check_state);

    // all done:
    X(sim_id, 1);
    X(sim_id, 2);

    for (auto i = 0u; i < qs.size(); ++i)
        release(sim_id, i);
    destroy(sim_id);
}

*/

void test_permute_basis()
{
    auto sim_id = init();

    // oracle for |a>|b> -> |a>|a XOR b> on two-qubit registers |a>, |b>
    auto permutation = [](auto index) {
        auto a = index & 3;
        auto b = (index >> 2) & 3;
        return a | (a ^ b) << 2;
    };
    constexpr auto nqubits = 4u;
    constexpr auto nstates = 1ul << nqubits;
    std::size_t table[nstates];
    for (std::size_t i = 0; i < nstates; ++i) {
        table[i] = permutation(i);
    }

    std::vector<unsigned> qbit_ids(nqubits);
    for (unsigned i = 0; i < qbit_ids.size(); ++i)
        qbit_ids[i] = i + 1;

    for (unsigned i = 0; i < nqubits + 1; ++i)
        allocateQubit(sim_id, i);
    // Dump(sim_id, "permute-start.txt");

    // create some quantum state
    H(sim_id, 1);
    CX(sim_id, 1, 2);
    Ry(sim_id, 1.1, 3);
    Ry(sim_id, 2.2, 4);

    // apply permutation - this should be equivalent to CX(sim_id, 0, 2); CX(sim_id, 1, 3);
    PermuteBasis(sim_id, nqubits, qbit_ids.data(), nstates, table);
    // Dump(sim_id, "permute-middle.txt");

    // check uncompute with CX instead of permutation
    CX(sim_id, 2, 4);
    CX(sim_id, 1, 3);
    Ry(sim_id, -2.2, 4);
    Ry(sim_id, -1.1, 3);
    CX(sim_id, 1, 2);
    H(sim_id, 1);

    // Dump(sim_id, "permute-end.txt");
    assert(M(sim_id, 0) == false);
    assert(M(sim_id, 1) == false);
    assert(M(sim_id, 2) == false);
    assert(M(sim_id, 3) == false);
    assert(M(sim_id, 4) == false);

    for (unsigned i = 0; i < nqubits + 1; ++i)
        release(sim_id, i);
    destroy(sim_id);
}

void test_permute_basis_adjoint()
{
    auto sim_id = init();

    // oracle for |a>|b> -> |a>|a XOR b> on two-qubit registers |a>, |b>
    auto permutation = [](auto index) {
        auto a = index & 3;
        auto b = (index >> 2) & 3;
        return a | (a ^ b) << 2;
    };
    constexpr auto nqubits = 4u;
    constexpr auto nstates = 1ul << nqubits;
    std::size_t table[nstates];
    for (std::size_t i = 0; i < nstates; ++i) {
        table[i] = permutation(i);
    }

    std::vector<unsigned> qbit_ids(nqubits);
    for (unsigned i = 0; i < nqubits; ++i)
        qbit_ids[i] = i + 1;

    for (unsigned i = 0; i < nqubits + 1; ++i)
        allocateQubit(sim_id, i);

    // create some quantum state
    H(sim_id, 1);
    CX(sim_id, 1, 2);
    Ry(sim_id, 1.1, 3);
    Ry(sim_id, 2.2, 4);

    // apply permutation - this should be equivalent to CX(sim_id, 0, 2); CX(sim_id, 1, 3);
    PermuteBasis(sim_id, nqubits, qbit_ids.data(), nstates, table);

    // check uncompute with adjoint=true
    AdjPermuteBasis(sim_id, nqubits, qbit_ids.data(), nstates, table);
    Ry(sim_id, -2.2, 4);
    Ry(sim_id, -1.1, 3);
    CX(sim_id, 1, 2);
    H(sim_id, 1);

    assert(M(sim_id, 0) == false);
    assert(M(sim_id, 1) == false);
    assert(M(sim_id, 2) == false);
    assert(M(sim_id, 3) == false);
    assert(M(sim_id, 4) == false);

    for (unsigned i = 0; i < nqubits + 1; ++i)
        release(sim_id, i);
    destroy(sim_id);
}

int main()
{
#if 0 // Original tests
    std::cerr << "Testing allocate\n";
    test_allocate();
    std::cerr << "Testing gates\n";
    test_gates();
    std::cerr << "Testing teleport\n";
    test_teleport();
    std::cerr << "Testing basis state permutation\n";
    test_permute_basis();
    test_permute_basis_adjoint();
    std::cerr << "Testing dump\n";
    // test_dump();
    // test_dump_qubits();
    return 0;
#endif

#if 1 // Simulator timing tests
    printf("@@@DBG max=%d procs=%d thrds=%d\n", omp_get_max_threads(), omp_get_num_procs(), omp_get_num_threads());
    char* envNT = NULL;
    size_t len;
#ifdef _MSC_VER
    errno_t err = _dupenv_s(&envNT, &len, "OMP_NUM_THREADS");
#else
    envNT = getenv("OMP_NUM_THREADS");
#endif
    int fuseLimits[] = {0,1,2,5,10,50,100};
    for (int fuseSpan = 4; fuseSpan < 5; fuseSpan++) { // 1,5
        for (int flIdx = 6; flIdx < 7; flIdx++) { // 0,7
            for (int numThreads = 1; numThreads < 2; numThreads++) { // 1,5
                for (int simTyp = 1; simTyp < 2; simTyp++) { // 1,4
                    if (simTyp == 3 && (!Microsoft::Quantum::haveFMA() || !Microsoft::Quantum::haveAVX2())) continue;
                    if (simTyp == 2 && !Microsoft::Quantum::haveAVX()) continue;

                    if (envNT == NULL) omp_set_num_threads(numThreads);
                    auto sim_id = initDBG(simTyp, fuseSpan, fuseLimits[flIdx]);

                    const int nQs = 15;
                    for (int q = 0; q < nQs; q++) allocateQubit(sim_id, q);

                    std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
                    for (int i = 0; i < 1000000; i++) {
                        for (int dir = 0; dir < 2; dir++) {
                            for (int k = 0; k < 5; k++) {
                                unsigned c = k;
                                if (dir == 1) c = (nQs - 1) - k;
                                for (int j = 0; j < 5; j++) {
                                    if (k == 0) H(sim_id, c);
                                    else        MCX(sim_id, 1, &c, c - 1);
                                }
                            }
                        }

                        std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
                        std::chrono::duration<double> elapsed = curr - start;
                        if (elapsed.count() >= 40.0) break;
                    }

                    destroy(sim_id);
                }
                if (envNT != NULL) break;
            }
        }
    }
#endif

#if 0 // OpenMP test
    double thrd1elapsed = 1.0;
    for (int thrds = 1; thrds < 9; thrds++) {
        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
        omp_set_num_threads(thrds);
        double rslts[8] = { 0,0,0,0,0,0,0,0 };
        int outer = 800000;
        int inner = 2000;
        #pragma omp parallel for schedule(static,outer/100)
        for (int i = 0; i < outer; i++) {
            double x = 1.0;
            for (int j = 0; j < inner; j++) x += sqrt((double)j);
            rslts[omp_get_thread_num()] += x;
        }
        std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
        std::chrono::duration<double> elapsed = curr - start;
        double elap = elapsed.count();
        if (thrds == 1) thrd1elapsed = elap;
        printf("@@@DBG threads: %d Elapsed: %.2f Factor: %.2f\n", thrds, elap, thrd1elapsed/elap);
    }
#endif
}
