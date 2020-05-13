// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <complex>

// check if we want to force single precision
/* #undef USE_SINGLE_PRECISION */

// check if we have AVX intrinsics
#define HAVE_INTRINSICS

// check if we have AVX-512 intrinsics
/* #undef HAVE_AVX512 */

// check if we want to use fused kernels
#define USE_GATE_FUSION

/* #undef BUILD_SHARED_LIBS */


#if defined (_MSC_VER) && defined (BUILD_SHARED_LIBS)

#ifdef BUILD_DLL
#define MICROSOFT_QUANTUM_DECL __declspec(dllexport)
#else
#define MICROSOFT_QUANTUM_DECL __declspec(dllimport)
#endif
#define MICROSOFT_QUANTUM_DECL_IMPORT __declspec(dllimport)
#else
#define MICROSOFT_QUANTUM_DECL
#define MICROSOFT_QUANTUM_DECL_IMPORT
#endif

#ifdef HAVE_INTRINSICS
#ifdef HAVE_AVX512
#define SIMULATOR SimulatorAVX512
#else
#ifdef HAVE_FMA
#define SIMULATOR SimulatorAVX2
#else
#define SIMULATOR SimulatorAVX
#endif
#endif
#else
#define SIMULATOR SimulatorGeneric
#endif


