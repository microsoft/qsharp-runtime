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
        _In_reads_(n) intptr_t* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(
            reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        return Microsoft::Quantum::Simulator::get(id)->JointEnsembleProbability(bv, qv);
    }

    MICROSOFT_QUANTUM_DECL bool InjectState(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) intptr_t* q,
        _In_ double* re,
        _In_ double* im)
    {
        const size_t N = (static_cast<size_t>(1) << n);
        std::vector<ComplexType> amplitudes;
        amplitudes.reserve(N);
        for (size_t i = 0; i < N; i++)
        {
            amplitudes.push_back({re[i], im[i]});
        }
        std::vector<logical_qubit_id> qubits(
            reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));

        return Microsoft::Quantum::Simulator::get(sid)->InjectState(qubits, amplitudes);
    }

    MICROSOFT_QUANTUM_DECL void allocateQubit(_In_ unsigned id, _In_ intptr_t q)
    {
        Microsoft::Quantum::Simulator::get(id)->allocateQubit(static_cast<logical_qubit_id>(q));
    }

    MICROSOFT_QUANTUM_DECL bool release(_In_ unsigned id, _In_ intptr_t q)
    {
        // The underlying simulator function will return True if and only if the qubit being released
        // was in the ground state prior to release.
        return Microsoft::Quantum::Simulator::get(id)->release(static_cast<logical_qubit_id>(q));
    }

    MICROSOFT_QUANTUM_DECL intptr_t num_qubits(_In_ unsigned id)
    {
        return static_cast<intptr_t>(Microsoft::Quantum::Simulator::get(id)->num_qubits());
    }

#define FWDGATE1(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G(_In_ unsigned id, _In_ intptr_t q)                                                   \
    {                                                                                                                  \
        Microsoft::Quantum::Simulator::get(id)->G(static_cast<logical_qubit_id>(q));                                   \
    }
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G(_In_ unsigned id, _In_ unsigned n, _In_reads_(n) intptr_t* c, _In_ intptr_t q)   \
    {                                                                                                                  \
        std::vector<logical_qubit_id> vc(                                                                              \
            reinterpret_cast<logical_qubit_id*>(c), reinterpret_cast<logical_qubit_id*>(c + n));                       \
        Microsoft::Quantum::Simulator::get(id)->C##G(vc, static_cast<logical_qubit_id>(q));                            \
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

    MICROSOFT_QUANTUM_DECL void R(_In_ unsigned id, _In_ unsigned b, _In_ double phi, _In_ intptr_t q)
    {
        Microsoft::Quantum::Simulator::get(id)->R(static_cast<Gates::Basis>(b), phi, static_cast<logical_qubit_id>(q));
    }

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR(
        _In_ unsigned id,
        _In_ unsigned b,
        _In_ double phi,
        _In_ unsigned nc,
        _In_reads_(nc) intptr_t* c,
        _In_ intptr_t q)
    {
        std::vector<logical_qubit_id> cv(reinterpret_cast<logical_qubit_id*>(c), reinterpret_cast<logical_qubit_id*>(c + nc));
        Microsoft::Quantum::Simulator::get(id)->CR(
            static_cast<Gates::Basis>(b), phi, cv, static_cast<logical_qubit_id>(q));
    }

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_reads_(n) intptr_t* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        Microsoft::Quantum::Simulator::get(id)->Exp(bv, phi, qv);
    }
    MICROSOFT_QUANTUM_DECL void MCExp(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_ unsigned nc,
        _In_reads_(nc) intptr_t* c,
        _In_reads_(n) intptr_t* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        std::vector<logical_qubit_id> cv(reinterpret_cast<logical_qubit_id*>(c), reinterpret_cast<logical_qubit_id*>(c + nc));
        Microsoft::Quantum::Simulator::get(id)->CExp(bv, phi, cv, qv);
    }

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M(_In_ unsigned id, _In_ intptr_t q)
    {
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->M(static_cast<logical_qubit_id>(q));
    }
    MICROSOFT_QUANTUM_DECL unsigned Measure(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_reads_(n) intptr_t* q)
    {
        std::vector<Gates::Basis> bv;
        for (unsigned i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        return (unsigned)Microsoft::Quantum::Simulator::get(id)->Measure(bv, qv);
    }

    // apply permutation of basis states to the wave function
    MICROSOFT_QUANTUM_DECL void PermuteBasis(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) intptr_t* q,
        _In_ std::size_t table_size,
        _In_reads_(table_size) std::size_t* permutation_table)
    {
        assert(sizeof(logical_qubit_id) == sizeof(intptr_t));
        const std::vector<logical_qubit_id> qs(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, false);
    }
    MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) intptr_t* q,
        _In_ std::size_t table_size,
        _In_reads_(table_size) std::size_t* permutation_table)
    {
        const std::vector<logical_qubit_id> qs(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        Microsoft::Quantum::Simulator::get(id)->permuteBasis(qs, table_size, permutation_table, true);
    }

    // dump wavefunction to given callback until callback returns false
    MICROSOFT_QUANTUM_DECL void Dump(_In_ unsigned id, _In_ bool (*callback)(size_t, double, double))
    {
        Microsoft::Quantum::Simulator::get(id)->dump(callback);
    }

    MICROSOFT_QUANTUM_DECL void DumpToLocation(
        _In_ unsigned id,
        _In_ TDumpToLocationCallback callback,
        _In_ TDumpLocation location)
    {
        Microsoft::Quantum::Simulator::get(id)->dump(callback, location);
    }

    // dump the wavefunction of the subset of qubits to the given callback returns false
    MICROSOFT_QUANTUM_DECL bool DumpQubits(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) intptr_t* q,
        _In_ bool (*callback)(size_t, double, double))
    {
        std::vector<logical_qubit_id> qs(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        return Microsoft::Quantum::Simulator::get(id)->dumpQubits(qs, callback);
    }

    MICROSOFT_QUANTUM_DECL bool DumpQubitsToLocation(
        _In_ unsigned id,
        _In_ unsigned n,
        _In_reads_(n) intptr_t* q,
        _In_ TDumpToLocationCallback callback,
        _In_ TDumpLocation location)
    {
        std::vector<logical_qubit_id> qs(reinterpret_cast<logical_qubit_id*>(q), reinterpret_cast<logical_qubit_id*>(q + n));
        return Microsoft::Quantum::Simulator::get(id)->dumpQubits(qs, callback, location);
    }

    // dump the list of logical qubit ids to given callback
    MICROSOFT_QUANTUM_DECL void DumpIds(_In_ unsigned id, _In_ void (*callback)(intptr_t))
    {
        Microsoft::Quantum::Simulator::get(id)->dumpIds(callback);
    }
}
