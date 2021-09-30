// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Wrapper functions for basic C++ functions
// All have the same logic: use the sim_id argument as an
// index into the vector of simulators,
// then call a member function

#include <iostream>
#include <string>
#include <chrono>
#include <thread>

#include "capi.hpp"
#include "SparseSimulator.h"
#include "factory.hpp"

using namespace Microsoft::Quantum::SPARSESIMULATOR;

std::string sample_string;

extern "C"
{

    MICROSOFT_QUANTUM_DECL unsigned init_cpp(logical_qubit_id num_qubits)
    {
       return createSimulator(num_qubits);
    }


    MICROSOFT_QUANTUM_DECL void destroy_cpp(unsigned sim_id)
    {
        destroySimulator(sim_id);
    }

    MICROSOFT_QUANTUM_DECL void seed_cpp(unsigned sim_id, _In_ unsigned s){
        getSimulator(sim_id)->set_random_seed(s);
    }

    MICROSOFT_QUANTUM_DECL void allocateQubit_cpp(unsigned sim_id, logical_qubit_id q)
    {
        getSimulator(sim_id)->allocate_specific_qubit(q);
    }

    MICROSOFT_QUANTUM_DECL void releaseQubit_cpp(unsigned sim_id, logical_qubit_id q)
    {
        getSimulator(sim_id)->release(q);
    }

    MICROSOFT_QUANTUM_DECL logical_qubit_id num_qubits_cpp(unsigned sim_id)
    {
        return getSimulator(sim_id)->get_num_qubits();
    }

// Generic single-qubit gate
#define FWDGATE1(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G##_cpp(unsigned sim_id, _In_ logical_qubit_id q)                                                   \
    {                                                                                                                  \
        getSimulator(sim_id)->G(q);                                                                  \
    }
// Generic multi-qubit gate
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G##_cpp(unsigned sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q)   \
    {                                                                                                                  \
                                                                                                                       \
        getSimulator(sim_id)->MC##G(std::vector<logical_qubit_id>(c, c + n), q);                                                   \
    }
#define FWD(G) FWDGATE1(G)

    // single-qubit gates
        FWD(X)
        FWD(Y)
        FWD(Z)
        FWD(H)

        FWD(S)
        FWD(T)
        FWD(AdjS)
        FWD(AdjT)

#define MFWD(G) FWDCSGATE1(G)
        MFWD(H)
        MFWD(X)
        MFWD(Y)
        MFWD(Z)

#undef FWDGATE1
#undef FWDGATE2
#undef FWDGATE3
#undef FWDCSGATE1
#undef FWD



    MICROSOFT_QUANTUM_DECL void SWAP_cpp(unsigned sim_id, _In_ logical_qubit_id q1, _In_ logical_qubit_id q2){
        getSimulator(sim_id)->SWAP(q1, q2);
    }

    MICROSOFT_QUANTUM_DECL void MCSWAP_cpp(unsigned sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q1, _In_ logical_qubit_id q2){
        getSimulator(sim_id)->CSWAP(std::vector<logical_qubit_id>(c, c + n), q1, q2);
    }

    MICROSOFT_QUANTUM_DECL void MCApplyAnd_cpp(unsigned sim_id,_In_ int length, _In_reads_(length) logical_qubit_id* controls, _In_ logical_qubit_id target){
        getSimulator(sim_id)->MCApplyAnd(std::vector<logical_qubit_id>(controls, controls + length), target);
    }

    MICROSOFT_QUANTUM_DECL void MCAdjointApplyAnd_cpp(unsigned sim_id,_In_ int length, _In_reads_(length) logical_qubit_id* controls, _In_ logical_qubit_id target){
        getSimulator(sim_id)->MCApplyAndAdj(std::vector<logical_qubit_id>(controls, controls + length), target);
    }

    // rotations

    MICROSOFT_QUANTUM_DECL void R_cpp(unsigned sim_id, _In_ int b, _In_ double phi, _In_ logical_qubit_id q)
    {
        getSimulator(sim_id)->R(static_cast<Gates::Basis>(b), phi, q);
    }
    MICROSOFT_QUANTUM_DECL void Rfrac_cpp(unsigned sim_id, _In_ int b, _In_ std::int64_t numerator, _In_ std::int64_t power, _In_ logical_qubit_id q)
    {
        getSimulator(sim_id)->RFrac(static_cast<Gates::Basis>(b), numerator, power, q);
    }
    MICROSOFT_QUANTUM_DECL void R1_cpp(unsigned sim_id,_In_ double phi, _In_ logical_qubit_id q)
    {
        getSimulator(sim_id)->R1(phi, q);
    }
    MICROSOFT_QUANTUM_DECL void R1frac_cpp(unsigned sim_id, _In_ std::int64_t numerator, _In_ std::int64_t power, _In_ logical_qubit_id q)
    {
        getSimulator(sim_id)->R1Frac(numerator, power, q);
    }

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR_cpp(
        unsigned sim_id,
        _In_ int b,
        _In_ double phi,
        _In_ logical_qubit_id nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR(cv, static_cast<Gates::Basis>(b), phi, q);
    }

    MICROSOFT_QUANTUM_DECL void MCRFrac_cpp(
        unsigned sim_id,
        _In_ int b,
        _In_ std::int64_t numerator, 
        _In_ std::int64_t power,
        _In_ logical_qubit_id nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCRFrac(cv, static_cast<Gates::Basis>(b), numerator, power, q);
    }

    MICROSOFT_QUANTUM_DECL void MCR1_cpp(
        unsigned sim_id,
        _In_ double phi,
        _In_ int nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR1(cv, phi, q);
    }

    MICROSOFT_QUANTUM_DECL void MCR1Frac_cpp(
        unsigned sim_id,
        _In_ std::int64_t numerator, 
        _In_ std::int64_t power,
        _In_ int nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR1Frac(cv, numerator, power, q);
    }

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp_cpp(
        unsigned sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_ double phi,
        _In_reads_(n) logical_qubit_id* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        getSimulator(sim_id)->Exp(bv, phi, qv);
    }

   MICROSOFT_QUANTUM_DECL void MCExp_cpp(
        unsigned sim_id,
        _In_ int nc,
        _In_ int n,
        _In_reads_(nc) logical_qubit_id* c,
        _In_reads_(n) int* b,
        _In_ double phi,
        _In_reads_(n) logical_qubit_id* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCExp(cv, bv, phi, qv);
    }

    // measurements
    MICROSOFT_QUANTUM_DECL bool M_cpp(unsigned sim_id, _In_ logical_qubit_id q)
    {
        return getSimulator(sim_id)->M(q);
    }

    MICROSOFT_QUANTUM_DECL void Reset_cpp(unsigned sim_id, _In_ logical_qubit_id q){
        getSimulator(sim_id)->Reset(q);
    }

    MICROSOFT_QUANTUM_DECL bool Measure_cpp(
        unsigned sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_reads_(n) logical_qubit_id* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        return getSimulator(sim_id)->Measure(bv, qv);
    }

    // Extracts the probability of measuring a One result on qubits q with basis b
    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability_cpp(
        unsigned sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_reads_(n) logical_qubit_id* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        return getSimulator(sim_id)->MeasurementProbability(bv, qv);
    }


    // Iterates through the entire wavefunction and calls `callback` on every state in the superposition
    // It will write the label of the state, in binary, from qubit 0 to `max_qubit_id`, into the char* pointer, then call `callback`
    //  with the real and complex values as the double arguments
     MICROSOFT_QUANTUM_DECL void Dump_cpp(unsigned sim_id, _In_ logical_qubit_id max_qubit_id, _In_ void (*callback)(char* , double, double)){
        return getSimulator(sim_id)->dump_all(max_qubit_id, callback);
     }

     // Same as Dump_cpp, but only dumps the wavefunction on the qubits in `q`, ensuring they are separable from the rest of the state first
    MICROSOFT_QUANTUM_DECL bool DumpQubits_cpp(
        unsigned sim_id,
        _In_ logical_qubit_id n,
        _In_reads_(n) logical_qubit_id* q,
        _In_ void (*callback)(char* , double, double))
    {
        std::vector<logical_qubit_id> qs(q, q + n);
        return getSimulator(sim_id)->dump_qubits(qs, callback);
    }


    // Asserts that the gates in `b`, measured on the qubits in `q`, return `result`
    MICROSOFT_QUANTUM_DECL bool Assert_cpp(unsigned sim_id, _In_ int n, _In_reads_(n) int* b, _In_reads_(n) logical_qubit_id* q, bool result){
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        try {
            getSimulator(sim_id)->Assert(bv, qv, result);
        }
        catch(const std::exception&){
            // C# will not call "Dispose"
            // after this exception, so this cleans up manually
            destroySimulator(sim_id);
            return false;
        }
        return true;
    }

}
