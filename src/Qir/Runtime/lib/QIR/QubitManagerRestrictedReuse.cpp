// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This code compiles, but was never executed, be careful!

#include "QubitManagerRestrictedReuse.hpp"

namespace Microsoft
{
namespace Quantum
{


//
// QubitListInSharedArray
//

QubitListInSharedArray::QubitListInSharedArray(int minElement, int maxElement, int* sharedQubitStatusArray)
{
    // We are not storing pointer to shared array because it can be reallocated.
    // Indexes and special values remain the same on such reallocations.
    FailIf(minElement > maxElement || minElement < 0 || maxElement == INT_MAX,
        "Incorrect boundaries in the linked list initialization.");

    for (int i = minElement; i < maxElement; i++) {
        sharedQubitStatusArray[i] = i + 1;
    }
    sharedQubitStatusArray[maxElement] = NoneMarker;
    firstElement = minElement;
    lastElement = maxElement;
}

bool QubitListInSharedArray::IsEmpty()
{
    return firstElement == NoneMarker;
}

void QubitListInSharedArray::AddQubit(int id, bool addToFront, int* sharedQubitStatusArray)
{
    FailIf(id == NoneMarker, "Incorrect qubit id, cannot add it to the list.");

    // If the list is empty, we initialize it with the new element.
    if (IsEmpty())
    {
        firstElement = id;
        lastElement = id;
        sharedQubitStatusArray[id] = NoneMarker;
        return;
    }

    if (addToFront)
    {
        sharedQubitStatusArray[id] = firstElement;
        firstElement = id;
    } else
    {
        sharedQubitStatusArray[lastElement] = id;
        sharedQubitStatusArray[id] = NoneMarker;
    }
}

// TODO: Set status to the taken qubit here. Then counting is reasonable here, but not possible?
// TODO: Rename 'RemoveQubitFromFront'?
int QubitListInSharedArray::TakeQubitFromFront(int* sharedQubitStatusArray)
{
    // First element will be returned. It is 'NoneMarker' if the list is empty.
    int result = firstElement;

    // Advance list start to the next element if list is not empty.
    if (!IsEmpty())
    {
        firstElement = sharedQubitStatusArray[firstElement];
    }

    // Drop pointer to the last element if list becomes empty.
    if (IsEmpty())
    {
        lastElement = NoneMarker;
    }

    return result;
}

void QubitListInSharedArray::MoveAllQubitsFrom(QubitListInSharedArray& source, int* sharedQubitStatusArray)
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
        sharedQubitStatusArray[source.lastElement] = firstElement;
    }
    firstElement = source.firstElement;

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

void CRestrictedReuseAreaStack::PushToBack(RestrictedReuseArea area)
{
    this->insert(this->end(), area);
}


//
// CRestrictedReuseAreaStack
//

RestrictedReuseArea CRestrictedReuseAreaStack::PopFromBack()
{
    FailIf(this->empty(), "Cannot remove element from empty set.");
    RestrictedReuseArea result = this->back();
    this->pop_back();
    return result;
}

RestrictedReuseArea& CRestrictedReuseAreaStack::PeekBack() {
    return this->back();
}

int CRestrictedReuseAreaStack::Count() {
    return this->size();
}

//
// CQubitManagerRestrictedReuse
//

// Although it is not necessary to pass area IDs to these functions, such support may be added for extra checks.
void CQubitManagerRestrictedReuse::StartRestrictedReuseArea()
{
    RestrictedReuseArea newArea;
    freeQubitsInAreas.PushToBack(newArea);
}

void CQubitManagerRestrictedReuse::NextRestrictedReuseSegment()
{
    FailIf(freeQubitsInAreas.Count() <= 0, "Internal error! No reuse areas.");
    FailIf(freeQubitsInAreas.Count() == 1, "NextRestrictedReuseSegment() without an active area.");
    RestrictedReuseArea& currentArea = freeQubitsInAreas.PeekBack();
    // When new segment starts, reuse of all free qubits in the current area becomes prohibited.
    currentArea.FreeQubitsReuseProhibited.MoveAllQubitsFrom(currentArea.FreeQubitsReuseAllowed, sharedQubitStatusArray);
}

void CQubitManagerRestrictedReuse::EndRestrictedReuseArea()
{
    FailIf(freeQubitsInAreas.Count() < 2, "EndRestrictedReuseArea() without an active area.");
    RestrictedReuseArea areaAboutToEnd = freeQubitsInAreas.PopFromBack();
    RestrictedReuseArea& containingArea = freeQubitsInAreas.PeekBack();
    // When area ends, reuse of all free qubits from this area becomes allowed.
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseProhibited, sharedQubitStatusArray);
    containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseAllowed, sharedQubitStatusArray);
}

long CQubitManagerRestrictedReuse::AllocateQubit()
{
    if (EncourageReuse) {
        // When reuse is encouraged, we start with the innermost area
        for (int i = freeQubitsInAreas.Count() - 1; i >= 0; i--) {
            long id = freeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker) {
                return id;
            }
        }
    } else {
        // When reuse is discouraged, we start with the outermost area
        for (int i = 0; i < freeQubitsInAreas.Count(); i++) {
            long id = freeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(sharedQubitStatusArray);
            if (id != NoneMarker) {
                return id;
            }
        }
    }
    return NoneMarker;
}

void CQubitManagerRestrictedReuse::ReleaseQubit(long id)
{
    // Released qubits are added to reuse area/segment in which they were released
    // (rather than area/segment where they are allocated).
    // Although counterintuitive, this makes code simple.
    // This is reasonable because we think qubits should be allocated and released in the same segment.
    freeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.AddQubit(id, EncourageReuse, sharedQubitStatusArray);
}

CQubitManagerRestrictedReuse::CQubitManagerRestrictedReuse(
    int initialQubitCapacity,
    bool mayExtendCapacity,
    bool encourageReuse)
{
    qubitCapacity = initialQubitCapacity;
    if (qubitCapacity <= 0) {
        qubitCapacity = FallbackQubitCapacity;
    }
    sharedQubitStatusArray = new int[qubitCapacity];

    MayExtendCapacity = mayExtendCapacity;
    EncourageReuse = encourageReuse;

    // These objects are passed by value (copies are created)
    QubitListInSharedArray FreeQubitsFresh(0, qubitCapacity - 1, sharedQubitStatusArray);
    RestrictedReuseArea outermostArea(FreeQubitsFresh);
    freeQubitsInAreas.PushToBack(outermostArea);

    AllocatedQubitsCount = 0;
    DisabledQubitsCount = 0;
    FreeQubitsCount = qubitCapacity;
}

CQubitManagerRestrictedReuse::~CQubitManagerRestrictedReuse()
{
    if (sharedQubitStatusArray != nullptr)
    {
        delete[] sharedQubitStatusArray;
        sharedQubitStatusArray = nullptr;
    }
    // freeQubitsInAreas - direct member of the class, no need to delete.
}

void CQubitManagerRestrictedReuse::EnsureCapacity(int requestedCapacity)
{
    // No need to adjust existing values (NonMarker or indexes in the array).
    // TODO: Borrowing/returning are not yet supported.
    if (requestedCapacity <= qubitCapacity)
    {
        return;
    }

    // Prepare new shared status array
    int* newStatusArray = new int[requestedCapacity];
    memcpy(newStatusArray, sharedQubitStatusArray, qubitCapacity * sizeof(newStatusArray[0]));
    QubitListInSharedArray newFreeQubits(qubitCapacity, requestedCapacity - 1, newStatusArray);

    // Set new data. All new qubits are added to the free qubits in the outermost area.
    FreeQubitsCount += requestedCapacity - qubitCapacity;
    delete[] sharedQubitStatusArray;
    sharedQubitStatusArray = newStatusArray;
    qubitCapacity = requestedCapacity;
    freeQubitsInAreas[0].FreeQubitsReuseAllowed.MoveAllQubitsFrom(newFreeQubits, sharedQubitStatusArray);
}

bool CQubitManagerRestrictedReuse::IsDisabled(int id)
{
    return sharedQubitStatusArray[id] == DisabledMarker;
}

bool CQubitManagerRestrictedReuse::IsDisabled(Qubit qubit)
{
    return IsValid(qubit) && IsDisabled(QubitToId(qubit));
}

void CQubitManagerRestrictedReuse::Disable(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Invalid qubit.");
    int id = QubitToId(qubit);
    // We can only disable explicitly allocated qubits that were not borrowed.
    FailIf(!IsExplicitlyAllocated(id), "Cannot disable qubit that is not explicitly allocated.");
    sharedQubitStatusArray[id] = DisabledMarker;
    DisabledQubitsCount++;

    AllocatedQubitsCount--;
    FailIf(AllocatedQubitsCount < 0, "Incorrect count of allocated qubits.");
}

void CQubitManagerRestrictedReuse::Disable(Qubit* qubitsToDisable, int qubitCount)
{
    FailIf(qubitCount < 0, "Qubit count cannot be negative");
    if (qubitsToDisable == nullptr || qubitCount == 0)
    {
        return;
    }

    for (int i = 0; i < qubitCount; i++)
    {
        Disable(qubitsToDisable[i]);
    }
}

bool CQubitManagerRestrictedReuse::IsExplicitlyAllocated(long id)
{
    return sharedQubitStatusArray[id] == AllocatedMarker;
}

void CQubitManagerRestrictedReuse::ChangeStatusToAllocated(long id)
{
    FailIf(id >= qubitCapacity, "Internal Error: Cannot change status of an invalid qubit.");
    sharedQubitStatusArray[id] = AllocatedMarker;
    AllocatedQubitsCount++;
    FreeQubitsCount--;
}

Qubit CQubitManagerRestrictedReuse::Allocate()
{
    long newQubitId = AllocateQubit();
    if (newQubitId == NoneMarker && MayExtendCapacity)
    {
        EnsureCapacity(qubitCapacity * 2);
        newQubitId = AllocateQubit();
    }
    FailIf(newQubitId == NoneMarker, "Not enough qubits.");
    ChangeStatusToAllocated(newQubitId);
    return CreateQubitObject(newQubitId);
}

Qubit* CQubitManagerRestrictedReuse::Allocate(long numToAllocate)
{
    FailIf(numToAllocate < 0, "Attempt to allocate negative number of qubits.");
    if (numToAllocate == 0)
    {
        return new Qubit[0];
    }

    // Consider optimization for initial allocation of a large array at once
    Qubit* result = new Qubit[numToAllocate];
    for (int i = 0; i < numToAllocate; i++)
    {
        int newQubitId = AllocateQubit();
        if (newQubitId == NoneMarker)
        {
            for (int k = 0; k < i; k++)
            {
                Release(result[k]);
            }
            delete[] result;
            result = nullptr;
            FailNow("Not enough qubits.");
            return nullptr;
        }
        ChangeStatusToAllocated(newQubitId);
        result[i] = CreateQubitObject(newQubitId);
    }

    return result;
}

bool CQubitManagerRestrictedReuse::IsFree(long id)
{
    return sharedQubitStatusArray[id] >= 0;
}

bool CQubitManagerRestrictedReuse::IsFree(Qubit qubit)
{
    return IsValid(qubit) && IsFree(QubitToId(qubit));
}

void CQubitManagerRestrictedReuse::Release(long id)
{
    if (IsDisabled(id))
    {
        // Nothing to do. Qubit will stay disabled.
        return;
    }

    FailIf(!IsExplicitlyAllocated(id), "Attempt to free qubit that has not been allocated.");

    if (MayExtendCapacity && !EncourageReuse)
    {
        // We can extend capcity and don't want reuse => Qubits will never be reused => Discard qubit.
        // We put it in its own "free" list, this list will never be found again and qubit will not be reused.
        sharedQubitStatusArray[id] = NoneMarker;
    } else
    {
        ReleaseQubit(id);
    }

    FreeQubitsCount++;
    AllocatedQubitsCount--;
    FailIf(AllocatedQubitsCount < 0, "Incorrect allocated qubit count.");
}

void CQubitManagerRestrictedReuse::Release(Qubit qubit)
{
    FailIf(!IsValid(qubit), "Qubit is not valid.");
    Release(QubitToId(qubit));
    // TODO: should we clean id of released qubit object?
}

void CQubitManagerRestrictedReuse::Release(Qubit* qubitsToRelease, int qubitCount) {
    FailIf(qubitCount < 0, "Attempt to release negative number of qubits.");
    if (qubitsToRelease == nullptr)
    {
        return;
    }

    for (int i = 0; i < qubitCount; i++)
    {
        Release(qubitsToRelease[i]);
        qubitsToRelease[i] = nullptr;
    }

    delete[] qubitsToRelease;
}

Qubit CQubitManagerRestrictedReuse::Borrow()
{
    // We don't support true borrowing/returning at the moment.
    return Allocate();
}

Qubit* CQubitManagerRestrictedReuse::Borrow(long qubitCountToBorrow)
{
    // We don't support true borrowing/returning at the moment.
    return Allocate(qubitCountToBorrow);
}

void CQubitManagerRestrictedReuse::Return(Qubit qubit)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubit);
}

void CQubitManagerRestrictedReuse::Return(Qubit* qubitsToReturn, int qubitCountToReturn)
{
    // We don't support true borrowing/returning at the moment.
    Release(qubitsToReturn, qubitCountToReturn);
}

bool CQubitManagerRestrictedReuse::IsValid(Qubit qubit)
{
    int id = QubitToId(qubit);
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

Qubit CQubitManagerRestrictedReuse::CreateQubitObject(int id)
{
    FailIf(id < 0 || id > INTPTR_MAX, "Qubit id out of range.");
    intptr_t pointerSizedId = static_cast<intptr_t>(id);
    return reinterpret_cast<Qubit>(pointerSizedId);
}

int CQubitManagerRestrictedReuse::QubitToId(Qubit qubit)
{
    intptr_t pointerSizedId = reinterpret_cast<intptr_t>(qubit);
    FailIf(pointerSizedId < 0 || pointerSizedId > INT_MAX, "Qubit id out of range.");
    return static_cast<int>(pointerSizedId);
}

}
}
