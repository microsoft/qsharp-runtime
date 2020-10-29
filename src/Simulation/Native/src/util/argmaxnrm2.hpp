// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "openmp.hpp"
#include "splitinterval.hpp"
#include <algorithm>
#include <cassert>
#include <complex>
#include <vector>

namespace Microsoft
{
namespace Quantum
{
template <class TInputIterator>
TInputIterator argmaxnrm2serial(TInputIterator first, TInputIterator last)
{
    TInputIterator argmax = first;
    auto maxvalue = std::norm(*argmax);
    for (TInputIterator i = first; i != last; ++i)
    {
        auto val = std::norm(*i);
        if (val > maxvalue)
        {
            maxvalue = val;
            argmax = i;
        }
    }
    return argmax;
}

template <class T, class A>
std::size_t argmaxnrm2(const std::vector<T, A>& values)
{
    assert(values.size() > 0);

    std::size_t threads = static_cast<std::size_t>(omp_get_max_threads());
    std::vector<std::size_t> chunks = split_interval_in_chunks(values.size(), threads);

    std::vector<T> argmaxvals(chunks.size() - 1);
    std::vector<typename std::vector<T, A>::const_iterator> argmaxs(chunks.size() - 1);
#pragma omp parallel
    {
        int threadid = omp_get_thread_num();
        if (threadid < chunks.size() - 1)
        {
            typename std::vector<T, A>::const_iterator chunk_start = begin(values) + chunks[threadid];
            typename std::vector<T, A>::const_iterator chunck_end = begin(values) + chunks[threadid + 1];
            argmaxs[threadid] = argmaxnrm2serial(chunk_start, chunck_end);
            argmaxvals[threadid] = *argmaxs[threadid];
        }
    }

    typename std::vector<T>::const_iterator argmax = argmaxnrm2serial(begin(argmaxvals), end(argmaxvals));

    return argmaxs[argmax - begin(argmaxvals)] - begin(values);
}
} // namespace Quantum
} // namespace Microsoft
