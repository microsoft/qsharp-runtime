// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "config.hpp"
#include <complex>

// SAL only defined in windows.
#ifndef _In_
// NOLINTNEXTLINE
#define _In_
// NOLINTNEXTLINE
#define _In_reads_(n)
#endif

extern "C"
{
    // non-quantum

    MICROSOFT_QUANTUM_DECL unsigned init(); // NOLINT
    MICROSOFT_QUANTUM_DECL void destroy(_In_ unsigned sid); // NOLINT
    MICROSOFT_QUANTUM_DECL void seed(_In_ unsigned sid, _In_ unsigned s); // NOLINT
    MICROSOFT_QUANTUM_DECL void Dump(_In_ unsigned sid, _In_ bool (*callback)(size_t, double, double));
    MICROSOFT_QUANTUM_DECL bool DumpQubits(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ bool (*callback)(size_t, double, double));

    typedef void* TDumpLocation;
    typedef bool (*TDumpToLocationCallback)(size_t, double, double, TDumpLocation);
    // TDumpToLocationAPI is the siugnature of DumpToLocation. The caller needs to cast the address to TDumpToLocationAPI
    // to correctly call DumpToLocation from outside of this dynamic library.
    typedef void (*TDumpToLocationAPI)(unsigned sid, TDumpToLocationCallback callback, TDumpLocation location);
    MICROSOFT_QUANTUM_DECL void DumpToLocation(_In_ unsigned sid, _In_ TDumpToLocationCallback callback, _In_ TDumpLocation location);

    // TDumpQubitsToLocationAPI is the siugnature of DumpQubitsToLocation. The caller needs to cast the address to TDumpQubitsToLocationAPI
    // to correctly call DumpQubitsToLocation from outside of this dynamic library.
    typedef bool (*TDumpQubitsToLocationAPI)(
        unsigned sid,
        unsigned n,
        unsigned* q,
        TDumpToLocationCallback callback, 
        TDumpLocation location);
    MICROSOFT_QUANTUM_DECL bool DumpQubitsToLocation(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ TDumpToLocationCallback callback, 
        _In_ TDumpLocation location);

    MICROSOFT_QUANTUM_DECL void DumpIds(_In_ unsigned sid, _In_ void (*callback)(unsigned));

    MICROSOFT_QUANTUM_DECL std::size_t random_choice(_In_ unsigned sid, _In_ std::size_t n, _In_reads_(n) double* p); // NOLINT

    MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) int* b,
        _In_reads_(n) unsigned* q);

    MICROSOFT_QUANTUM_DECL bool InjectState(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q, // The listed qubits must be disentangled and in state |0>
        _In_ double* re, // 2^n real parts of the amplitudes of the superposition the listed qubits should be put into
        _In_ double* im  // 2^n imaginary parts of the amplitudes
    );

    // allocate and release
    MICROSOFT_QUANTUM_DECL void allocateQubit(_In_ unsigned sid, _In_ unsigned qid); // NOLINT
    MICROSOFT_QUANTUM_DECL bool release(_In_ unsigned sid, _In_ unsigned q); // NOLINT
    MICROSOFT_QUANTUM_DECL unsigned num_qubits(_In_ unsigned sid); // NOLINT

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
    MICROSOFT_QUANTUM_DECL void MCR(
        _In_ unsigned sid,
        _In_ unsigned b,
        _In_ double phi,
        _In_ unsigned n,
        _In_reads_(n) unsigned* c,
        _In_ unsigned q);

    // Exponential of Pauli operators
    MICROSOFT_QUANTUM_DECL void Exp(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_reads_(n) unsigned* q);
    MICROSOFT_QUANTUM_DECL void MCExp(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_ double phi,
        _In_ unsigned nc,
        _In_reads_(nc) unsigned* cs,
        _In_reads_(n) unsigned* q);

    // measurements
    MICROSOFT_QUANTUM_DECL unsigned M(_In_ unsigned sid, _In_ unsigned q);
    MICROSOFT_QUANTUM_DECL unsigned Measure(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* b,
        _In_reads_(n) unsigned* q);

    // permutation oracle emulation
    MICROSOFT_QUANTUM_DECL void PermuteBasis(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ std::size_t table_size, // NOLINT
        _In_reads_(table_size) std::size_t* permutation_table); // NOLINT
    MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(
        _In_ unsigned sid,
        _In_ unsigned n,
        _In_reads_(n) unsigned* q,
        _In_ std::size_t table_size, // NOLINT
        _In_reads_(table_size) std::size_t* permutation_table); // NOLINT

}
