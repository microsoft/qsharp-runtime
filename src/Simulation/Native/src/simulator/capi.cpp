// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/capi.hpp"
#include "simulator/factory.hpp"
#include "simulator/simulator.hpp"
using namespace Microsoft::Quantum::Simulator;

extern "C"
{

    // init and cleanup
    MICROSOFT_QUANTUM_DECL unsigned init()
    {
        return Microsoft::Quantum::Simulator::create();
    }

    MICROSOFT_QUANTUM_DECL void destroy(_In_ unsigned id)
    {
        Microsoft::Quantum::Simulator::destroy(id);
    }

    MICROSOFT_QUANTUM_DECL void seed(_In_ unsigned id, _In_ unsigned s)
    {
        Microsoft::Quantum::Simulator::get(id)->seed(s);
    }

    // non-quantum
    MICROSOFT_QUANTUM_DECL std::size_t random_choice(_In_ unsigned id, _In_ std::size_t n, _In_reads_(n) double* p)
    {
        return Microsoft::Quantum::Simulator::get(id)->random(n, p);
    }

    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) int* b,
        _In_reads_(n) unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        return Microsoft::Quantum::Simulator::get(id)->JointEnsembleProbability(bv, qv);
    }

    MICROSOFT_QUANTUM_DECL void allocateQubit(_In_ unsigned id, _In_ unsigned q)
    {
        Microsoft::Quantum::Simulator::get(id)->allocateQubit(q);
    }

    MICROSOFT_QUANTUM_DECL void release(_In_ unsigned id, _In_ unsigned q)
    {
        Microsoft::Quantum::Simulator::get(id)->release(q);
    }

    MICROSOFT_QUANTUM_DECL unsigned num_qubits(_In_ unsigned id)
    {
        return Microsoft::Quantum::Simulator::get(id)->num_qubits();
    }

#define FWDGATE1(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G(_In_ unsigned id, _In_ unsigned q)                                                   \
    {                                                                                                                  \
        Microsoft::Quantum::Simulator::get(id)->G(q);                                                                  \
    }
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G(_In_ unsigned id, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q)   \
    {                                                                                                                  \
        std::vector<unsigned> vc(c, c + n);                                                                            \
        Microsoft::Quantum::Simulator::get(id)->C##G(vc, q);                                                           \
    }
#define FWD(G) FWDGATE1(G) FWDCSGATE1(G)

    // single-qubit gates
    FWD(X)
    FWD(Y)
    FWD(Z)
    FWD(H)
    FWD(S)
    FWD(T)
    FWD(AdjS)
    FWD(AdjT)

#undef FWDGATE1
#undef FWDGATE2
#undef FWDGATE3
#undef FWDCSGATE1
#undef FWD

    // rotations

    MICROSOFT_QUANTUM_DECL void R(_In_ unsigned id, _In_ unsigned b, _In_ double phi, _In_ unsigned q)
    {
        Microsoft::Quantum::Simulator::get(id)->R(static_cast<Gates::Basis>(b), phi, q);
    }

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR(
        _In_ unsigned id,
        _In_ unsigned b,
        _In_ double phi,
        _In_ unsigned nc,
        _In_reads_(nc) unsigned* c,
        _In_ unsigned q)
    {
        std::vector<unsigned> cv(c, c + nc);
        Microsoft::Quantum::Simulator::get(id)->CR(static_cast<Gates::Basis>(b), phi, cv, q);
    }

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_reads_(n) unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->Exp(bv, phi, qv);
    }
    MICROSOFT_QUANTUM_DECL void MCExp(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_ unsigned nc,
        _In_reads_(nc) unsigned* c,
        _In_reads_(n) unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        std::vector<unsigned> cv(c, c + nc);
        Microsoft::Quantum::Simulator::get(id)->CExp(bv, phi, cv, qv);
    }

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M(_In_ unsigned id, _In_ unsigned q)
    {
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->M(q);
    }
    MICROSOFT_QUANTUM_DECL unsigned Measure(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_reads_(n) unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->Measure(bv, qv);
    }

    // apply permutation of basis states to the wave function
    MICROSOFT_QUANTUM_DECL void PermuteBasis(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ std::size_t table_size,
        _In_reads_(table_size) std::size_t* permutation_table)
    {
        const std::vector<unsigned> qs(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, false);
    }
    MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ std::size_t table_size,
        _In_reads_(table_size) std::size_t* permutation_table)
    {
        const std::vector<unsigned> qs(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, true);
    }

    // dump wavefunction to given callback until callback returns false
    MICROSOFT_QUANTUM_DECL void Dump(_In_ unsigned id, _In_ bool (*callback)(size_t, double, double))
    {
        Microsoft::Quantum::Simulator::get(id)->dump(callback);
    }

    // dump the wavefunction of the subset of qubits to the given callback returns false
    MICROSOFT_QUANTUM_DECL bool DumpQubits(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ bool (*callback)(size_t, double, double))
    {
        std::vector<unsigned> qs(q, q + n);
        return Microsoft::Quantum::Simulator::get(id)->dumpQubits(qs, callback);
    }

    // dump the list of logical qubit ids to given callback
    MICROSOFT_QUANTUM_DECL void DumpIds(_In_ unsigned id, _In_ void (*callback)(unsigned))
    {
        Microsoft::Quantum::Simulator::get(id)->dumpIds(callback);
    }
}
