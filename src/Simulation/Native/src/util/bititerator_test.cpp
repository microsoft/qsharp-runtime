// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "bititerator.hpp"
#include "splitinterval.hpp"

#include <bitset>
#include <cassert>
#include <cstdint>
#include <vector>

// test against slower naive iterator
void bititerator_test(const std::vector<unsigned>& bits_to_iterate)
{
    using namespace Microsoft::Quantum;
    std::uint64_t init = (std::uint64_t)rand();
    std::bitset<64> initial(init);
    for (unsigned i : bits_to_iterate)
    {
        initial.set(i, false);
    }

    bititerator it(initial.to_ullong(), bits_to_iterate);
    for (std::uint64_t v = 0; v < (1 << bits_to_iterate.size()) - 1; ++v, ++it)
    {
        std::uint64_t res = sparse_map(bits_to_iterate, v, init);
        //assert(res == it.b);
    }
}

void bititerator_test_with_chuncks(const std::vector<unsigned>& bits_to_iterate)
{
    std::uint64_t init = (std::uint64_t)0;

    using namespace Microsoft::Quantum;
    std::vector<size_t> chunks = split_interval_in_chunks(1ull << bits_to_iterate.size(), 6);
    for (int i = 0; i < chunks.size() - 1; ++i)
    {
        std::uint64_t st = chunks[i];
        bititerator it(st, init, bits_to_iterate);
        for (std::uint64_t v = st; v < chunks[i + 1]; ++v, ++it)
        {
            std::uint64_t res = sparse_map(bits_to_iterate, v, init);
            //assert(res == it.b);
        }
    }
}

int main()
{
    bititerator_test_with_chuncks(std::vector<unsigned>{0, 1, 2, 3});
    bititerator_test(std::vector<unsigned>{0, 3, 4, 8});
    bititerator_test(std::vector<unsigned>{0, 1, 4, 7, 25, 63});

    return 0;
}
