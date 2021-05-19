// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <csignal>
#include <iostream>
#include <vector>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{

    // TODO: Remove this! Use standard ones.
    static void FailNow(const char* message) { std::cout << message; throw message; }
    static void FailIf(bool condition, const char* message) {
        if (condition) {
            FailNow(message);
        }
    }


    // TODO: Decide on the interface and move this to appropriate place.
    struct IQubitManager
    {
        virtual ~IQubitManager() = default;
        virtual Qubit Allocate() = 0;
        virtual void Release(Qubit qubit) = 0;
    };

    // The end of free lists are marked with NoneMarker value. It is used like null for pointers.
    // This value is non-negative just like other values in the free lists.
    constexpr int NoneMarker = INT_MAX;

    // Explicitly allocated qubits are marked with Allocated value.
    // Qubits implicitly allocated for borrowing are "refcounted" with values [Allocated+1 .. -2].
    // When refcount needs to be decreased to Allocated value, the qubit is automatically released.
    constexpr int AllocatedMarker = INT_MAX;

    // Disabled qubits are marked with this value.
    constexpr int DisabledMarker = -1;

    // We want status array to be reasonably large if initialization for it is wrong (i.e. requested size < 1).
    constexpr int FallbackQubitCapacity = 8;

    // Indexes in the status array can potentially be in range 0 .. long.MaxValue-1.
    // This gives maximum capacity as long.MaxValue.
    // Index equal to long.MaxValue doesn't exist and is reserved for 'NoneMarker' - list terminator.
    constexpr int MaximumQubitCapacity = INT_MAX;

    // QubitListInSharedArray implements a singly-linked list with "pointers" to the first and the last element stored.
    // Pointers are the indexes in a shared array. Shared array isn't sotored here because it can be reallocated.
    // This class maintains status of elements in the list by virtue of linking them as part of this list.
    // This class doesn't update status of elementes excluded from the list.
    // This class is small, contains no pointers and relies on default shallow copying/destruction.
    struct QubitListInSharedArray final
    {
    private:
        int firstElement = NoneMarker;
        int lastElement = NoneMarker;

    public:
        // Initialize empty list
        QubitListInSharedArray() = default;

        // Initialize as a list with sequential elements from minElement to maxElement inclusve.
        QubitListInSharedArray(int minElement, int maxElement, int* sharedQubitStatusArray);

        bool IsEmpty();
        void AddQubit(int id, bool addToFront, int* sharedQubitStatusArray);
        int TakeQubitFromFront(int* sharedQubitStatusArray);
        void MoveAllQubitsFrom(QubitListInSharedArray& source, int* sharedQubitStatusArray);
    };


    // Restricted reuse area consists of multiple segments. Qubits released in one segment cannot be reused in another.
    // One restricted reuse area can be nested in a segment of another restricted reuse area.
    // This class tracks current segment of an area. Previous segments are tracked collectively (not individually).
    // This class is small, contains no pointers and relies on default shallow copying/destruction.
    struct RestrictedReuseArea final
    {
    public:
        QubitListInSharedArray FreeQubitsReuseProhibited;
        QubitListInSharedArray FreeQubitsReuseAllowed;

        RestrictedReuseArea() = default;
        RestrictedReuseArea(QubitListInSharedArray freeQubits);
    };



    // This is NOT a stack! We modify it only by push/pop, but we also iterate over elements.
    // TODO: Better name?
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
        // TODO: Remove and use size directly?
        int Count();
    };

    class CQubitManagerRestrictedReuse : public IQubitManager
    {
        // Restricted reuse area control, allocation and release

        public: void StartRestrictedReuseArea();
        public: void NextRestrictedReuseSegment();
        public: void EndRestrictedReuseArea();
        private: long AllocateQubit(); // Computation complexity is O(number of nested restricted reuse areas).
        private: void ReleaseQubit(long id);

        // Configuration Properties

        // TODO: Make sure these are read only
        public: bool MayExtendCapacity;
        public: bool EncourageReuse;

        // Constructors/destructors, storage and reallocation

        private: int* sharedQubitStatusArray; // Tracks allocation state of all qubits. Stores lists of free qubits.
        private: int qubitCapacity = 0; // qubitCapacity is always equal to the array size.
        private: CRestrictedReuseAreaStack freeQubitsInAreas; // Fresh Free Qubits are located in freeQubitsInAreas[0].FreeQubitsReuseAllowed
        
        public: CQubitManagerRestrictedReuse(
            int initialQubitCapacity,
            bool mayExtendCapacity = false,
            bool encourageReuse = true);

        // No complex scenarios for now. Don't need to support copying/moving.
        public: CQubitManagerRestrictedReuse(const CQubitManagerRestrictedReuse&) = delete;
        public: CQubitManagerRestrictedReuse& operator = (const CQubitManagerRestrictedReuse&) = delete;
        public: ~CQubitManagerRestrictedReuse();
        private: void EnsureCapacity(int requestedCapacity);

        // Disable, disabled qubit count and checks

        public: int DisabledQubitsCount = 0;
        public: bool IsDisabled(int id);
        public: bool IsDisabled(Qubit qubit);
        // Disables a given qubit.
        // Once a qubit is disabled it can never be "enabled" or reallocated.
        public: void Disable(Qubit qubit);
        // Disables a set of given qubits.
        // Once a qubit is disabled it can never be "enabled" or reallocated.
        public: void Disable(Qubit* qubitsToDisable, int qubitCount);

        // Allocate, allocated qubit count and checks

        public: int AllocatedQubitsCount = 0;
        public: bool IsExplicitlyAllocated(long id);
        public: void ChangeStatusToAllocated(long id);
        // Allocates a qubit. Extend capacity if necessary and possible.
        // Fails if the qubit cannot be allocated. 
        public: Qubit Allocate();
        // Allocates numToAllocate new qubits. Extend capacity if necessary and possible.
        // Fails without allocating any qubits if the qubits cannot be allocated. 
        // Returned array of qubits must be passed to Release to release qubits and free memory use for array.
        public: Qubit* Allocate(long numToAllocate);

        // Release, free qubit count and checks

        public: long FreeQubitsCount = 0;
        public: bool IsFree(long id);
        public: bool IsFree(Qubit qubit);
        public: void Release(long id);
        // Releases a given qubit.
        public: void Release(Qubit qubit);
        // Releases an array of given qubits and deallocates array memory.
        public: void Release(Qubit* qubitsToRelease, int qubitCount);

        // Borrow (We treat borrowing as allocation currently)

        public: Qubit Borrow();
        public: Qubit* Borrow(long qubitCountToBorrow);

        // Return (We treat returning as release currently)

        public: void Return(Qubit qubit);
        public: void Return(Qubit* qubitsToReturn, int qubitCountToReturn);

        // Qubit creation, validity check

        public: bool IsValid(Qubit qubit);

        // May be overriden to create a custom Qubit object.
        // When not overriden, it just stores qubit Id in place of a pointer to a qubit.
        // id: unique qubit id
        // Returns a newly instantiated qubit.
        public: virtual Qubit CreateQubitObject(int id);

        // May be overriden to get a qubit id from a custom qubit object.
        // Must be overriden if CreateQubitObject is overriden.
        // When not overriden, it just reinterprets pointer to qubit as a qubit id.
        // qubit: pointer to QUBIT
        // Returns id of a qubit pointed to by qubit.
        public: virtual int QubitToId(Qubit qubit);
    };


}
}
