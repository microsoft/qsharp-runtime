// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <iostream>
#include <vector>
#include <limits>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    // CQubitManager maintains mapping between user qubit objects and
    // underlying qubit identifiers (Ids). When user program allocates
    // a qubit, Qubit Manager decides whether to allocate a fresh id or
    // reuse existing id that was previously freed. When user program
    // releases a qubit, Qubit Manager tracks it as a free qubit id.
    // Decision to reuse a qubit id is influenced by restricted reuse
    // areas. When a qubit id is freed in one section of a restricted
    // reuse area, it cannot be reused in other section of the same area.
    // Borrowing of qubits is not supported and is currently implemented
    // as plain allocation.
    class QIR_SHARED_API CQubitManager
    {
    public:
        using QubitIdType = ::int32_t;

        // We want status array to be reasonably large.
        constexpr static QubitIdType DefaultQubitCapacity = 8;

        // Indexes in the status array can potentially be in range 0 .. QubitIdType.MaxValue-1.
        // This gives maximum capacity as QubitIdType.MaxValue.
        // Index equal to int.MaxValue doesn't exist and is reserved for 'NoneMarker' - list terminator.
        constexpr static QubitIdType MaximumQubitCapacity = std::numeric_limits<QubitIdType>::max();

    public:
        CQubitManager(
            QubitIdType initialQubitCapacity = DefaultQubitCapacity,
            bool mayExtendCapacity = true,
            bool encourageReuse = true);

        // No complex scenarios for now. Don't need to support copying/moving.
        CQubitManager(const CQubitManager&) = delete;
        CQubitManager& operator = (const CQubitManager&) = delete;
        virtual ~CQubitManager();

        // Restricted reuse area control
        void StartRestrictedReuseArea();
        void NextRestrictedReuseSegment();
        void EndRestrictedReuseArea();

        // Allocate a qubit. Extend capacity if necessary and possible.
        // Fail if the qubit cannot be allocated.
        // Computation complexity is O(number of nested restricted reuse areas).
        Qubit Allocate();
        // Allocate qubitCountToAllocate qubits and store them in the provided array. Extend manager capacity if necessary and possible.
        // Fail without allocating any qubits if the qubits cannot be allocated.
        // Caller is responsible for providing array of sufficient size to hold qubitCountToAllocate.
        void Allocate(Qubit* qubitsToAllocate, int qubitCountToAllocate);

        // Releases a given qubit.
        void Release(Qubit qubit);
        // Releases qubitCountToRelease qubits in the provided array.
        // Caller is responsible for managing memory used by the array itself (i.e. delete[] array if it was dynamically allocated).
        void Release(Qubit* qubitsToRelease, int qubitCountToRelease);

        // Borrow (We treat borrowing as allocation currently)
        Qubit Borrow();
        void Borrow(Qubit* qubitsToBorrow, int qubitCountToBorrow);
        // Return (We treat returning as release currently)
        void Return(Qubit qubit);
        void Return(Qubit* qubitsToReturn, int qubitCountToReturn);

        // Disables a given qubit.
        // Once a qubit is disabled it can never be "enabled" or reallocated.
        void Disable(Qubit qubit);
        // Disables a set of given qubits.
        // Once a qubit is disabled it can never be "enabled" or reallocated.
        void Disable(Qubit* qubitsToDisable, int qubitCountToDisable);

        bool IsValid(Qubit qubit) const;
        bool IsDisabled(Qubit qubit) const;
        bool IsFree(Qubit qubit) const;

        // May be overriden to create a custom Qubit object.
        // When not overriden, it just stores qubit Id in place of a pointer to a qubit.
        // id: unique qubit id
        // Returns a newly instantiated qubit.
        virtual Qubit CreateQubitObject(QubitIdType id);

        // May be overriden to get a qubit id from a custom qubit object.
        // Must be overriden if CreateQubitObject is overriden.
        // When not overriden, it just reinterprets pointer to qubit as a qubit id.
        // qubit: pointer to QUBIT
        // Returns id of a qubit pointed to by qubit.
        virtual QubitIdType QubitToId(Qubit qubit) const;

        // Qubit counts
        int GetDisabledQubitCount() const { return disabledQubitCount; }
        int GetAllocatedQubitCount() const { return allocatedQubitCount; }
        int GetFreeQubitCount() const { return freeQubitCount; }

        bool GetMayExtendCapacity() const { return mayExtendCapacity; }
        bool GetEncourageReuse() const { return encourageReuse; }

    private:
        // The end of free lists are marked with NoneMarker value. It is used like null for pointers.
        // This value is non-negative just like other values in the free lists.
        constexpr static QubitIdType NoneMarker = std::numeric_limits<QubitIdType>::max();

        // Explicitly allocated qubits are marked with AllocatedMarker value.
        // If borrowing is implemented, negative values may be used for refcounting.
        constexpr static QubitIdType AllocatedMarker = std::numeric_limits<QubitIdType>::min();

        // Disabled qubits are marked with this value.
        constexpr static QubitIdType DisabledMarker = -1;

        // QubitListInSharedArray implements a singly-linked list with "pointers" to the first and the last element stored.
        // Pointers are the indexes in a shared array. Shared array isn't sotored in this class because it can be reallocated.
        // This class maintains status of elements in the list by virtue of linking them as part of this list.
        // This class doesn't update status of elementes excluded from the list.
        // This class is small, contains no C++ pointers and relies on default shallow copying/destruction.
        struct QubitListInSharedArray final
        {
        private:
            QubitIdType firstElement = NoneMarker;
            QubitIdType lastElement = NoneMarker;
            // We are not storing pointer to shared array because it can be reallocated.
            // Indexes and special values remain the same on such reallocations.

        public:
            // Initialize empty list
            QubitListInSharedArray() = default;

            // Initialize as a list with sequential elements from startId to endId inclusve.
            QubitListInSharedArray(QubitIdType startId, QubitIdType endId, QubitIdType* sharedQubitStatusArray);

            bool IsEmpty() const;
            void AddQubit(QubitIdType id, bool addToFront, QubitIdType* sharedQubitStatusArray);
            QubitIdType TakeQubitFromFront(QubitIdType* sharedQubitStatusArray);
            void MoveAllQubitsFrom(QubitListInSharedArray& source, QubitIdType* sharedQubitStatusArray);
        };

        // Restricted reuse area consists of multiple segments. Qubits released in one segment cannot be reused in another.
        // One restricted reuse area can be nested in a segment of another restricted reuse area.
        // This class tracks current segment of an area. Previous segments are tracked collectively (not individually).
        // This class is small, contains no C++ pointers and relies on default shallow copying/destruction.
        struct RestrictedReuseArea final
        {
        public:
            QubitListInSharedArray FreeQubitsReuseProhibited;
            QubitListInSharedArray FreeQubitsReuseAllowed;

            RestrictedReuseArea() = default;
            RestrictedReuseArea(QubitListInSharedArray freeQubits);
        };

        // This is NOT a pure stack! We modify it only by push/pop, but we also iterate over elements.
        class CRestrictedReuseAreaStack final : public std::vector<RestrictedReuseArea>
        {
        public:
            // No complex scenarios for now. Don't need to support copying/moving.
            CRestrictedReuseAreaStack() = default;
            CRestrictedReuseAreaStack(const CRestrictedReuseAreaStack&) = delete;
            CRestrictedReuseAreaStack& operator = (const CRestrictedReuseAreaStack&) = delete;
            ~CRestrictedReuseAreaStack() = default;

            void PushToBack(RestrictedReuseArea area);
            RestrictedReuseArea PopFromBack();
            RestrictedReuseArea& PeekBack();
            int Count() const;
        };

    private:
        void EnsureCapacity(QubitIdType requestedCapacity);

        QubitIdType AllocateQubitId();
        void ReleaseQubitId(QubitIdType id);
        void ChangeStatusToAllocated(QubitIdType id);
        void Release(QubitIdType id);

        bool IsDisabled(QubitIdType id) const;
        bool IsExplicitlyAllocated(QubitIdType id) const;
        bool IsFree(QubitIdType id) const;

        // Configuration Properties
        bool mayExtendCapacity = true;
        bool encourageReuse = true;

        // State
        QubitIdType* sharedQubitStatusArray = nullptr; // Tracks allocation state of all qubits. Stores lists of free qubits.
        QubitIdType qubitCapacity = 0; // qubitCapacity is always equal to the array size.
        CRestrictedReuseAreaStack freeQubitsInAreas; // Fresh Free Qubits are located in freeQubitsInAreas[0].FreeQubitsReuseAllowed

        // Counts
        int disabledQubitCount = 0;
        int allocatedQubitCount = 0;
        int freeQubitCount = 0;
    };

}
}
