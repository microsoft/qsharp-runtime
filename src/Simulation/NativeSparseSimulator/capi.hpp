// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include "types.h"

#ifdef BUILD_DLL
#define MICROSOFT_QUANTUM_DECL __declspec(dllexport)
#else
#define MICROSOFT_QUANTUM_DECL
#endif
#define MICROSOFT_QUANTUM_DECL_IMPORT __declspec(dllimport)

using namespace Microsoft::Quantum::SPARSESIMULATOR;

// All of these are called by the C# SparseSimulator class
extern "C"
{
    MICROSOFT_QUANTUM_DECL simulator_id_type init_cpp(logical_qubit_id num_qubits);
    MICROSOFT_QUANTUM_DECL void destroy_cpp(simulator_id_type sim_id);

    MICROSOFT_QUANTUM_DECL void seed_cpp(simulator_id_type sim_id, unsigned int s);
    // allocate and release
    MICROSOFT_QUANTUM_DECL void allocateQubit_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL bool releaseQubit_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL logical_qubit_id num_qubits_cpp(simulator_id_type sim_id);

    // single-qubit gates
    MICROSOFT_QUANTUM_DECL void X_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Y_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Z_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void H_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void S_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void T_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void AdjS_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void AdjT_cpp(simulator_id_type sim_id, logical_qubit_id q);


    MICROSOFT_QUANTUM_DECL void MCX_cpp(simulator_id_type sim_id, int n, logical_qubit_id* c, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCY_cpp(simulator_id_type sim_id, int n, logical_qubit_id* c, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCZ_cpp(simulator_id_type sim_id, int n, logical_qubit_id* c, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCH_cpp(simulator_id_type sim_id, int n, logical_qubit_id* c, logical_qubit_id q);

    MICROSOFT_QUANTUM_DECL void SWAP_cpp(simulator_id_type sim_id, logical_qubit_id q1, logical_qubit_id q2);
    MICROSOFT_QUANTUM_DECL void MCSWAP_cpp(simulator_id_type sim_id, int n, logical_qubit_id* c, logical_qubit_id q1, logical_qubit_id q2);
    MICROSOFT_QUANTUM_DECL void MCAnd_cpp(simulator_id_type sim_id, int length, logical_qubit_id* controls, logical_qubit_id target);
    MICROSOFT_QUANTUM_DECL void MCAdjointAnd_cpp(simulator_id_type sim_id, int length, logical_qubit_id* controls, logical_qubit_id target);

    // rotations
    MICROSOFT_QUANTUM_DECL void R_cpp(simulator_id_type sim_id, int b, double phi, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Rfrac_cpp(simulator_id_type sim_id, int b, std::int64_t numerator, std::int64_t power, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void R1_cpp(simulator_id_type sim_id, double phi, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void R1frac_cpp(simulator_id_type sim_id, std::int64_t numerator, std::int64_t power, logical_qubit_id q);

 

   // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR_cpp(
        simulator_id_type sim_id,
        int b,
        double phi,
        logical_qubit_id n,
        logical_qubit_id* c,
        logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCRFrac_cpp(
        simulator_id_type sim_id,
        int b,
        std::int64_t numerator, 
        std::int64_t power,
        logical_qubit_id nc,
        logical_qubit_id* c,
        logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCR1_cpp(
        simulator_id_type sim_id,
        double phi,
        int n,
        logical_qubit_id* c,
        logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCR1Frac_cpp(
        simulator_id_type sim_id,
        std::int64_t numerator, 
        std::int64_t power,
        int nc,
        logical_qubit_id* c,
        logical_qubit_id q);

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp_cpp(
        simulator_id_type sim_id,
        int n,
        int* b,
        double phi,
        logical_qubit_id* q);
    MICROSOFT_QUANTUM_DECL void MCExp_cpp(
        simulator_id_type sim_id,
        int nc,
        int n,
        logical_qubit_id* c,
        int* b,
        double phi,
        logical_qubit_id* q);

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Reset_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL unsigned Measure_cpp(
        simulator_id_type sim_id,
        int n,
        int* b,
        logical_qubit_id* q);

   
    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability_cpp(
        simulator_id_type sim_id,
        int n,
        int* b,
        logical_qubit_id* q);

    MICROSOFT_QUANTUM_DECL void Dump_cpp(simulator_id_type sim_id, bool (*callback)(const char*, double, double));
    MICROSOFT_QUANTUM_DECL void ExtendedDump_cpp(simulator_id_type sim_id, bool (*callback)(const char*, double, double, void*), void*);
    MICROSOFT_QUANTUM_DECL bool DumpQubits_cpp(
        simulator_id_type sim_id,
        int n,
        logical_qubit_id* q,
        bool (*callback)(const char*, double, double));
    MICROSOFT_QUANTUM_DECL bool ExtendedDumpQubits_cpp(
        simulator_id_type sim_id,
        int n,
        logical_qubit_id* q,
        bool (*callback)(const char*, double, double, void*),
        void*);
    MICROSOFT_QUANTUM_DECL void QubitIds_cpp(simulator_id_type sim_id, void (*callback)(logical_qubit_id));

    MICROSOFT_QUANTUM_DECL bool Assert_cpp(simulator_id_type sim_id, int n, int* b, logical_qubit_id* q, bool result);
}
