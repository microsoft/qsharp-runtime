// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "config.hpp"
#include <complex>

extern "C"
{
    // non-quantum

    MICROSOFT_QUANTUM_DECL unsigned init(); // NOLINT
    MICROSOFT_QUANTUM_DECL void destroy( unsigned sid); // NOLINT
    MICROSOFT_QUANTUM_DECL void seed( unsigned sid,  unsigned s); // NOLINT
    MICROSOFT_QUANTUM_DECL void Dump( unsigned sid,  bool (*callback)(const char*, double, double));
    MICROSOFT_QUANTUM_DECL bool DumpQubits(
         unsigned sid,
         unsigned n,
        unsigned* q,
         bool (*callback)(const char*, double, double));

    typedef void* TDumpLocation;
    typedef bool (*TDumpToLocationCallback)(size_t, double, double, TDumpLocation);
    // TDumpToLocationAPI is the siugnature of DumpToLocation. The caller needs to cast the address to TDumpToLocationAPI
    // to correctly call DumpToLocation from outside of this dynamic library.
    typedef void (*TDumpToLocationAPI)(unsigned sid, TDumpToLocationCallback callback, TDumpLocation location);
    MICROSOFT_QUANTUM_DECL void DumpToLocation( unsigned sid,  TDumpToLocationCallback callback,  TDumpLocation location);

    // TDumpQubitsToLocationAPI is the siugnature of DumpQubitsToLocation. The caller needs to cast the address to TDumpQubitsToLocationAPI
    // to correctly call DumpQubitsToLocation from outside of this dynamic library.
    typedef bool (*TDumpQubitsToLocationAPI)(
        unsigned sid,
        unsigned n,
        unsigned* q,
        TDumpToLocationCallback callback, 
        TDumpLocation location);
    MICROSOFT_QUANTUM_DECL bool DumpQubitsToLocation(
         unsigned sid,
         unsigned n,
        unsigned* q,
         TDumpToLocationCallback callback, 
         TDumpLocation location);

    MICROSOFT_QUANTUM_DECL void DumpIds( unsigned sid,  void (*callback)(unsigned));

    MICROSOFT_QUANTUM_DECL std::size_t random_choice( unsigned sid,  std::size_t n, double* p); // NOLINT

    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(
         unsigned sid,
         unsigned n,
        int* b,
        unsigned* q);

    MICROSOFT_QUANTUM_DECL bool InjectState(
         unsigned sid,
         unsigned n,
        unsigned* q, // The listed qubits must be unentangled and in state |0>
         double* re, // 2^n real parts of the amplitudes of the superposition the listed qubits should be put into
         double* im  // 2^n imaginary parts of the amplitudes
    );

    // allocate and release
    MICROSOFT_QUANTUM_DECL void allocateQubit( unsigned sid,  unsigned qid); // NOLINT
    MICROSOFT_QUANTUM_DECL bool release( unsigned sid,  unsigned q); // NOLINT
    MICROSOFT_QUANTUM_DECL unsigned num_qubits( unsigned sid); // NOLINT

    // single-qubit gates
    MICROSOFT_QUANTUM_DECL void X( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void Y( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void Z( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void H( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void S( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void T( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void AdjS( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL void AdjT( unsigned sid,  unsigned q);

    // multi-controlled single-qubit gates

    MICROSOFT_QUANTUM_DECL void MCX( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCY( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCZ( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCH( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCS( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCT( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCAdjS( unsigned sid,  unsigned n, unsigned* c,  unsigned q);
    MICROSOFT_QUANTUM_DECL void MCAdjT( unsigned sid,  unsigned n, unsigned* c,  unsigned q);

    // rotations
    MICROSOFT_QUANTUM_DECL void R( unsigned sid,  unsigned b,  double phi,  unsigned q);

    // multi-controlled rotations
    MICROSOFT_QUANTUM_DECL void MCR(
         unsigned sid,
         unsigned b,
         double phi,
         unsigned n,
        unsigned* c,
         unsigned q);

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp(
         unsigned sid,
         unsigned n,
        unsigned* b,
         double phi,
        unsigned* q);
    MICROSOFT_QUANTUM_DECL void MCExp(
         unsigned sid,
         unsigned n,
        unsigned* b,
         double phi,
         unsigned nc,
         unsigned* cs,
        unsigned* q);

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M( unsigned sid,  unsigned q);
    MICROSOFT_QUANTUM_DECL unsigned Measure(
         unsigned sid,
         unsigned n,
        unsigned* b,
        unsigned* q);

    // permutation oracle emulation
    MICROSOFT_QUANTUM_DECL void PermuteBasis(
         unsigned sid,
         unsigned n,
        unsigned* q,
         std::size_t table_size, // NOLINT
         std::size_t* permutation_table); // NOLINT
    MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(
         unsigned sid,
         unsigned n,
        unsigned* q,
         std::size_t table_size, // NOLINT
         std::size_t* permutation_table); // NOLINT

}
