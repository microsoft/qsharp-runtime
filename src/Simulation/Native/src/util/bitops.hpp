// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cassert>
#include <cmath>
#include <cstdint>
#ifdef _WIN32
#include <intrin.h>
#else
#include <x86intrin.h>
#endif

#include <bitset>

namespace Microsoft
{
namespace Quantum
{

/// the logarithm base 2 of  an integer

template <class Int>
unsigned ilog2(Int n)
{
#ifdef _WIN32
    for (unsigned width = 0; width < 8 * sizeof(Int); ++width)
        if ((static_cast<Int>(1) << width) == n) return width;
    // not a power of 2
    assert(false);
    return std::numeric_limits<unsigned>::max(); // dummy return
#else
    unsigned l = _bit_scan_reverse(n);
    assert(n == (Int(1) << l));
    return l;
#endif
}

// bit count
inline unsigned popcnt(uint64_t x)
{
#ifdef HAVE_INTRINSICS
#ifdef _WIN32
    return static_cast<unsigned>(__popcnt64(x));
#else
    return _popcnt64(x);
#endif
#else
    return static_cast<unsigned>(std::bitset<64>(x).count());
#endif
}

// bit parity
inline bool poppar(uint64_t x)
{
    return popcnt(x) & 1u;
}

} // namespace Quantum
} // namespace Microsoft
