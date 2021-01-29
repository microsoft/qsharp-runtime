#pragma once

#include <cstdint>
#include <vector>

namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        Provides dynamically extendable storage for packed bits
    ==============================================================================*/
    struct BitStates
    {
        typedef uint64_t TSLOT;
        static constexpr int slotSizeBits = sizeof(TSLOT) * 8;

        std::vector<TSLOT> slots;

        static long GetSlotIndex(long bitIndex)
        {
            return (bitIndex / (slotSizeBits));
        }
        static long GetIndexInSlot(long bitIndex)
        {
            return (bitIndex & (slotSizeBits - 1));
        }

        void ExtendToInclude(long index)
        {
            long slotIndex = GetSlotIndex(index);
            for (long i = this->slots.size(); i < slotIndex + 1; i++)
            {
                this->slots.push_back(0);
            }
        }

        void Clear()
        {
            this->slots.clear();
        }

        void SetBitAt(long index)
        {
            const long slotIndex = GetSlotIndex(index);
            const long bitIndex = GetIndexInSlot(index);
            this->slots[slotIndex] |= (static_cast<TSLOT>(1) << bitIndex);
        }

        void FlipBitAt(long index)
        {
            const long slotIndex = GetSlotIndex(index);
            const long bitIndex = GetIndexInSlot(index);
            this->slots[slotIndex] ^= (static_cast<TSLOT>(1) << bitIndex);
        }

        bool IsBitSetAt(long index) const
        {
            const long slotIndex = GetSlotIndex(index);
            const long bitIndex = GetIndexInSlot(index);
            return this->slots[slotIndex] & (static_cast<TSLOT>(1) << bitIndex);
        }

        bool IsAny() const
        {
            for (long i = 0; i < this->slots.size(); i++)
            {
                if (this->slots[i] != 0)
                {
                    return true;
                }
            }
            return false;
        }
    };

} // namespace Quantum
} // namespace Microsoft