// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "QubitManager.hpp"
#include "QirRuntime.hpp" // For quantum__rt__fail_cstr
#include <cstring> // For memcpy

namespace Microsoft
{
namespace Quantum
{

//
// Failing in case of errors
//

[[noreturn]] static void FailNow(const char* message)
{
     quantum__rt__fail_cstr(message);
}

static void FailIf(bool condition, const char* message)
{
    if (condition)
    {
        quantum__rt__fail_cstr(message);
    }
}

//
// QubitListInSharedArray
//

CQubitManager::QubitListInSharedArray::QubitListInSharedArray(
    QubitIdType startId,
    QubitIdType endId,
    QubitIdType* sharedQubitStatusArray):
        firstElement(startId),
        lastElement(endId)
{
    FailIf(startId > endId || startId < 0 || endId == MaximumQubitCapacity,
        "Incorrect boundaries in the linked list initialization.");
    FailIf(sharedQubitStatusArray == nullptr, "Shared status array is not provided.");

    for (QubitIdType i = startId; i < endId; i++) {
        sharedQubitStatusArray[i] = i + 1; // Current element points to the next element.
    }
    sharedQubitStatusArray[endId] = NoneMarker; // Last element ends the chain.
}

bool CQubitManager::QubitListInSharedArray::IsEmpty() const
{
    return firstElement == NoneMarker;
}

void CQubitManager::QubitListInSharedArray::AddQubit(QubitIdType id, bool addToFront, QubitIdType* sharedQubitStatusArray)
{
    FailIf(id == NoneMarker, "Incorrect qubit id, cannot add it to the list.");
    FailIf(sharedQubitStatusArray == nullptr, "Shared status array is not provided.");

    // If the list is empty, we initialize it with the new element.
    if (IsEmpty())
    {
        firstElement = id;
        lastElement = id;
        sharedQubitStatusArray[id] = NoneMarker; // List with a single elemenet in the chain.
        return;
    }

    if (addToFront)
    {
        sharedQubitStatusArray[id] = firstElement; // The new element will point to the former first element.
        firstElement = id; // The new element is now the first in the chain.
    } else
    {
        sharedQubitStatusArray[lastElement] = id; // The last element will point to the new element.
        sharedQubitStatusArray[id] = NoneMarker; // The new element will end the chain.
        lastElement = id; // The new element will be the last element in the chain.
    }
}

// TODO: Set status to the taken qubit here. Then counting is reasonable here, but not possible?
// TODO: Rename 'RemoveQubitFromFront'?
CQubitManager::QubitIdType CQubitManager::QubitListInSharedArray::TakeQubitFromFront(QubitIdType* sharedQubitStatusArray)
{
    FailIf(sharedQubitStatusArray == nullptr, "Shared status array is not provided.");

    // First element will be returned. It is 'NoneMarker' if the list is empty.
    QubitIdType result = firstElement;

    // Advance list start to the next element if list is not empty.
    if (!IsEmpty())
    {
        firstElement = sharedQubitStatusArray[firstElement]; // The second element will be the first.
    }

    // Drop pointer to the last element if list becomes empty.
    if (IsEmpty())
    {
        lastElement = NoneMarker;
    }

    return result;
}

void CQubitManager::QubitListInSharedArray::MoveAllQubitsFrom(QubitListInSharedArray& source, QubitIdType* sharedQubitStatusArray)
{
    FailIf(sharedQubitStatusArray == nullptr, "Shared status array is not provided.");

    // No need to do anthing if source is empty.
    if (source.IsEmpty())
    {
        return;
    }

    if (this->IsEmpty())
    {
        // If this list is empty, we'll just set it to the source list.
        lastElement = source.lastElement;
    } else
    {
        // Attach source at the beginning of the list if both lists aren't empty.
        sharedQubitStatusArray[source.lastElement] = firstElement; // The last element of the source chain will point to the first element of this chain.
    }
    firstElement = source.firstElement; // The first element from the source chain will be the first element of this chain.

    // Remove all elements from source.
    source.firstElement = NoneMarker;
    source.lastElement = NoneMarker;
}


//
// RestrictedReuseArea
//

CQubitManager::RestrictedReuseArea::RestrictedReuseArea(
    QubitListInSharedArray freeQubits):
        FreeQubitsReuseProhibited(), // Default costructor
        FreeQubitsReuseAllowed(freeQubits) // Default shallow copy.
{
}


//
// CRestrictedReuseAreaStack
//

void CQubitManager::CRestrictedReuseAreaStack::PushToBack(RestrictedReuseArea area)
{
    FailIf(Count() >= std::numeric_limits<int32_t>::max(), "Too many nested restricted reuse areas.");
    this->insert(this->end(), area);
}

CQubitManager::RestrictedReuseArea CQubitManager::CRestrictedReuseAreaStack::PopFromBack()
{
    FailIf(this->empty(), "Cannot remove restricted reuse area from an empty set.");
    RestrictedReuseArea result = this->back();
    this->pop_back();
    return result;
}

CQubitManager::RestrictedReuseArea& CQubitManager::CRestrictedReuseAreaStack::PeekBack()
{
    return this->back();
}

int32_t CQubitManager::CRestrictedReuseAreaStack::Count() const
{
    // The size should never exceed int32_t.
    return static_cast<int32_t>(this->size());
}

//
// CQubitManager
//

CQubitManager::CQubitManager(
    QubitIdType initialQubitCapacity,
    bool mayExtendCapacity,
    bool encourageReuse):
        mayExtendCapacity(mayExtendCapacity),
        encourageReuse(encourageReuse),
        qubitCapacity(initialQubitCapacity)
{
    FailIf(qubitCapacity <= 0, "Qubit capacity must be positive.");
    sharedQubitStatusArray = new QubitIdType[qubitCapacity];

    // These objects are passed by value (copies are created)
    QubitListInSharedArray FreeQubitsFresh(0, qubitCapacity - 1, sharedQubitStatusArray);
    RestrictedReuseArea outermostArea(FreeQubitsFresh);
    freeQubitsInAreas.PushToBack(outermostArea);

    freeQubitCount = qubitCapacity;
}

CQubitManager::~CQubitManager()
{
    if (sharedQubitStatusArray != nullptr)
    {
        delete[] sharedQubitStatusArray;
        sharedQubitStatusArray = nullptr;
    }
    // freeQubitsInAreas - direct member of the class, no need to delete.
}

// Although it is not necessary to pass area IDs to these functions, such support may be added for extra checks.
void CQubitManager::StartRestrictedReuseArea()
{
    RestrictedReuseArea newArea;
    freeQubitsInAreas.PushToBack(newArea);
}

void CQubitManager::NextRestrictedReuseSegment()
{
    FailIf(freeQubitsInAreas.Count() <= 0, "Internal error! No reuse areas.");
    FailIf(freeQubitsInAreas.Count() == 1, "NextRestrictedReuseSegment() without an active area.");
    RestrictedReuseArea& currentArea = freeQubitsInAreas.PeekBack();
    // When new segment starts, reuse of all free qubits in the current area becomes prohibited.
    currentArea.FreeQubitsReuseProhibited.MoveAllQubitsFrom(currentArea.FreeQubitsReuseAllowed, sharedQubitStatusArray);
}

void CQubitManager::EndRestrictedReuseArea()
{
    FailIf(freeQubitsInAreas.Count() < 2, "EndRestrictedReuseArea() without an active area.");
    RestrictedReuseArea areaAboutToEnd = freeQubitsInAreas.PopFromBack();
    RestrictedReuseArea& containingArea = freeQubitsInAreas.PeekBack();
    // When area ends, reuse of all free qubits from this area becomes allowed.
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseProhibited, sharedQubitStatusArray);
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseAllowed, sharedQubitStatusArray);
}

Qubit CQubitManager::Allocate()
{
    QubitIdType newQubitId = AllocateQubitId();
    if (newQubitId == NoneMarker && mayExtendCapacity)
    {
        QubitIdType newQubitCapacity = qubitCapacity * 2;
        FailIf(newQubitCapacity <= qubitCapacity, "Cannot extend capacity.");
        EnsureCapacity(newQubitCapacity);
        newQubitId = AllocateQubitId();
    }
    FailIf(newQubitId == NoneMarker, "Not enough qubits.");
    ChangeStatusToAllocated(newQubitId);
    return CreateQubitObject(newQubitId);
}

void CQubitManager::Allocate(Qubit* qubitsToAllocate, int32_t qubitCountToAllocate)
{
    if (qubitCountToAllocate == 0)
    {
        return;
    }
    FailIf(qubitCountToAllocate < 0, "Cannot allocate negative number of qubits.");
    FailIf(qubitsToAllocate == nullptr, "No array provided for qubits to be allocated.");

    // Consider optimization for initial allocation of a large array at once
    for (int32_t i = 0; i < qubitCountToAllocate; i++)
    {
        QubitIdType newQubitId = AllocateQubitId();
        if (newQubitId == NoneMarker)
        {
            for (int32_t k = 0; k < i; k++)
            {
                Release(qubitsToAllocate[k]);
            }
            FailNow("Not enough qubits.");
        }
        ChangeStatusToAllocated(newQubitId);
        qubitsToAllocate[i] = CreateQubitObject(newQubitId);
    }
}

void CQubitManager::Release(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Qubit is not valid.");
    ReleaseQubitId(QubitToId(qubit));
}

void CQubitManager::Release(Qubit* qubitsToRelease, int32_t qubitCountToRelease) {
    if (qubitCountToRelease == 0)
    {
        return;
    }
    FailIf(qubitCountToRelease < 0, "Cannot release negative number of qubits.");
    FailIf(qubitsToRelease == nullptr, "No array provided with qubits to be released.");

    for (int32_t i = 0; i < qubitCountToRelease; i++)
    {
        Release(qubitsToRelease[i]);
        qubitsToRelease[i] = nullptr;
    }
}

Qubit CQubitManager::Borrow()
{
    // We don't support true borrowing/returning at the moment.
    return Allocate();
}

void CQubitManager::Borrow(Qubit* qubitsToBorrow, int32_t qubitCountToBorrow)
{
    // We don't support true borrowing/returning at the moment.
    return Allocate(qubitsToBorrow, qubitCountToBorrow);
}

void CQubitManager::Return(Qubit qubit)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubit);
}

void CQubitManager::Return(Qubit* qubitsToReturn, int32_t qubitCountToReturn)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubitsToReturn, qubitCountToReturn);
}

void CQubitManager::Disable(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Qubit is not valid.");
    QubitIdType id = QubitToId(qubit);

    // We can only disable explicitly allocated qubits that were not borrowed.
    FailIf(!IsExplicitlyAllocated(id), "Cannot disable qubit that is not explicitly allocated.");
    sharedQubitStatusArray[id] = DisabledMarker;

    disabledQubitCount++;
    FailIf(disabledQubitCount <= 0, "Incorrect disabled qubit count.");
    allocatedQubitCount--;
    FailIf(allocatedQubitCount < 0, "Incorrect allocated qubit count.");
}

void CQubitManager::Disable(Qubit* qubitsToDisable, int32_t qubitCountToDisable)
{
    if (qubitCountToDisable == 0)
    {
        return;
    }
    FailIf(qubitCountToDisable < 0, "Cannot disable negative number of qubits.");
    FailIf(qubitsToDisable == nullptr, "No array provided with qubits to be disabled.");

    for (int32_t i = 0; i < qubitCountToDisable; i++)
    {
        Disable(qubitsToDisable[i]);
    }
}

bool CQubitManager::IsValid(Qubit qubit) const
{
    QubitIdType id = QubitToId(qubit);
    if (id >= qubitCapacity)
    {
        return false;
    }
    if (id < 0)
    {
        return false;
    }
    return true;
}

bool CQubitManager::IsDisabled(Qubit qubit) const
{
    return IsValid(qubit) && IsDisabled(QubitToId(qubit));
}

bool CQubitManager::IsFree(Qubit qubit) const
{
    return IsValid(qubit) && IsFree(QubitToId(qubit));
}

Qubit CQubitManager::CreateQubitObject(QubitIdType id)
{
    FailIf(id < 0 || id > INTPTR_MAX, "Qubit id is out of range.");
    intptr_t pointerSizedId = static_cast<intptr_t>(id);
    return reinterpret_cast<Qubit>(pointerSizedId);
}

CQubitManager::QubitIdType CQubitManager::QubitToId(Qubit qubit) const
{
    intptr_t pointerSizedId = reinterpret_cast<intptr_t>(qubit);
    FailIf(pointerSizedId < 0 || pointerSizedId > std::numeric_limits<QubitIdType>::max(), "Qubit id is out of range.");
    return static_cast<QubitIdType>(pointerSizedId);
}

void CQubitManager::EnsureCapacity(QubitIdType requestedCapacity)
{
    FailIf(requestedCapacity <= 0, "Requested qubit capacity must be positive.");
    if (requestedCapacity <= qubitCapacity)
    {
        return;
    }
    // We need to reallocate shared status array, but there's no need to adjust
    // existing values (NonMarker or indexes in the array).

    // Prepare new shared status array
    QubitIdType* newStatusArray = new QubitIdType[requestedCapacity];
    memcpy(newStatusArray, sharedQubitStatusArray, qubitCapacity * sizeof(newStatusArray[0]));
    QubitListInSharedArray newFreeQubits(qubitCapacity, requestedCapacity - 1, newStatusArray);

    // Set new data. All fresh new qubits are added to the free qubits in the outermost area.
    freeQubitCount += requestedCapacity - qubitCapacity;
    FailIf(freeQubitCount <= 0, "Incorrect free qubit count.");
    delete[] sharedQubitStatusArray;
    sharedQubitStatusArray = newStatusArray;
    qubitCapacity = requestedCapacity;
    freeQubitsInAreas[0].FreeQubitsReuseAllowed.MoveAllQubitsFrom(newFreeQubits, sharedQubitStatusArray);
}

CQubitManager::QubitIdType CQubitManager::AllocateQubitId()
{
    if (encourageReuse)
    {
        // When reuse is encouraged, we start with the innermost area
        for (CRestrictedReuseAreaStack::reverse_iterator rit = freeQubitsInAreas.rbegin(); rit != freeQubitsInAreas.rend(); ++rit)
        {
            QubitIdType id = rit->FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker)
            {
                return id;
            }
        }
    } else
    {
        // When reuse is discouraged, we start with the outermost area
        for (CRestrictedReuseAreaStack::iterator it = freeQubitsInAreas.begin(); it != freeQubitsInAreas.end(); ++it)
        {
            QubitIdType id = it->FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker)
            {
                return id;
            }
        }
    }
    return NoneMarker;
}

void CQubitManager::ChangeStatusToAllocated(QubitIdType id)
{
    FailIf(id < 0 || id >= qubitCapacity, "Internal Error: Cannot change status of an invalid qubit.");
    sharedQubitStatusArray[id] = AllocatedMarker;
    allocatedQubitCount++;
    FailIf(allocatedQubitCount <= 0, "Incorrect allocated qubit count.");
    freeQubitCount--;
    FailIf(freeQubitCount < 0, "Incorrect free qubit count.");
}

void CQubitManager::ReleaseQubitId(QubitIdType id)
{
    FailIf(id < 0 || id >= qubitCapacity, "Internal Error: Cannot release an invalid qubit.");
    if (IsDisabled(id))
    {
        // Nothing to do. Qubit will stay disabled.
        return;
    }

    FailIf(!IsExplicitlyAllocated(id), "Attempt to free qubit that has not been allocated.");

    if (mayExtendCapacity && !encourageReuse)
    {
        // We can extend capcity and don't want reuse => Qubits will never be reused => Discard qubit.
        // We put it in its own "free" list, this list will never be found again and qubit will not be reused.
        sharedQubitStatusArray[id] = NoneMarker;
    } else
    {
        // Released qubits are added to reuse area/segment in which they were released
        // (rather than area/segment where they are allocated).
        // Although counterintuitive, this makes code simple.
        // This is reasonable because qubits should be allocated and released in the same segment. (This is not enforced)
        freeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.AddQubit(id, encourageReuse, sharedQubitStatusArray);
    }

    freeQubitCount++;
    FailIf(freeQubitCount <= 0, "Incorrect free qubit count.");
    allocatedQubitCount--;
    FailIf(allocatedQubitCount < 0, "Incorrect allocated qubit count.");
}

bool CQubitManager::IsDisabled(QubitIdType id) const
{
    return sharedQubitStatusArray[id] == DisabledMarker;
}

bool CQubitManager::IsExplicitlyAllocated(QubitIdType id) const
{
    return sharedQubitStatusArray[id] == AllocatedMarker;
}

bool CQubitManager::IsFree(QubitIdType id) const
{
    return sharedQubitStatusArray[id] >= 0;
}

}
}
