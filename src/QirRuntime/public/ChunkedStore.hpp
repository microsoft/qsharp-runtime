#pragma once

#include <assert.h>
#include <vector>

#include "BitStates.hpp"

namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        Provides dynamically extendable storage for TItem_WithId (usually, qubits)
        that never moves previously allocated items, meaning the address of the item
        can be safely used to access it until it's released.

        The backing memory is split into contiguous chunks of fixed size, but the
        chunks aren't guaranteed to be located next to each other.

        TItem_WithId must provide public field "id". The store uses the id as index
        to speedup look up of items.

        TODO:
        1. is it beneficial to release empty chunks?
        2. do we really need to store the id on the items?
        3. should we shrink chunks vector?
    ==============================================================================*/
    template <int COUNT_ITEMS, typename TItem> struct Chunk
    {
        static_assert(
            COUNT_ITEMS < sizeof(uint64_t) * 8 + 1,
            L"keeping track of filled should be reviewed if this assert fails");

        uint64_t filled = 0;
        TItem data[COUNT_ITEMS];

        bool IsValidItem(long index)
        {
            return (index < COUNT_ITEMS) && (filled & (static_cast<uint64_t>(1) << index));
        }
    };

    template <typename TItem_WithId> struct CChunkedStore
    {
        static constexpr int items_in_chunk = 64;
        std::vector<Chunk<items_in_chunk, TItem_WithId>*> chunks;

        static long GetChunkIndex(long id)
        {
            return (id / items_in_chunk);
        }
        static long GetIndexInChunk(long id)
        {
            return (id & (items_in_chunk - 1));
        }

        CChunkedStore() = default;
        ~CChunkedStore()
        {
            for (Chunk<items_in_chunk, TItem_WithId>* chunk : this->chunks)
            {
                delete chunk;
            }
        }

        std::vector<TItem_WithId*> GetAllItems()
        {
            std::vector<TItem_WithId*> items;
            items.reserve(this->chunks.size() * items_in_chunk);
            for (size_t chunkIndex = 0; chunkIndex < this->chunks.size(); chunkIndex++)
            {
                if (this->chunks[chunkIndex] == nullptr)
                {
                    continue;
                }
                for (int i = 0; i < items_in_chunk; i++)
                {
                    if (this->chunks[chunkIndex]->IsValidItem(i))
                    {
                        items.push_back(&(this->chunks[chunkIndex]->data[i]));
                    }
                }
            }

            return items;
        }

        TItem_WithId* Allocate(long id)
        {
            const long chunkIndex = GetChunkIndex(id);
            if (chunkIndex >= this->chunks.size())
            {
                this->chunks.reserve(chunkIndex + 1);
                for (long i = this->chunks.size(); i <= chunkIndex; i++)
                {
                    this->chunks.push_back(nullptr);
                }
            }

            if (this->chunks[chunkIndex] == nullptr)
            {
                this->chunks[chunkIndex] = new Chunk<items_in_chunk, TItem_WithId>();
            }

            const long indexInChunk = GetIndexInChunk(id);
            assert(!(this->chunks[chunkIndex]->filled & (1 << indexInChunk)));
            this->chunks[chunkIndex]->filled |= (1 << indexInChunk);
            this->chunks[chunkIndex]->data[indexInChunk].id = id;

            return &(this->chunks[chunkIndex]->data[GetIndexInChunk(id)]);
        }

        void Release(TItem_WithId* item)
        {
            const long chunkIndex = GetChunkIndex(item->id);
            assert(chunkIndex < this->chunks.size());
            assert(this->chunks[chunkIndex] != nullptr);

            const long indexInChunk = GetIndexInChunk(item->id);
            assert(this->chunks[chunkIndex]->filled & (1 << indexInChunk));
            this->chunks[chunkIndex]->filled ^= (1 << indexInChunk);

            if (this->chunks[chunkIndex]->filled == 0)
            {
                delete this->chunks[chunkIndex];
                this->chunks[chunkIndex] = nullptr;
            }
        }
    };

} // namespace Quantum
} // namespace Microsoft