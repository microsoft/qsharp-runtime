// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#pragma once

#include "config.hpp"
#include <complex>

extern "C" {
// non-quantum

MICROSOFT_QUANTUM_DECL unsigned init();
MICROSOFT_QUANTUM_DECL void destroy(unsigned);
MICROSOFT_QUANTUM_DECL void seed(unsigned id,unsigned);
MICROSOFT_QUANTUM_DECL void Dump(unsigned id, bool(*callback)(size_t, double, double));
MICROSOFT_QUANTUM_DECL bool DumpQubits(unsigned id, unsigned n, unsigned* q, bool(*callback)(size_t, double, double));
MICROSOFT_QUANTUM_DECL void DumpIds(unsigned id, void(*callback)(unsigned));

MICROSOFT_QUANTUM_DECL std::size_t random_choice(unsigned id,std::size_t, double* p);

MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(unsigned id, unsigned n, int* b, unsigned* q);

// allocate and release
MICROSOFT_QUANTUM_DECL void allocateQubit(unsigned id, unsigned q);
MICROSOFT_QUANTUM_DECL void release(unsigned id, unsigned n);
MICROSOFT_QUANTUM_DECL unsigned num_qubits(unsigned id);

// single-qubit gates
MICROSOFT_QUANTUM_DECL void X(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void Y(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void Z(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void H(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void S(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void T(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void AdjS(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL void AdjT(unsigned id, unsigned);


// multi-controlled single-qubit gates

MICROSOFT_QUANTUM_DECL void MCX(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCY(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCZ(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCH(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCS(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCT(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCAdjS(unsigned id, unsigned n, unsigned* c, unsigned);
MICROSOFT_QUANTUM_DECL void MCAdjT(unsigned id, unsigned n, unsigned* c, unsigned);

// multi-qubit gates
//MICROSOFT_QUANTUM_DECL void SWAP(unsigned id, unsigned, unsigned);
//MICROSOFT_QUANTUM_DECL void MultiX(unsigned id, unsigned n, unsigned* q);

// controlled multi-qubit gates
//MICROSOFT_QUANTUM_DECL void MCSWAP(unsigned id, unsigned n, unsigned* c, unsigned, unsigned);
//MICROSOFT_QUANTUM_DECL void MCMultiX(unsigned id, unsigned nc, unsigned* c, unsigned nq, unsigned* q);

// rotations
MICROSOFT_QUANTUM_DECL void R(unsigned id, unsigned b, double, unsigned);
//MICROSOFT_QUANTUM_DECL void R1(unsigned id, double, unsigned);

// multi-controlled rotations
MICROSOFT_QUANTUM_DECL void MCR(unsigned id, unsigned b, double, unsigned n, unsigned* c, unsigned);
//MICROSOFT_QUANTUM_DECL void MCR1(unsigned id, double, unsigned n, unsigned* c, unsigned);

// Exponential of Pauli operators
MICROSOFT_QUANTUM_DECL void Exp(unsigned id, unsigned n, unsigned* b, double, unsigned* q);
MICROSOFT_QUANTUM_DECL void MCExp(unsigned id, unsigned n, unsigned* b, double, unsigned nc, unsigned* cs, unsigned* q);

// measurements
MICROSOFT_QUANTUM_DECL unsigned M(unsigned id, unsigned);
MICROSOFT_QUANTUM_DECL unsigned Measure(unsigned id, unsigned n, unsigned* b, unsigned* q);

// wave function cheat
//MICROSOFT_QUANTUM_DECL std::complex<double> const* wavefunction(unsigned id);
  
// permutation oracle emulation
MICROSOFT_QUANTUM_DECL void PermuteBasis(unsigned id, unsigned n, unsigned* q, std::size_t table_size, std::size_t *permutation_table);
MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(unsigned id, unsigned n, unsigned* q, std::size_t table_size, std::size_t *permutation_table);

}
