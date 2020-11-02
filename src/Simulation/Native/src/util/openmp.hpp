// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "config.hpp"

#include <mutex>
#include <thread>

#ifdef _OPENMP
#include "omp.h"
#else

inline int omp_get_num_threads()
{
    return 1;
}

inline int omp_get_thread_num()
{
    return 0;
}
inline int omp_get_max_threads()
{
    return 1;
}
#endif

namespace Microsoft
{
namespace Quantum
{
namespace openmp
{

MICROSOFT_QUANTUM_DECL void init(unsigned numthreads = 0);
#ifdef _OPENMP

class omp_mutex
{
  public:
    omp_mutex()
    {
        omp_init_lock(&_mutex);
    }
    ~omp_mutex()
    {
        omp_destroy_lock(&_mutex);
    }
    void lock()
    {
        omp_set_lock(&_mutex);
    }
    void unlock()
    {
        omp_unset_lock(&_mutex);
    }
    omp_mutex(omp_mutex const&) = delete;
    omp_mutex& operator=(omp_mutex const&) = delete;

  private:
    omp_lock_t _mutex;
};

class omp_recursive_mutex
{
  public:
    omp_recursive_mutex()
    {
        omp_init_nest_lock(&_mutex);
    }
    ~omp_recursive_mutex()
    {
        omp_destroy_nest_lock(&_mutex);
    }
    void lock()
    {
        omp_set_nest_lock(&_mutex);
    }
    void unlock()
    {
        omp_unset_nest_lock(&_mutex);
    }
    omp_recursive_mutex(omp_recursive_mutex const&) = delete;
    omp_recursive_mutex& operator=(omp_recursive_mutex const&) = delete;

  private:
    omp_nest_lock_t _mutex;
};

using mutex_type = omp_mutex;
using recursive_mutex_type = omp_recursive_mutex;

#else
using mutex_type = std::mutex;
using recursive_mutex_type = std::recursive_mutex;
#endif

} // namespace openmp
using openmp::mutex_type;
using openmp::recursive_mutex_type;
using lock_type = std::lock_guard<mutex_type>;
using recursive_lock_type = std::lock_guard<recursive_mutex_type>;

} // namespace Quantum
} // namespace Microsoft
