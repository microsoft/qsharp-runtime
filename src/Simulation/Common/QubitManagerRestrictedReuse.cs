using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;


namespace Microsoft.Quantum.Simulation.Common {

    public class QubitManagerRestrictedReuse {
        /// <summary>
        /// The end of free lists are marked with None value. It is used like null for pointers.
        /// This value is non-negative just like other values in the free lists.
        /// </summary>
        protected const long None = long.MaxValue;

        /// <summary>
        /// Allocated qubits are "refcounted" with values [Allocated+1 .. -2]. Refcounting is for borrowing.
        /// When refcount reaches Allocated value, the qubit is automatically released.
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

        // We want status array to be reasonably large.
        // TODO: This has a side effect of adjusting minimum count to 8. Maybe decouple count and capacity.
        protected const long MinimumQubitCapacity = 8;
        // Indexes in the status array can potentially be in range 0 .. long.MaxValue-1.
        // This gives maximum capacity as long.MaxValue.
        // Index long.MaxValue doesn't exist and is reserved for 'None' - list terminator.
        protected const long MaximumQubitCapacity = long.MaxValue;

        private class QubitListInSharedArray {
            // We want reference to the parent qubit manager rather than underlying qubit array
            // because array can be reallocated. Indexes and special values remain the same on reallocation.
            private QubitManagerRestrictedReuse ContainingQubitManager;

            // This class is implemented as a singly-linked list with pointers to the first and the last element.
            // Pointers are indexes in a shared array.
            private long FirstElement = None;
            private long LastElement = None;

            // Initialize empty list
            internal QubitListInSharedArray(QubitManagerRestrictedReuse parentQubitManager) {
                ContainingQubitManager = parentQubitManager;
            }

            // Initialize as a sequential list with elements from minElement to maxElement inclusve.
            internal QubitListInSharedArray(QubitManagerRestrictedReuse parentQubitManager, long minElement, long maxElement):
                this(parentQubitManager) {
                if (minElement > maxElement || minElement < 0 || maxElement == long.MaxValue) {
                    throw new ApplicationException("Incorrect boundaries in the linked list initialization.");
                }
                for (long i = minElement; i < maxElement; i++) {
                    parentQubitManager.SharedQubitStatusArray[i] = i + 1;
                }
                parentQubitManager.SharedQubitStatusArray[maxElement] = None;
                FirstElement = minElement;
                LastElement = maxElement;
            }

            internal bool IsEmpty() {
                return FirstElement == None;
            }

            internal void AddQubit(long id) {
                if (IsEmpty()) {
                    LastElement = id;
                }
                ContainingQubitManager.SharedQubitStatusArray[id] = FirstElement;
                FirstElement = id;
            }

            internal long RemoveOneQubit() {
                // First element will be returned.
                long result = FirstElement;

                // Advance list start to the next element if list is not empty.
                if (!IsEmpty()) {
                    FirstElement = ContainingQubitManager.SharedQubitStatusArray[FirstElement];
                }

                // Drop pointer to the last element if list becomes empty.
                if (IsEmpty()) {
                    LastElement = None;
                }

                return result;
            }

            internal void MoveAllQubitsFrom(QubitListInSharedArray source) {
                // No need to do anthing if source is empty.
                if (source.IsEmpty()) {
                    return;
                }

                // Attach source at the beginning of the list. 
                ContainingQubitManager.SharedQubitStatusArray[source.LastElement] = FirstElement;
                FirstElement = source.FirstElement;

                // Remove all elements from source.
                source.FirstElement = None;
                source.LastElement = None;
            }
        }

        // Restricted reuse section consists of multiple segments. Qubits used in one segment cannot be reused in another.
        // One restricted reuse section can be nested in a segment of another restricted reuse section.
        // This class tracks current restricted reuse segment of a section. There's no need to track other segments.
        // TODO: Come up with better names rather than section-segment.
        private class RestrictedReuseSection {
            internal QubitListInSharedArray FreeQubitsReuseProhibited;
            internal QubitListInSharedArray FreeQubitsReuseAllowed;
            internal RestrictedReuseSection(QubitManagerRestrictedReuse containingQubitManager) {
                FreeQubitsReuseProhibited = new QubitListInSharedArray(containingQubitManager);
                FreeQubitsReuseAllowed = new QubitListInSharedArray(containingQubitManager);
            }
        }

        private Stack<RestrictedReuseSection> RestrictedReuseFreeQubits = new Stack<RestrictedReuseSection>();
        private QubitListInSharedArray FreshFreeQubits;

        // TODO: Currently we cannot extend capacity, but it is possible by reallocating array.
        // No existing value adjustments are necessary.
        // Also borrowing/returning, disabling, and other properties are not yet supported.
        public QubitManagerRestrictedReuse(long qubitCapacity) {
            if (qubitCapacity < MinimumQubitCapacity) {
                qubitCapacity = MinimumQubitCapacity;
            }
            SharedQubitStatusArray = new long[qubitCapacity];
            FreshFreeQubits = new QubitListInSharedArray(this, 0, qubitCapacity-1);

            RestrictedReuseSection outermostSection = new RestrictedReuseSection(this);
            RestrictedReuseFreeQubits.Push(outermostSection);
        }

        // TODO: Although it is not necessary to pass section IDs, this support may be added for extra checks.
        public void ReuseSectionStart() {
            RestrictedReuseSection sectionThatStarts = new RestrictedReuseSection(this);
            RestrictedReuseFreeQubits.Push(sectionThatStarts);
        }

        public void ReuseNextSegment() {
            if (RestrictedReuseFreeQubits.Count <= 0) {
                throw new ApplicationException("Internal error. No reuse sections.");
            }
            if (RestrictedReuseFreeQubits.Count == 1) {
                throw new ApplicationException("Next reuse section without begin.");
            }
            RestrictedReuseSection currentSection = RestrictedReuseFreeQubits.Peek();
            currentSection.FreeQubitsReuseProhibited.MoveAllQubitsFrom(currentSection.FreeQubitsReuseAllowed);
        }

        public void ReuseSectionEnd() {
            ReuseNextSegment();
            RestrictedReuseSection sectionThatEnds = RestrictedReuseFreeQubits.Pop();
            Debug.Assert(sectionThatEnds.FreeQubitsReuseAllowed.IsEmpty());
            RestrictedReuseSection containingSection = RestrictedReuseFreeQubits.Peek();
            containingSection.FreeQubitsReuseAllowed.MoveAllQubitsFrom(sectionThatEnds.FreeQubitsReuseProhibited);
        }

        public long AllocateQubit() {
            // Computation complexity is O(number of nested restricted reuse sections).
            foreach (RestrictedReuseSection section in RestrictedReuseFreeQubits) {
                long id = section.FreeQubitsReuseAllowed.RemoveOneQubit();
                if (id >= 0) {
                    return id;
                }
            }
            return FreshFreeQubits.RemoveOneQubit();
        }

        public  void ReleaseQubit(long id) {
            // Released qubits are added to reuse section in which they were released
            // (rather than section where they are allocated).
            // Although counterintuitive, this makes code simple.
            // This is reasonable because we think qubits should be allocated and released in the same section.
            RestrictedReuseFreeQubits.Peek().FreeQubitsReuseAllowed.AddQubit(id);
        }
/*
 * 
 * FROM HERE ON - Not a real code.
 * 
 * 

#region Qubit creation

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

        // TODO: QUBIT ID IS INT, NOT LONG!!!! JUST DO INTS EVERYWHERE!!!

#endregion

#region IQubitManager - properties

        public virtual bool DisableBorrowing { get; }

        public virtual long FreeQubitsCount { get; protected set; }
        public virtual long AllocatedQubitsCount { get; protected set; }

        // TODO: Move to borrowing
        long QubitsAvailableToBorrowCount(int stackFrame = 0);

        // TODO: NOT AN INTERFACE FUNCTION, MOVE
        public virtual long DisabledQubitsCount { get; protected set; }

#endregion

#region IQubitManager - checks

        public virtual bool IsValid(Qubit qubit) {
            if (qubit == null) { return false; }
            if (qubit.Id >= QubitCapacity) { return false; }
            if (qubit.Id < 0) { return false; }
            return true;
        }
        protected virtual bool IsFree(long id) {
            return SharedQubitStatusArray[id] >= 0;
        }
        public virtual bool IsFree(Qubit qubit) {
            return IsValid(qubit) && IsFree(qubit.Id);
        }
        protected virtual bool IsDisabled(long id) {
            return SharedQubitStatusArray[id] >= 0;
        }
        public virtual bool IsDisabled(Qubit qubit) {
            return IsValid(qubit) && IsDisabled(qubit.Id);
        }

        #endregion

#region IQubitManager.Disable

        /// <summary>
        /// Disables a given qubit.
        /// Once a qubit is disabled it can never be reallocated.
        /// </summary>
        public virtual void Disable(Qubit qubit) {
            if (IsFree(qubit)) {
                // We cannot disable a free qubit because it will break free lists.
                throw new ApplicationException("Cannot disable free qubit.");
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
        public void Disable(IQArray<Qubit> qubitsToDisable) {
            if (qubitsToDisable == null || qubitsToDisable.Length == 0) {
                return;
            }

            foreach (Qubit qubit in qubitsToDisable) {
                this.Disable(qubit);
            }
        }

        #endregion

#region Allocate

        /// <summary>
        /// Allocates a qubit.
        /// Throws a NotEnoughQubits exception if the qubit cannot be allocated. 
        /// </summary>
        public virtual Qubit Allocate() {
            // TODO: May extend capacity!
            // TODO: Who takes care of counting properties
            long newQubitId = AllocateQubit();
            if (newQubitId == None) {
                throw new NotEnoughQubits(1, this.FreeQubitsCount);
            }
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
        IEnumerable<long> AllocatedIds() {
            for (long i = 0; i < QubitCapacity; i++) {
                if (!IsFree(i)) yield return i;
            }
        }


#endregion
*/




    }
}
