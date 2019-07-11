// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>

#include "util/openmp.hpp"

void Microsoft::Quantum::openmp::init(unsigned numthreads)
{
#ifdef _OPENMP
    if (numthreads)
        omp_set_num_threads(numthreads);
#if defined(__ICC) || defined(__INTEL_COMPILER)
    kmp_set_defaults("KMP_AFFINITY=compact");
#endif
#else
    assert(numthreads < 2);
#endif
}
