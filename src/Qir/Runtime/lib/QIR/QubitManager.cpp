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

void CQubitManager::QubitListInSharedArray::AddQubit(QubitIdType id, QubitIdType* sharedQubitStatusArray)
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

    sharedQubitStatusArray[id] = firstElement; // The new element will point to the former first element.
    firstElement = id; // The new element is now the first in the chain.
}

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

    if (result != NoneMarker)
    {
        sharedQubitStatusArray[result] = AllocatedMarker;
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
    bool mayExtendCapacity):
        mayExtendCapacity(mayExtendCapacity),
        qubitCapacity(initialQubitCapacity)
{
    FailIf(qubitCapacity <= 0, "Qubit capacity must be positive.");
    sharedQubitStatusArray = new QubitIdType[(size_t)qubitCapacity];

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
    FailIf(freeQubitsInAreas.Count() <= 0, "Internal error! No reuse areas.");
    RestrictedReuseArea areaAboutToBegin;
    RestrictedReuseArea& currentArea = freeQubitsInAreas.PeekBack();
    if (currentArea.FreeQubitsReuseAllowed.IsEmpty())
    {
        areaAboutToBegin.prevAreaWithFreeQubits = currentArea.prevAreaWithFreeQubits;
    } else
    {
        areaAboutToBegin.prevAreaWithFreeQubits = freeQubitsInAreas.Count() - 1;
    }
    freeQubitsInAreas.PushToBack(areaAboutToBegin);
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
    if (areaAboutToEnd.prevAreaWithFreeQubits < containingArea.prevAreaWithFreeQubits) {
        containingArea.prevAreaWithFreeQubits = areaAboutToEnd.prevAreaWithFreeQubits;
    }
    // When area ends, reuse of all free qubits from this area becomes allowed.
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseProhibited, sharedQubitStatusArray);
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseAllowed, sharedQubitStatusArray);
}

Qubit CQubitManager::Allocate()
{
    QubitIdType newQubitId = AllocateQubitId();
    FailIf(newQubitId == NoneMarker, "Not enough qubits.");
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
        qubitsToAllocate[i] = CreateQubitObject(newQubitId);
    }
}

void CQubitManager::Release(Qubit qubit)
{
    FailIf(!IsValidQubit(qubit), "Qubit is not valid.");
    ReleaseQubitId(QubitToId(qubit));
    DeleteQubitObject(qubit);
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
    FailIf(!IsValidQubit(qubit), "Qubit is not valid.");
    QubitIdType id = QubitToId(qubit);

    // We can only disable explicitly allocated qubits that were not borrowed.
    FailIf(!IsExplicitlyAllocatedId(id), "Cannot disable qubit that is not explicitly allocated.");
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

bool CQubitManager::IsValidId(QubitIdType id) const
{
    return (id >= 0) && (id < qubitCapacity);
}

bool CQubitManager::IsDisabledId(QubitIdType id) const
{
    return sharedQubitStatusArray[id] == DisabledMarker;
}

bool CQubitManager::IsExplicitlyAllocatedId(QubitIdType id) const
{
    return sharedQubitStatusArray[id] == AllocatedMarker;
}

bool CQubitManager::IsFreeId(QubitIdType id) const
{
    return sharedQubitStatusArray[id] >= 0;
}


bool CQubitManager::IsValidQubit(Qubit qubit) const
{
    return IsValidId(QubitToId(qubit));
}

bool CQubitManager::IsDisabledQubit(Qubit qubit) const
{
    return IsValidQubit(qubit) && IsDisabledId(QubitToId(qubit));
}

bool CQubitManager::IsExplicitlyAllocatedQubit(Qubit qubit) const
{
    return IsValidQubit(qubit) && IsExplicitlyAllocatedId(QubitToId(qubit));
}

bool CQubitManager::IsFreeQubitId(QubitIdType id) const
{
    return IsValidId(id) && IsFreeId(id);
}

CQubitManager::QubitIdType CQubitManager::GetQubitId(Qubit qubit) const
{
    FailIf(!IsValidQubit(qubit), "Not a valid qubit.");
    return QubitToId(qubit);
}


Qubit CQubitManager::CreateQubitObject(QubitIdType id)
{
    // Make sure the static_cast won't overflow:
    FailIf(id < 0 || id >= MaximumQubitCapacity, "Qubit id is out of range.");
    intptr_t pointerSizedId = static_cast<intptr_t>(id);
    return reinterpret_cast<Qubit>(pointerSizedId);
}

void CQubitManager::DeleteQubitObject(Qubit /*qubit*/)
{
    // Do nothing. By default we store qubit Id in place of a pointer to a qubit.
}

CQubitManager::QubitIdType CQubitManager::QubitToId(Qubit qubit) const
{
    intptr_t pointerSizedId = reinterpret_cast<intptr_t>(qubit);
    // Make sure the static_cast won't overflow:
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
    QubitIdType* newStatusArray = new QubitIdType[(size_t)requestedCapacity];
    memcpy(newStatusArray, sharedQubitStatusArray, (size_t)qubitCapacity * sizeof(newStatusArray[0]));
    QubitListInSharedArray newFreeQubits(qubitCapacity, requestedCapacity - 1, newStatusArray);

    // Set new data. All fresh new qubits are added to the free qubits in the outermost area.
    freeQubitCount += requestedCapacity - qubitCapacity;
    FailIf(freeQubitCount <= 0, "Incorrect free qubit count.");
    delete[] sharedQubitStatusArray;
    sharedQubitStatusArray = newStatusArray;
    qubitCapacity = requestedCapacity;
    freeQubitsInAreas[0].FreeQubitsReuseAllowed.MoveAllQubitsFrom(newFreeQubits, sharedQubitStatusArray);
}

CQubitManager::QubitIdType CQubitManager::TakeFreeQubitId()
{
    // First we try to take qubit from the current (innermost) area.
    QubitIdType id = freeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);

    // Then, if no free qubits available for reuse, we scan outer areas (if they exist).
    if (id == NoneMarker && freeQubitsInAreas.Count() >= 2)
    {
        int32_t areaIndex = freeQubitsInAreas.Count() - 1;
        do
        {
            areaIndex = freeQubitsInAreas[areaIndex].prevAreaWithFreeQubits;
            id = freeQubitsInAreas[areaIndex].FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
        } while ((areaIndex != 0) && (id == NoneMarker));

        // We remember previous area where a free qubit was found or 0 if none were found.
        freeQubitsInAreas.PeekBack().prevAreaWithFreeQubits = areaIndex;
    }

    if (id != NoneMarker)
    {
        FailIf(id < 0 || id >= qubitCapacity, "Internal Error: Allocated invalid qubit.");
        allocatedQubitCount++;
        FailIf(allocatedQubitCount <= 0, "Incorrect allocated qubit count.");
        freeQubitCount--;
        FailIf(freeQubitCount < 0, "Incorrect free qubit count.");
    }

    return id;
}

CQubitManager::QubitIdType CQubitManager::AllocateQubitId()
{
    QubitIdType newQubitId = TakeFreeQubitId();
    if (newQubitId == NoneMarker && mayExtendCapacity)
    {
        QubitIdType newQubitCapacity = qubitCapacity * 2;
        FailIf(newQubitCapacity <= qubitCapacity, "Cannot extend capacity.");
        EnsureCapacity(newQubitCapacity);
        newQubitId = TakeFreeQubitId();
    }
    return newQubitId;
}

void CQubitManager::ReleaseQubitId(QubitIdType id)
{
    FailIf(id < 0 || id >= qubitCapacity, "Internal Error: Cannot release an invalid qubit.");
    if (IsDisabledId(id))
    {
        // Nothing to do. Qubit will stay disabled.
        return;
    }

    FailIf(!IsExplicitlyAllocatedId(id), "Attempt to free qubit that has not been allocated.");

    // Released qubits are added to reuse area/segment in which they were released
    // (rather than area/segment where they are allocated).
    // Although counterintuitive, this makes code simple.
    // This is reasonable because qubits should be allocated and released in the same segment. (This is not enforced)
    freeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.AddQubit(id, sharedQubitStatusArray);

    freeQubitCount++;
    FailIf(freeQubitCount <= 0, "Incorrect free qubit count.");
    allocatedQubitCount--;
    FailIf(allocatedQubitCount < 0, "Incorrect allocated qubit count.");
}


}
}
