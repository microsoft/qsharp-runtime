// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;


namespace Microsoft.Quantum.Simulation.Common {

    public class QubitManagerRestrictedReuse: IQubitManager {
        /// <summary>
        /// The end of free lists are marked with None value. It is used like null for pointers.
        /// This value is non-negative just like other values in the free lists.
        /// </summary>
        protected const long None = long.MaxValue;

        /// <summary>
        /// Explicitly allocated qubits are marked with Allocated value.
        /// Qubits implicitly allocated for borrowing are "refcounted" with values [Allocated+1 .. -2].
        /// When refcount needs to be decreased to Allocated value, the qubit is automatically released.
        /// </summary>
        protected const long Allocated = long.MinValue;

        /// <summary>
        /// Disabled qubits are marked with this value.
        /// </summary>
        protected const long Disabled = -1;

        /// <summary>
        /// Tracks allocation state of all qubits. Stores lists of free qubits.
        /// QubitCapacity is always equal to array size.
        /// </summary>
        protected long[] SharedQubitStatusArray;
        protected long QubitCapacity { get { return SharedQubitStatusArray.LongLength; } }

        // We want status array to be reasonably large if passed value is wrong.
        protected const long MinimumQubitCapacity = 8;
        // Indexes in the status array can potentially be in range 0 .. long.MaxValue-1.
        // This gives maximum capacity as long.MaxValue.
        // Index long.MaxValue doesn't exist and is reserved for 'None' - list terminator.
        protected const long MaximumQubitCapacity = long.MaxValue;

        private class QubitListInSharedArray {
            // This class is implemented as a singly-linked list with pointers to the first and the last element.
            // Pointers are indexes in a shared array.
            private long FirstElement = None;
            private long LastElement = None;

            // Initialize empty list
            internal QubitListInSharedArray() {
            }

            // Initialize as a list with sequential elements from minElement to maxElement inclusve.
            internal QubitListInSharedArray(long minElement, long maxElement, long[] sharedQubitStatusArray) {
                // We are not storing pointer to shared array because it can be reallocated.
                // Indexes and special values remain the same on such reallocations.
                if (minElement > maxElement || minElement < 0 || maxElement == long.MaxValue) {
                    throw new ApplicationException("Incorrect boundaries in the linked list initialization.");
                }
                for (long i = minElement; i < maxElement; i++) {
                    sharedQubitStatusArray[i] = i + 1;
                }
                sharedQubitStatusArray[maxElement] = None;
                FirstElement = minElement;
                LastElement = maxElement;
            }

            internal bool IsEmpty() {
                return FirstElement == None;
            }

            internal void AddQubit(long id, bool addToFront, long[] sharedQubitStatusArray) {
                Debug.Assert(id != None);

                // If the list is empty, we initialize it with the new element.
                if (IsEmpty()) {
                    FirstElement = id;
                    LastElement = id;
                    sharedQubitStatusArray[id] = None;
                    return;
                }

                if (addToFront) {
                    sharedQubitStatusArray[id] = FirstElement;
                    FirstElement = id;
                } else {
                    sharedQubitStatusArray[LastElement] = id;
                    sharedQubitStatusArray[id] = None;
                }
            }

            internal long TakeQubitFromFront(long[] sharedQubitStatusArray) {
                // First element will be returned.
                long result = FirstElement;

                // Advance list start to the next element if list is not empty.
                if (!IsEmpty()) {
                    FirstElement = sharedQubitStatusArray[FirstElement];
                }

                // Drop pointer to the last element if list becomes empty.
                if (IsEmpty()) {
                    LastElement = None;
                }

                return result;
            }

            internal void MoveAllQubitsFrom(QubitListInSharedArray source, long[] sharedQubitStatusArray) {
                // No need to do anthing if source is empty.
                if (source.IsEmpty()) {
                    return;
                }

                if (this.IsEmpty()) {
                    // It this list is empty, we'll just set it to the source list.
                    LastElement = source.LastElement;
                } else {
                    // Attach source at the beginning of the list. 
                    sharedQubitStatusArray[source.LastElement] = FirstElement;
                }
                FirstElement = source.FirstElement;

                // Remove all elements from source.
                source.FirstElement = None;
                source.LastElement = None;
            }
        }

        // Restricted reuse area consists of multiple segments. Qubits used in one segment cannot be reused in another.
        // One restricted reuse area can be nested in a segment of another restricted reuse area.
        // This class tracks current restricted reuse segment of an area. There's no need to track other segments.
        private class RestrictedReuseArea {
            internal QubitListInSharedArray FreeQubitsReuseProhibited;
            internal QubitListInSharedArray FreeQubitsReuseAllowed;
            internal RestrictedReuseArea(QubitListInSharedArray freeQubits) {
                FreeQubitsReuseProhibited = new QubitListInSharedArray();
                FreeQubitsReuseAllowed = freeQubits;
            }
        }

        private class RestrictedReuseAreaStack : List<RestrictedReuseArea> {
            internal void PushToBack(RestrictedReuseArea area) {
                Add(area);
            }
            internal RestrictedReuseArea PopFromBack() {
                RestrictedReuseArea result = this[Count - 1];
                RemoveAt(Count - 1);
                return result;
            }
            internal RestrictedReuseArea PeekBack() {
                return this[Count - 1];
            }
        }

        private RestrictedReuseAreaStack FreeQubitsInAreas = new RestrictedReuseAreaStack();
        private QubitListInSharedArray FreeQubitsFresh; // This is also present on stack, just a reference here!

#region Restricted reuse area control, allocation and release

        // TODO: Although it is not necessary to pass area IDs, this support may be added for extra checks.
        public void StartRestrictedReuseArea() {
            RestrictedReuseArea newArea = new RestrictedReuseArea(new QubitListInSharedArray());
            FreeQubitsInAreas.PushToBack(newArea);
        }

        public void NextRestrictedReuseSegment() {
            if (FreeQubitsInAreas.Count <= 0) {
                throw new ApplicationException("Internal error. No reuse areas.");
            }
            if (FreeQubitsInAreas.Count == 1) {
                throw new ApplicationException("NextRestrictedReuseSegment() without an active area.");
            }
            RestrictedReuseArea currentArea = FreeQubitsInAreas.PeekBack();
            // When new segment starts, reuse of all free qubits in the current area becomes prohibited.
            currentArea.FreeQubitsReuseProhibited.MoveAllQubitsFrom(currentArea.FreeQubitsReuseAllowed, SharedQubitStatusArray);
        }

        public void EndRestrictedReuseArea() {
            if (FreeQubitsInAreas.Count < 2) {
                throw new ApplicationException("EndRestrictedReuseArea() without an active area.");
            }
            RestrictedReuseArea areaAboutToEnd = FreeQubitsInAreas.PopFromBack();
            RestrictedReuseArea containingArea = FreeQubitsInAreas.PeekBack();
            // When area ends, reuse of all free qubits from this area becomes allowed.
            containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseProhibited, SharedQubitStatusArray);
            containingArea.FreeQubitsReuseAllowed.MoveAllQubitsFrom(areaAboutToEnd.FreeQubitsReuseAllowed, SharedQubitStatusArray);
        }

        public long AllocateQubit() {
            // Computation complexity is O(number of nested restricted reuse areas).
            if (EncourageReuse) {
                // When reuse is encouraged, we start with the innermost area
                for (int i = FreeQubitsInAreas.Count - 1; i >= 0; i--) {
                    long id = FreeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(SharedQubitStatusArray);
                    if (id != None) {
                        return id;
                    }
                }
            } else {
                // When reuse is discouraged, we start with the outermost area
                for (int i = 0; i < FreeQubitsInAreas.Count; i++) {
                    long id = FreeQubitsInAreas[i].FreeQubitsReuseAllowed.TakeQubitFromFront(SharedQubitStatusArray);
                    if (id != None) {
                        return id;
                    }
                }
            }
            return None;
        }

        public  void ReleaseQubit(long id) {
            // Released qubits are added to reuse area/segment in which they were released
            // (rather than area/segment where they are allocated).
            // Although counterintuitive, this makes code simple.
            // This is reasonable because we think qubits should be allocated and released in the same segment.
            FreeQubitsInAreas.PeekBack().FreeQubitsReuseAllowed.AddQubit(id, EncourageReuse, SharedQubitStatusArray);
        }

#endregion END - Restricted reuse area control, allocation and release

#region Configuration Properties

        public bool DisableBorrowing { get; }

        public bool MayExtendCapacity { get; }

        public bool EncourageReuse { get; }

#endregion END - Configuration Properties

#region Constructor and reallocation

        public QubitManagerRestrictedReuse(
            long qubitCapacity,
            bool mayExtendCapacity = false,
            bool disableBorrowing = false,
            bool encourageReuse = true) {

            if (qubitCapacity <= 0) {
                qubitCapacity = MinimumQubitCapacity;
            }
            SharedQubitStatusArray = new long[qubitCapacity];

            MayExtendCapacity = mayExtendCapacity;
            DisableBorrowing = disableBorrowing;
            EncourageReuse = encourageReuse;

            FreeQubitsFresh = new QubitListInSharedArray(0, qubitCapacity - 1, SharedQubitStatusArray);
            RestrictedReuseArea outermostArea = new RestrictedReuseArea(FreeQubitsFresh);
            FreeQubitsInAreas.PushToBack(outermostArea);

            AllocatedQubitsCount = 0;
            DisabledQubitsCount = 0;
            FreeQubitsCount = QubitCapacity;
        }

        // No existing value adjustments are necessary.
        // TODO: Also borrowing/returning are not yet supported.
        private void EnsureCapacity(long requestedCapacity) {
            if (requestedCapacity <= QubitCapacity) {
                return;
            }

            // Prepare new shared status array
            long[] newStatusArray = new long[requestedCapacity];
            Array.Copy(SharedQubitStatusArray, newStatusArray, QubitCapacity);
            QubitListInSharedArray newFreeItems = new QubitListInSharedArray(QubitCapacity, requestedCapacity - 1, newStatusArray);

            // Set new data. All new qubits are added to the free qubits in the outermost area.
            FreeQubitsCount += requestedCapacity - QubitCapacity; // Do this first, QubitCapacity is SharedQubitStatusArray length.
            SharedQubitStatusArray = newStatusArray;
            FreeQubitsFresh.MoveAllQubitsFrom(newFreeItems, SharedQubitStatusArray);
        }

#endregion END - Constructor and reallocation

#region Disable, disabled qubit count and checks

        public long DisabledQubitsCount { get; protected set; } = 0;

        protected virtual bool IsDisabled(long id) {
            return SharedQubitStatusArray[id] == Disabled;
        }
        public virtual bool IsDisabled(Qubit qubit) {
            return IsValid(qubit) && IsDisabled(qubit.Id);
        }

        /// <summary>
        /// Disables a given qubit.
        /// Once a qubit is disabled it can never be "enabled" or reallocated.
        /// </summary>
        public virtual void Disable(Qubit qubit) {
            if (!IsValid(qubit)) {
                throw new ApplicationException("Invalid qubit.");
            }
            if (!IsExplicitlyAllocated(qubit.Id)) {
                // We can only disable explicitly allocated qubits that were not borrowed.
                throw new ApplicationException("Cannot disable qubit that is not explicitly allocated.");
            }
            SharedQubitStatusArray[qubit.Id] = Disabled;
            DisabledQubitsCount++;

            AllocatedQubitsCount--;
            Debug.Assert(AllocatedQubitsCount >= 0);
        }

        /// <summary>
        /// Disables a set of given qubits.
        /// Once a qubit is disabled it can never be "enabled" or reallocated.
        /// </summary>
        public virtual void Disable(IQArray<Qubit> qubitsToDisable) {
            if (qubitsToDisable == null || qubitsToDisable.Length == 0) {
                return;
            }

            foreach (Qubit qubit in qubitsToDisable) {
                Disable(qubit);
            }
        }

#endregion END - Disable, disabled qubit count and checks

#region Allocate, allocated qubit count and checks

        public virtual long AllocatedQubitsCount { get; protected set; }

        protected bool IsExplicitlyAllocated(long id) {
            return SharedQubitStatusArray[id] == Allocated;
        }

        /// <summary>
        /// Allocates a qubit.
        /// Throws a NotEnoughQubits exception if the qubit cannot be allocated. 
        /// </summary>
        public virtual Qubit Allocate() {
            long newQubitId = AllocateQubit();
            if (newQubitId == None && MayExtendCapacity) {
                EnsureCapacity(QubitCapacity * 2);
                newQubitId = AllocateQubit();
            }
            if (newQubitId == None) {
                // TODO: Wording of the exception doesn't account for restricted reuse.
                throw new NotEnoughQubits(1, this.FreeQubitsCount);
            }
            SharedQubitStatusArray[newQubitId] = Allocated;
            AllocatedQubitsCount++;
            FreeQubitsCount--;
            return CreateQubitObject(newQubitId);
        }

        /// <summary>
        /// Allocates numToAllocate new qubits.
        /// Throws a NotEnoughQubits exception without allocating any qubits if the qubits cannot be allocated. 
        /// </summary>
        public IQArray<Qubit> Allocate(long numToAllocate) {
            if (numToAllocate < 0) {
                throw new ArgumentException("Attempt to allocate negative number of qubits.");
            } else if (numToAllocate == 0) {
                return QArray<Qubit>.Create(0);
            }

            // TODO: Consider optimization for initial allocation of a large array at once

            QArray<Qubit> result = QArray<Qubit>.Create(numToAllocate);
            for (int i = 0; i < numToAllocate; i++) {
                long allocated = AllocateQubit();
                if (allocated == None) {
                    for (int k = 0; k < i; k++) {
                        Release(result[k]);
                    }
                    throw new NotEnoughQubits(numToAllocate, this.FreeQubitsCount);
                }
                result.Modify(i, CreateQubitObject(allocated));
            }

            return result;
        }

        /// <summary>
        /// Returns all allocated qubit ids. Disabled qubits are also returned. (is this OK?)
        /// </summary>
        /// <returns></returns>
        public virtual IEnumerable<long> AllocatedIds() {
            for (long i = 0; i < QubitCapacity; i++) {
                // TODO: Is it OK to include disabled IDs?
                // TODO: If qubit manager is modified while iteration is in progress, this won't return an error.
                if (!IsFree(i)) yield return i;
            }
        }

#endregion END - Allocate, allocated qubit count and checks

#region Release, free qubit count and checks

        public virtual long FreeQubitsCount { get; protected set; }

        protected virtual bool IsFree(long id) {
            return SharedQubitStatusArray[id] >= 0;
        }
        public virtual bool IsFree(Qubit qubit) {
            return IsValid(qubit) && IsFree(qubit.Id);
        }

        protected virtual void Release(long id) {
            if (IsDisabled(id)) {
                // Nothing to do. Qubit will stay disabled.
                return;
            }

            if (!IsExplicitlyAllocated(id)) {
                throw new ArgumentException("Attempt to free qubit that has not been allocated.");
            }

            if (MayExtendCapacity && !EncourageReuse) {
                // We can extend capcity and don't want reuse => Qubits will never be reused => Discard qubit.
                // We put it in its own "free" list, this list will never be found again and qubit will not be reused.
                SharedQubitStatusArray[id] = None;
            } else {
                ReleaseQubit(id);
            }

            FreeQubitsCount++;
            AllocatedQubitsCount--;
            Debug.Assert(AllocatedQubitsCount >= 0);
        }

        /// <summary>
        /// Releases a given qubit.
        /// </summary>
        public virtual void Release(Qubit qubit) {
            if (!IsValid(qubit)) {
                throw new ApplicationException("Qubit is not valid.");
            }
            Release(qubit.Id);
            // TODO: should we clean id of released qubit object?
        }

        /// <summary>
        /// Releases a set of given qubits.
        /// </summary>
        public virtual void Release(IQArray<Qubit> qubitsToRelease) {
            if (qubitsToRelease == null) {
                return;
            }

            foreach (Qubit qubit in qubitsToRelease) {
                Release(qubit);
            }
        }

#endregion END - Release, free qubit count and checks

#region Borrow (We treat borrowing as allocation currently)

        public virtual long QubitsAvailableToBorrowCount(int stackFrame = 0) {
            // TODO: We don't support borrowing at the moment.
            return 0;
        }

        public IQArray<Qubit> Borrow(long numToBorrow) {
            // TODO: We don't support borrowing at the moment.
            return Allocate(numToBorrow);
        }

        public Qubit Borrow() {
            // TODO: We don't support borrowing at the moment.
            return Allocate();
        }

        public virtual void OnOperationStart(ICallable _, IApplyData values) {
            // TODO: We don't support borrowing at the moment.
        }

        public virtual void OnOperationEnd(ICallable _, IApplyData values) {
            // TODO: We don't support borrowing at the moment.
        }

#endregion END - Borrow

#region Return (We treat borrowing as allocation currently)

        public virtual void Return(Qubit qubit) {
            // TODO: We don't support borrowing at the moment.
            Release(qubit);
        }

        public void Return(IQArray<Qubit> qubitsToReturn) {
            // TODO: We don't support borrowing at the moment.
            Release(qubitsToReturn);
        }

#endregion END - Return

#region Qubit creation, validity check

        public virtual bool IsValid(Qubit qubit) {
            if (qubit == null) {
                return false;
            }
            if (qubit.Id >= QubitCapacity) {
                return false;
            }
            if (qubit.Id < 0) {
                return false;
            }
            return true;
        }

        private class QubitNonAbstract : Qubit {
            // This class is only needed because Qubit is abstract. 
            // It is equivalent to Qubit and adds nothing to it except the ability to create it.
            // It should be used only in CreateQubitObject below, and nowhere else.
            // When Qubit stops being abstract, this class should be removed.
            internal QubitNonAbstract(int id) : base(id) { }
        }

        /// <summary>
        /// May be overriden to create a custom Qubit object of a derived type.
        /// </summary>
        /// <param name="id">unique qubit id</param>
        /// <returns>a newly instantiated qubit</returns>
        public virtual Qubit CreateQubitObject(long id) {
            if (id < 0 || id >= Int32.MaxValue) {
                throw new NotSupportedException("Qubit id out of range.");
            }
            return new QubitNonAbstract((int)id);
        }

        // TODO: QUBIT ID IS INT, NOT LONG!!!! JUST DO INTS EVERYWHERE???

#endregion END -  Qubit creation, validity check

    }
}
