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

static void FailNow(const char* message)
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

QubitListInSharedArray::QubitListInSharedArray(QubitIdType startId, QubitIdType endId, QubitIdType* sharedQubitStatusArray)
{
    FailIf(startId > endId || startId < 0 || endId == std::numeric_limits<QubitIdType>::max(),
        "Incorrect boundaries in the linked list initialization.");

    for (QubitIdType i = startId; i < endId; i++) {
        sharedQubitStatusArray[i] = i + 1; // Current element points to the next element.
    }
    sharedQubitStatusArray[endId] = NoneMarker; // Last element ends the chain.
    firstElement = startId;
    lastElement = endId;
}

bool QubitListInSharedArray::IsEmpty() const
{
    return firstElement == NoneMarker;
}

void QubitListInSharedArray::AddQubit(QubitIdType id, bool addToFront, QubitIdType* sharedQubitStatusArray)
{
    FailIf(id == NoneMarker, "Incorrect qubit id, cannot add it to the list.");

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
QubitIdType QubitListInSharedArray::TakeQubitFromFront(QubitIdType* sharedQubitStatusArray)
{
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

void QubitListInSharedArray::MoveAllQubitsFrom(QubitListInSharedArray& source, QubitIdType* sharedQubitStatusArray)
{
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

RestrictedReuseArea::RestrictedReuseArea(QubitListInSharedArray freeQubits)
{
    //FreeQubitsReuseProhibited = QubitListInSharedArray(); // This is initialized by default.
    FreeQubitsReuseAllowed = freeQubits; // Default shallow copying.
}


//
// CRestrictedReuseAreaStack
//

void CRestrictedReuseAreaStack::PushToBack(RestrictedReuseArea area)
{
    FailIf(Count() >= std::numeric_limits<int>::max(), "Too many nested restricted reuse areas.");
    this->insert(this->end(), area);
}

RestrictedReuseArea CRestrictedReuseAreaStack::PopFromBack()
{
    FailIf(this->empty(), "Cannot remove element from empty set.");
    RestrictedReuseArea result = this->back();
    this->pop_back();
    return result;
}

RestrictedReuseArea& CRestrictedReuseAreaStack::PeekBack()
{
    return this->back();
}

int CRestrictedReuseAreaStack::Count() const
{
    return this->size();
}

//
// CQubitManager
//

CQubitManager::CQubitManager(
    QubitIdType initialQubitCapacity,
    bool mayExtendCapacity,
    bool encourageReuse)
{
    this->mayExtendCapacity = mayExtendCapacity;
    this->encourageReuse = encourageReuse;

    qubitCapacity = initialQubitCapacity;
    if (qubitCapacity <= 0) {
        qubitCapacity = DefaultQubitCapacity;
    }
    sharedQubitStatusArray = new QubitIdType[qubitCapacity];

    // These objects are passed by value (copies are created)
    QubitListInSharedArray FreeQubitsFresh(0, qubitCapacity - 1, sharedQubitStatusArray);
    RestrictedReuseArea outermostArea(FreeQubitsFresh);
    freeQubitsInAreas.PushToBack(outermostArea);

    allocatedQubitCount = 0;
    disabledQubitCount = 0;
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

void CQubitManager::Allocate(Qubit* qubitsToAllocate, int qubitCountToAllocate)
{
    FailIf(qubitCountToAllocate < 0, "Attempt to allocate negative number of qubits.");
    if (qubitCountToAllocate == 0)
    {
        return;
    }
    FailIf(qubitsToAllocate == nullptr, "No array provided for qubits to be allocated.");

    // Consider optimization for initial allocation of a large array at once
    for (int i = 0; i < qubitCountToAllocate; i++)
    {
        QubitIdType newQubitId = AllocateQubitId();
        if (newQubitId == NoneMarker)
        {
            for (int k = 0; k < i; k++)
            {
                Release(qubitsToAllocate[k]);
            }
            FailNow("Not enough qubits.");
            return;
        }
        ChangeStatusToAllocated(newQubitId);
        qubitsToAllocate[i] = CreateQubitObject(newQubitId);
    }
}

void CQubitManager::Release(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Qubit is not valid.");
    Release(QubitToId(qubit));
}

void CQubitManager::Release(Qubit* qubitsToRelease, int qubitCountToRelease) {
    FailIf(qubitCountToRelease < 0, "Attempt to release negative number of qubits.");
    if (qubitCountToRelease == 0)
    {
        return;
    }
    FailIf(qubitsToRelease == nullptr, "No array provided for qubits to be released.");

    for (int i = 0; i < qubitCountToRelease; i++)
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

void CQubitManager::Borrow(Qubit* qubitsToBorrow, int qubitCountToBorrow)
{
    // We don't support true borrowing/returning at the moment.
    return Allocate(qubitsToBorrow, qubitCountToBorrow);
}

void CQubitManager::Return(Qubit qubit)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubit);
}

void CQubitManager::Return(Qubit* qubitsToReturn, int qubitCountToReturn)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubitsToReturn, qubitCountToReturn);
}

void CQubitManager::Disable(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Invalid qubit.");
    QubitIdType id = QubitToId(qubit);
    // We can only disable explicitly allocated qubits that were not borrowed.
    FailIf(!IsExplicitlyAllocated(id), "Cannot disable qubit that is not explicitly allocated.");
    sharedQubitStatusArray[id] = DisabledMarker;
    disabledQubitCount++;

    allocatedQubitCount--;
    FailIf(allocatedQubitCount < 0, "Incorrect count of allocated qubits.");
}

void CQubitManager::Disable(Qubit* qubitsToDisable, int qubitCountToDisable)
{
    FailIf(qubitCountToDisable < 0, "Qubit count cannot be negative");
    if (qubitsToDisable == nullptr || qubitCountToDisable == 0)
    {
        return;
    }

    for (int i = 0; i < qubitCountToDisable; i++)
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

QubitIdType CQubitManager::QubitToId(Qubit qubit) const
{
    intptr_t pointerSizedId = reinterpret_cast<intptr_t>(qubit);
    FailIf(pointerSizedId < 0 || pointerSizedId > std::numeric_limits<QubitIdType>::max(), "Qubit id is out of range.");
    return static_cast<int>(pointerSizedId);
}

void CQubitManager::EnsureCapacity(QubitIdType requestedCapacity)
{
    // No need to adjust existing values (NonMarker or indexes in the array).
    // TODO: Borrowing/returning are not yet supported.
    if (requestedCapacity <= qubitCapacity)
    {
        return;
    }

    // Prepare new shared status array
    QubitIdType* newStatusArray = new QubitIdType[requestedCapacity];
    memcpy(newStatusArray, sharedQubitStatusArray, qubitCapacity * sizeof(newStatusArray[0]));
    QubitListInSharedArray newFreeQubits(qubitCapacity, requestedCapacity - 1, newStatusArray);

    // Set new data. All new qubits are added to the free qubits in the outermost area.
    freeQubitCount += requestedCapacity - qubitCapacity;
    delete[] sharedQubitStatusArray;
    sharedQubitStatusArray = newStatusArray;
    qubitCapacity = requestedCapacity;
    freeQubitsInAreas[0].FreeQubitsReuseAllowed.MoveAllQubitsFrom(newFreeQubits, sharedQubitStatusArray);
}

QubitIdType CQubitManager::AllocateQubitId()
{
    if (encourageReuse)
    {
        // When reuse is encouraged, we start with the innermost area
        for (int i = freeQubitsInAreas.Count() - 1; i >= 0; i--)
        {
            QubitIdType id = freeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker)
            {
                return id;
            }
        }
    } else
    {
        // When reuse is discouraged, we start with the outermost area
        for (int i = 0; i < freeQubitsInAreas.Count(); i++)
        {
            QubitIdType id = freeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker)
            {
                return id;
            }
        }
    }
    return NoneMarker;
}

void CQubitManager::ReleaseQubitId(QubitIdType id)
{
    // Released qubits are added to reuse area/segment in which they were released
    // (rather than area/segment where they are allocated).
    // Although counterintuitive, this makes code simple.
    // This is reasonable because we think qubits should be allocated and released in the same segment.
    freeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.AddQubit(id, encourageReuse, sharedQubitStatusArray);
}

void CQubitManager::ChangeStatusToAllocated(QubitIdType id)
{
    FailIf(id >= qubitCapacity, "Internal Error: Cannot change status of an invalid qubit.");
    sharedQubitStatusArray[id] = AllocatedMarker;
    allocatedQubitCount++;
    freeQubitCount--;
}

void CQubitManager::Release(QubitIdType id)
{
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
        ReleaseQubitId(id);
    }

    freeQubitCount++;
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
