// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "openmp.hpp"
#include <cassert>
#include <vector>

namespace Microsoft
{
namespace Quantum
{

static std::vector<std::size_t> split_interval_in_chunks(std::size_t max, std::size_t chuncks)
{
    assert(chuncks > 0);
    std::size_t smallest_chunk_size = (max - max % chuncks) / chuncks;
    std::size_t remaining_count = max - smallest_chunk_size * chuncks;
    std::size_t actual_chuncks = smallest_chunk_size != 0 ? chuncks : remaining_count;

    std::vector<std::size_t> res(actual_chuncks + 1);
    res[0] = 0;
    for (std::size_t chunk = 0; chunk < actual_chuncks; ++chunk)
    {
        res[chunk + 1] = res[chunk] + smallest_chunk_size;
        if (chunk < remaining_count)
        {
            ++res[chunk + 1];
        }
    }
    assert(res[res.size() - 1] == max);
    return res;
}
}
}
