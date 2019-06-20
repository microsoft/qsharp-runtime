// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#include "util/openmp.hpp"
#include <mutex>
#include <cassert>

int main()
{

    using namespace Microsoft::Quantum::openmp;

    init();
    init(1);
    assert(omp_get_num_threads() == 1);
    assert(omp_get_thread_num() == 0);
#ifdef _OPENMP
    omp_mutex mutex;
    std::lock_guard<omp_mutex> guard(mutex);
#endif

    return 0;
}
