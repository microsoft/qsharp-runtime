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

    MICROSOFT_QUANTUM_DECL simulator_id_type init_cpp(logical_qubit_id num_qubits)
    {
       return createSimulator(num_qubits);
    }


    MICROSOFT_QUANTUM_DECL void destroy_cpp(simulator_id_type sim_id)
    {
        destroySimulator(sim_id);
    }

    MICROSOFT_QUANTUM_DECL void seed_cpp(simulator_id_type sim_id,  unsigned int s){
        getSimulator(sim_id)->set_random_seed(s);
    }

    MICROSOFT_QUANTUM_DECL void allocateQubit_cpp(simulator_id_type sim_id, logical_qubit_id q)
    {
        getSimulator(sim_id)->allocate_specific_qubit(q);
    }

    MICROSOFT_QUANTUM_DECL bool releaseQubit_cpp(simulator_id_type sim_id, logical_qubit_id q)
    {
        return (getSimulator(sim_id)->release(q));
    }

    MICROSOFT_QUANTUM_DECL logical_qubit_id num_qubits_cpp(simulator_id_type sim_id)
    {
        return getSimulator(sim_id)->get_num_qubits();
    }

// Generic single-qubit gate
#define FWDGATE1(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G##_cpp(simulator_id_type sim_id,  logical_qubit_id q)                                                   \
    {                                                                                                                  \
        getSimulator(sim_id)->G(q);                                                                  \
    }
// Generic multi-qubit gate
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G##_cpp(simulator_id_type sim_id,  int n, logical_qubit_id* c,  logical_qubit_id q)   \
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



    MICROSOFT_QUANTUM_DECL void SWAP_cpp(simulator_id_type sim_id,  logical_qubit_id q1,  logical_qubit_id q2){
        getSimulator(sim_id)->SWAP(q1, q2);
    }

    MICROSOFT_QUANTUM_DECL void MCSWAP_cpp(simulator_id_type sim_id,  int n, logical_qubit_id* c,  logical_qubit_id q1,  logical_qubit_id q2){
        getSimulator(sim_id)->CSWAP(std::vector<logical_qubit_id>(c, c + n), q1, q2);
    }

    MICROSOFT_QUANTUM_DECL void MCApplyAnd_cpp(simulator_id_type sim_id, int length,  logical_qubit_id* controls,  logical_qubit_id target){
        getSimulator(sim_id)->MCApplyAnd(std::vector<logical_qubit_id>(controls, controls + length), target);
    }

    MICROSOFT_QUANTUM_DECL void MCAdjointApplyAnd_cpp(simulator_id_type sim_id, int length,  logical_qubit_id* controls,  logical_qubit_id target){
        getSimulator(sim_id)->MCApplyAndAdj(std::vector<logical_qubit_id>(controls, controls + length), target);
    }

    // rotations

    MICROSOFT_QUANTUM_DECL void R_cpp(simulator_id_type sim_id,  int b,  double phi,  logical_qubit_id q)
    {
        getSimulator(sim_id)->R(static_cast<Gates::Basis>(b), phi, q);
    }
    MICROSOFT_QUANTUM_DECL void Rfrac_cpp(simulator_id_type sim_id,  int b,  std::int64_t numerator,  std::int64_t power,  logical_qubit_id q)
    {
        getSimulator(sim_id)->RFrac(static_cast<Gates::Basis>(b), numerator, power, q);
    }
    MICROSOFT_QUANTUM_DECL void R1_cpp(simulator_id_type sim_id, double phi,  logical_qubit_id q)
    {
        getSimulator(sim_id)->R1(phi, q);
    }
    MICROSOFT_QUANTUM_DECL void R1frac_cpp(simulator_id_type sim_id,  std::int64_t numerator,  std::int64_t power,  logical_qubit_id q)
    {
        getSimulator(sim_id)->R1Frac(numerator, power, q);
    }

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR_cpp(
        simulator_id_type sim_id,
         int b,
         double phi,
         logical_qubit_id nc,
         logical_qubit_id* c,
         logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR(cv, static_cast<Gates::Basis>(b), phi, q);
    }

    MICROSOFT_QUANTUM_DECL void MCRFrac_cpp(
        simulator_id_type sim_id,
         int b,
         std::int64_t numerator, 
         std::int64_t power,
         logical_qubit_id nc,
         logical_qubit_id* c,
         logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCRFrac(cv, static_cast<Gates::Basis>(b), numerator, power, q);
    }

    MICROSOFT_QUANTUM_DECL void MCR1_cpp(
        simulator_id_type sim_id,
         double phi,
         int nc,
         logical_qubit_id* c,
         logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR1(cv, phi, q);
    }

    MICROSOFT_QUANTUM_DECL void MCR1Frac_cpp(
        simulator_id_type sim_id,
         std::int64_t numerator, 
         std::int64_t power,
         int nc,
         logical_qubit_id* c,
         logical_qubit_id q)
    {
        std::vector<logical_qubit_id> cv(c, c + nc);
        getSimulator(sim_id)->MCR1Frac(cv, numerator, power, q);
    }

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp_cpp(
        simulator_id_type sim_id,
         int n,
        int* b,
         double phi,
        logical_qubit_id* q)
    {
        std::vector<Gates::Basis> bv;
        bv.reserve(n);
        for (int i = 0; i < n; ++i)
            bv.push_back(static_cast<Gates::Basis>(*(b + i)));
        std::vector<logical_qubit_id> qv(q, q + n);
        getSimulator(sim_id)->Exp(bv, phi, qv);
    }

   MICROSOFT_QUANTUM_DECL void MCExp_cpp(
        simulator_id_type sim_id,
         int nc,
         int n,
         logical_qubit_id* c,
        int* b,
         double phi,
        logical_qubit_id* q)
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
    MICROSOFT_QUANTUM_DECL unsigned M_cpp(simulator_id_type sim_id,  logical_qubit_id q)
    {
        return getSimulator(sim_id)->M(q);
    }

    MICROSOFT_QUANTUM_DECL void Reset_cpp(simulator_id_type sim_id,  logical_qubit_id q){
        getSimulator(sim_id)->Reset(q);
    }

    MICROSOFT_QUANTUM_DECL unsigned Measure_cpp(
        simulator_id_type sim_id,
         int n,
        int* b,
        logical_qubit_id* q)
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
        simulator_id_type sim_id,
         int n,
        int* b,
        logical_qubit_id* q)
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
    MICROSOFT_QUANTUM_DECL void Dump_cpp(simulator_id_type sim_id,  bool (*callback)(const char*, double, double)){
        return getSimulator(sim_id)->dump_all(callback);
    }

    MICROSOFT_QUANTUM_DECL void ExtendedDump_cpp(simulator_id_type sim_id,  bool (*callback)(const char*, double, double, void*),  void* arg){
        return getSimulator(sim_id)->dump_all_ext(callback, arg);
    }

    // Same as Dump_cpp, but only dumps the wavefunction on the qubits in `q`, ensuring they are separable from the rest of the state first
    MICROSOFT_QUANTUM_DECL bool DumpQubits_cpp(
        simulator_id_type sim_id,
         int n,
        logical_qubit_id* q,
         bool (*callback)(const char*, double, double))
    {
        std::vector<logical_qubit_id> qs(q, q + n);
        return getSimulator(sim_id)->dump_qubits(qs, callback);
    }

    MICROSOFT_QUANTUM_DECL bool ExtendedDumpQubits_cpp(
        simulator_id_type sim_id,
         int n,
        logical_qubit_id* q,
         bool (*callback)(const char*, double, double, void*),
         void* arg)
    {
        std::vector<logical_qubit_id> qs(q, q + n);
        return getSimulator(sim_id)->dump_qubits_ext(qs, callback, arg);
    }

    // // dump the list of logical qubit ids to given callback
    // MICROSOFT_QUANTUM_DECL void DumpIds( unsigned id,  void (*callback)(unsigned))
    // {
    //     Microsoft::Quantum::Simulator::get(id)->dumpIds(callback);
    // }
    MICROSOFT_QUANTUM_DECL void QubitIds_cpp(simulator_id_type sim_id, void (*callback)(logical_qubit_id))
    {
        getSimulator(sim_id)->dump_ids(callback);
    }

    // Asserts that the gates in `b`, measured on the qubits in `q`, return `result`
    MICROSOFT_QUANTUM_DECL bool Assert_cpp(simulator_id_type sim_id,  int n, int* b, logical_qubit_id* q, bool result){
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
