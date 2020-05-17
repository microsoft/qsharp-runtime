// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "config.hpp"
#include <complex>

// SAL only defined in windows.
#ifndef _In_
#define _In_
#define _In_reads_(n)
#endif

extern "C" {
// non-quantum

MICROSOFT_QUANTUM_DECL unsigned init();
MICROSOFT_QUANTUM_DECL unsigned initDBG(int force,int fusedSpan); //@@@DBG
MICROSOFT_QUANTUM_DECL void destroy(_In_ unsigned sid);
MICROSOFT_QUANTUM_DECL void seed(_In_ unsigned sid, _In_ unsigned s);
MICROSOFT_QUANTUM_DECL void Dump(_In_ unsigned sid, _In_ bool(*callback)(size_t, double, double));
MICROSOFT_QUANTUM_DECL bool DumpQubits(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* q, _In_ bool(*callback)(size_t, double, double));
MICROSOFT_QUANTUM_DECL void DumpIds(_In_ unsigned sid, _In_ void(*callback)(unsigned));

MICROSOFT_QUANTUM_DECL std::size_t random_choice(_In_ unsigned sid, _In_ std::size_t n, _In_reads_(n) double* p);

MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) int* b, _In_reads_(n) unsigned* q);

// allocate and release
MICROSOFT_QUANTUM_DECL void allocateQubit(_In_ unsigned sid, _In_ unsigned qid);
MICROSOFT_QUANTUM_DECL void release(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL unsigned num_qubits(_In_ unsigned sid);

// single-qubit gates
MICROSOFT_QUANTUM_DECL void X(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void Y(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void Z(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void H(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void S(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void T(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void AdjS(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void AdjT(_In_ unsigned sid, _In_ unsigned q);


// multi-controlled single-qubit gates

MICROSOFT_QUANTUM_DECL void MCX(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCY(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCZ(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCH(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCS(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCT(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCAdjS(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL void MCAdjT(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);

// rotations
MICROSOFT_QUANTUM_DECL void R(_In_ unsigned sid, _In_ unsigned b, _In_ double phi, _In_ unsigned q);

// multi-controlled rotations
MICROSOFT_QUANTUM_DECL void MCR(_In_ unsigned sid, _In_ unsigned b, _In_ double phi, _In_ unsigned n, _In_reads_(n) unsigned* c, _In_ unsigned q);

// Exponential of Pauli operators
MICROSOFT_QUANTUM_DECL void Exp(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* b, _In_ double phi, _In_reads_(n) unsigned* q);
MICROSOFT_QUANTUM_DECL void MCExp(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* b, _In_ double phi, _In_ unsigned nc, _In_reads_(nc) unsigned* cs, _In_reads_(n) unsigned* q);

// measurements
MICROSOFT_QUANTUM_DECL unsigned M(_In_ unsigned sid, _In_ unsigned q);
MICROSOFT_QUANTUM_DECL unsigned Measure(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* b, _In_reads_(n) unsigned* q);

// permutation oracle emulation
MICROSOFT_QUANTUM_DECL void PermuteBasis(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* q, _In_ std::size_t table_size, _In_reads_(table_size) std::size_t *permutation_table);
MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(_In_ unsigned sid, _In_ unsigned n, _In_reads_(n) unsigned* q, _In_ std::size_t table_size, _In_reads_(table_size) std::size_t *permutation_table);

}
