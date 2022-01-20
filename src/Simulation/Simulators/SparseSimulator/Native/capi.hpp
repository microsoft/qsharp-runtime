// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include "types.h"

// SAL only defined in windows.
#ifndef _In_
#define _In_
#define _In_reads_(n)
#endif
#ifndef _Out_
#define _Out_
#endif

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

    MICROSOFT_QUANTUM_DECL void seed_cpp(simulator_id_type sim_id, _In_ unsigned int s);
    // allocate and release
    MICROSOFT_QUANTUM_DECL void allocateQubit_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void releaseQubit_cpp(simulator_id_type sim_id, logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL logical_qubit_id num_qubits_cpp(simulator_id_type sim_id);

    // single-qubit gates
    MICROSOFT_QUANTUM_DECL void X_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Y_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Z_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void H_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void S_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void T_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void AdjS_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void AdjT_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);


    MICROSOFT_QUANTUM_DECL void MCX_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCY_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCZ_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void MCH_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q);

    MICROSOFT_QUANTUM_DECL void SWAP_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q1, _In_ logical_qubit_id q2);
    MICROSOFT_QUANTUM_DECL void MCSWAP_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) logical_qubit_id* c, _In_ logical_qubit_id q1, _In_ logical_qubit_id q2);
    MICROSOFT_QUANTUM_DECL void MCAnd_cpp(simulator_id_type sim_id,_In_ int length, _In_reads_(length) logical_qubit_id* controls, _In_ logical_qubit_id target);
    MICROSOFT_QUANTUM_DECL void MCAdjointAnd_cpp(simulator_id_type sim_id,_In_ int length, _In_reads_(length) logical_qubit_id* controls, _In_ logical_qubit_id target);

    // rotations
    MICROSOFT_QUANTUM_DECL void R_cpp(simulator_id_type sim_id, _In_ int b, _In_ double phi, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Rfrac_cpp(simulator_id_type sim_id, _In_ int b, _In_ std::int64_t numerator, std::int64_t power, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void R1_cpp(simulator_id_type sim_id, _In_ double phi, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void R1frac_cpp(simulator_id_type sim_id, _In_ std::int64_t numerator, std::int64_t power, _In_ logical_qubit_id q);

 

   // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR_cpp(
        simulator_id_type sim_id,
        _In_ int b,
        _In_ double phi,
        _In_ logical_qubit_id n,
        _In_reads_(n) logical_qubit_id* c,
        _In_ logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCRFrac_cpp(
        simulator_id_type sim_id,
        _In_ int b,
        _In_ std::int64_t numerator, 
        _In_ std::int64_t power,
        _In_ logical_qubit_id nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCR1_cpp(
        simulator_id_type sim_id,
        _In_ double phi,
        _In_ int n,
        _In_reads_(n) logical_qubit_id* c,
        _In_ logical_qubit_id q);

     MICROSOFT_QUANTUM_DECL void MCR1Frac_cpp(
        simulator_id_type sim_id,
        _In_ std::int64_t numerator, 
        _In_ std::int64_t power,
        _In_ int nc,
        _In_reads_(nc) logical_qubit_id* c,
        _In_ logical_qubit_id q);

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp_cpp(
        simulator_id_type sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_ double phi,
        _In_reads_(n) logical_qubit_id* q);
    MICROSOFT_QUANTUM_DECL void MCExp_cpp(
        simulator_id_type sim_id,
        _In_ int nc,
        _In_ int n,
        _In_reads_(nc) logical_qubit_id* c,
        _In_reads_(n) int* b,
        _In_ double phi,
        _In_reads_(n) logical_qubit_id* q);

    // measurements
    MICROSOFT_QUANTUM_DECL bool M_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL void Reset_cpp(simulator_id_type sim_id, _In_ logical_qubit_id q);
    MICROSOFT_QUANTUM_DECL bool Measure_cpp(
        simulator_id_type sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_reads_(n) logical_qubit_id* q);

   
    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability_cpp(
        simulator_id_type sim_id,
        _In_ int n,
        _In_reads_(n) int* b,
        _In_reads_(n) logical_qubit_id* q);

    MICROSOFT_QUANTUM_DECL void Dump_cpp(simulator_id_type sim_id, _In_ logical_qubit_id max_qubit_id, _In_ void (*callback)(char*, double, double));
    MICROSOFT_QUANTUM_DECL bool DumpQubits_cpp(
        simulator_id_type sim_id,
        _In_ logical_qubit_id n,
        _In_reads_(n) logical_qubit_id* q,
        _In_ void (*callback)(char* , double, double));

    MICROSOFT_QUANTUM_DECL bool Assert_cpp(simulator_id_type sim_id, _In_ int n, _In_reads_(n) int* b, _In_reads_(n) logical_qubit_id* q, bool result);
}
