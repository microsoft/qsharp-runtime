// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#pragma once

#include <bitset>
#include <cassert>
#include <cstdint>
#include <vector>

namespace Microsoft
{
namespace Quantum
{
static std::vector<unsigned> complement(const std::vector<unsigned>& bit_positions, unsigned highest_bit)
{
    const unsigned max_bit_size = 64;
    assert(highest_bit <= max_bit_size);
    std::bitset<max_bit_size> mask(0);
    std::vector<unsigned> res;
    for (unsigned i : bit_positions)
    {
        assert(i < max_bit_size);
        mask.set(i);
    }

    for (unsigned i = 0; i < highest_bit; ++i)
    {
        if (!mask[i])
        {
            res.push_back(i);
        }
    }
    return res;
}

// returns uint64_t that is equal to rest,
// except bits listed in bits_to_set.
// Bit number bits_to_set[k] of the result
// is set to bit k of from.
static std::uint64_t sparse_map(std::vector<unsigned> bits_to_set, std::uint64_t from, std::uint64_t rest)
{
    std::bitset<64> source(from);
    std::bitset<64> res(rest);

    for (size_t i = 0; i < bits_to_set.size(); ++i)
    {
        res.set(bits_to_set[i], source[i]);
    }

    return res.to_ullong();
}

// The iterator computes the next bit-string
// b_next such that it is the next one after b with
// respect to lexicographical order, given
// the bits at positions except given by bits_positions_to_iterate are
// constant.
// For example, consider bit-string 0111 and
// suppose the bits 0 and 3 must be iterated over, then
// the next bit-string is 1110.
// The operation `++` takes constant time.
struct bititerator
{
    std::uint64_t b;
    std::uint64_t const_bits_mask;
    std::uint64_t mask_values;

    bititerator(std::uint64_t start, const std::vector<unsigned>& bits_positions_to_iterate) : b(start)
    {
        const unsigned bitsize = sizeof(b) * 8;
        std::vector<unsigned> const_bits_positions = complement(bits_positions_to_iterate, bitsize);

        std::bitset<bitsize> const_bits(0);
        for (unsigned x : const_bits_positions)
        {
            const_bits.set(x);
        }

        const_bits_mask = const_bits.to_ullong();

        std::bitset<bitsize> start_bits(start);
        std::bitset<bitsize> mask(0);
        mask.flip();
        for (unsigned x : const_bits_positions)
        {
            mask.set(x, start_bits[x]);
        }
        mask_values = mask.to_ullong();
    }

    bititerator(std::uint64_t start_for_bits_to_iterate,
                std::uint64_t rest,
                const std::vector<unsigned>& bits_positions_to_iterate)
        : bititerator(sparse_map(bits_positions_to_iterate, start_for_bits_to_iterate, rest), bits_positions_to_iterate)
    {
    }

    bititerator& operator++()
    {
        b |= const_bits_mask;
        ++b;
        b |= const_bits_mask;
        b &= mask_values;
        return *this;
    }
};
}
}
