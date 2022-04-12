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

    MICROSOFT_QUANTUM_DECL void destroy(unsigned id)
    {
        Microsoft::Quantum::Simulator::destroy(id);
    }

    MICROSOFT_QUANTUM_DECL void seed(unsigned id, unsigned s)
    {
        Microsoft::Quantum::Simulator::get(id)->seed(s);
    }

    // non-quantum
    MICROSOFT_QUANTUM_DECL std::size_t random_choice(unsigned id, std::size_t n, double* p)
    {
        return Microsoft::Quantum::Simulator::get(id)->random(n, p);
    }

    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(
        unsigned id,
        unsigned n,
        int* b,
        unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        return Microsoft::Quantum::Simulator::get(id)->JointEnsembleProbability(bv, qv);
    }

    MICROSOFT_QUANTUM_DECL bool InjectState(
        unsigned sid,
        unsigned n,
        unsigned* q,
        double* re,
        double* im)
    {
        const size_t N = (static_cast<size_t>(1) << n);
        std::vector<ComplexType> amplitudes;
        amplitudes.reserve(N);
        for (size_t i = 0; i < N; i++)
        {
            amplitudes.push_back({re[i], im[i]});
        }
        std::vector<unsigned> qubits(q, q + n);

        return Microsoft::Quantum::Simulator::get(sid)->InjectState(qubits, amplitudes);
    }

    MICROSOFT_QUANTUM_DECL void allocateQubit(unsigned id, unsigned q)
    {
        Microsoft::Quantum::Simulator::get(id)->allocateQubit(q);
    }

    MICROSOFT_QUANTUM_DECL bool release(unsigned id, unsigned q)
    {
        // The underlying simulator function will return True if and only if the qubit being released
        // was in the ground state prior to release.
        return Microsoft::Quantum::Simulator::get(id)->release(q);
    }

    MICROSOFT_QUANTUM_DECL unsigned num_qubits(unsigned id)
    {
        return Microsoft::Quantum::Simulator::get(id)->num_qubits();
    }

#define FWDGATE1(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G(unsigned id, unsigned q)                                                   \
    {                                                                                                                  \
        Microsoft::Quantum::Simulator::get(id)->G(q);                                                                  \
    }
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G(unsigned id, unsigned n, unsigned* c, unsigned q)   \
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

    MICROSOFT_QUANTUM_DECL void R(unsigned id, unsigned b, double phi, unsigned q)
    {
        Microsoft::Quantum::Simulator::get(id)->R(static_cast<Gates::Basis>(b), phi, q);
    }

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR(
        unsigned id,
        unsigned b,
        double phi,
        unsigned nc,
        unsigned* c,
        unsigned q)
    {
        std::vector<unsigned> cv(c, c + nc);
        Microsoft::Quantum::Simulator::get(id)->CR(static_cast<Gates::Basis>(b), phi, cv, q);
    }

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp(
        unsigned id,
        unsigned n,
        unsigned* b,
        double phi,
        unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->Exp(bv, phi, qv);
    }
    MICROSOFT_QUANTUM_DECL void MCExp(
        unsigned id,
        unsigned n,
        unsigned* b,
        double phi,
        unsigned nc,
        unsigned* c,
        unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        std::vector<unsigned> cv(c, c + nc);
        Microsoft::Quantum::Simulator::get(id)->CExp(bv, phi, cv, qv);
    }

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M(unsigned id, unsigned q)
    {
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->M(q);
    }
    MICROSOFT_QUANTUM_DECL unsigned Measure(
        unsigned id,
        unsigned n,
        unsigned* b,
        unsigned* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<unsigned> qv(q, q + n);
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->Measure(bv, qv);
    }

    // apply permutation of basis states to the wave function
    MICROSOFT_QUANTUM_DECL void PermuteBasis(
        unsigned id,
        unsigned n,
        unsigned* q,
        std::size_t table_size,
        std::size_t* permutation_table)
    {
        const std::vector<unsigned> qs(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, false);
    }
    MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(
        unsigned id,
        unsigned n,
        unsigned* q,
        std::size_t table_size,
        std::size_t* permutation_table)
    {
        const std::vector<unsigned> qs(q, q + n);
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, true);
    }

    // dump wavefunction to given callback until callback returns false
    MICROSOFT_QUANTUM_DECL void Dump(unsigned id, bool (*callback)(const char*, double, double))
    {
        Microsoft::Quantum::Simulator::get(id)->dump(callback);
    }

    MICROSOFT_QUANTUM_DECL void DumpToLocation(unsigned id, TDumpToLocationCallback callback, TDumpLocation location)
    {
        Microsoft::Quantum::Simulator::get(id)->dump(callback, location);
    }

    // dump the wavefunction of the subset of qubits to the given callback returns false
    MICROSOFT_QUANTUM_DECL bool DumpQubits(
        unsigned id,
        unsigned n,
        unsigned* q,
        bool (*callback)(const char*, double, double))
    {
        std::vector<unsigned> qs(q, q + n);
        return Microsoft::Quantum::Simulator::get(id)->dumpQubits(qs, callback);
    }

    MICROSOFT_QUANTUM_DECL bool DumpQubitsToLocation(
        unsigned id,
        unsigned n,
        unsigned* q,
        TDumpToLocationCallback callback, 
        TDumpLocation location)
    {
        std::vector<unsigned> qs(q, q + n);
        return Microsoft::Quantum::Simulator::get(id)->dumpQubits(qs, callback, location);
    }


    // dump the list of logical qubit ids to given callback
    MICROSOFT_QUANTUM_DECL void DumpIds(unsigned id, void (*callback)(unsigned))
    {
        Microsoft::Quantum::Simulator::get(id)->dumpIds(callback);
    }
}
