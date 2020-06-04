// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// Manages allocation, release, borrowing and return of qubits.
    /// Reuse of qubit Ids is allowed if they have been released.
    /// Allocation and release are O(1) operations.
    /// QubitManager uses memory - sizeof(long)*qubitCapacity. qubitCapacity is passed in to the constructor.
    /// </summary>
    public class QubitManager
    {
        long NumQubits; // Total number of qubits this QubitManager is capable of handling.
        long None; // Indicates the end of the list of free qubits. If we reach it - we are out of qubits.
        long Allocated; // All qubits allocated by user will be marked with this number.
        long Disabled; // All qubits disabled via DisableQubit interface will be marked with this number.
        long AllocatedForBorrowing; // All qubits allocated only for borrowing, will be marked with this number or higher.
        long[] qubits; // Tracks the allocation state of all qubits.
        long free; // Points to the first free (unallocated) qubit.
        long numAllocatedQubits; // Tracking this for optimization.
        long numDisabledQubits; // Number of disabled qubits.

        // Options
        bool MayExtendCapacity;
        public bool DisableBorrowing { get; }

        const long MaxQubitCapacity = long.MaxValue - 3;
        const long MinQubitCapacity = 8;

        // Implementation note:
        // The "long[] qubits" array has the following discipline:
        // For qubits that are allocated, the array stores the value "Allocated"
        // For qubits that are disabled, the array stores the value "Disabled", whether they have been released or not.
        // If a qubit was allocated only for the purposes of borrowing (there were not enough available allocated 
        //     qubits to satisfy a borrrowing request), the array stores the refcount of how many times this qubit has been 
        //     borrowed, increased by the value of "AllocatedForBorrowing" constant (minus one).
        //     When this refcount goes down to "AllocatedForBorrowing", the qubit will be released.
        // For qubits that are free, the array stores the index of the next free qubit (a value less than "Allocated" constant).
        //     The last free qubit in the list of free qubits stores the value "None".

        /// <summary>
        /// Creates and initializes QubitManager that can handle up to numQubits qubits
        /// </summary>
        public QubitManager(long qubitCapacity, bool mayExtendCapacity = false, bool disableBorrowing = false)
        {
            MayExtendCapacity = mayExtendCapacity;
            DisableBorrowing = disableBorrowing;

            if (qubitCapacity <= 0) { qubitCapacity = MinQubitCapacity; }

            UpdateQubitCapacity(qubitCapacity);

            for (long i = 0; i < NumQubits; i++)
            {
                this.qubits[i] = i + 1;
            }
            Debug.Assert(this.qubits[NumQubits - 1] == None);

            free = 0;
            numAllocatedQubits = 0;
            numDisabledQubits = 0;
        }

        private void UpdateQubitCapacity(long newQubitCapacity)
        {
            Debug.Assert(newQubitCapacity < MaxQubitCapacity);
            NumQubits = newQubitCapacity;
            None = NumQubits;
            Allocated = NumQubits + 1;
            Disabled = NumQubits + 2;
            AllocatedForBorrowing = NumQubits + 3;
            this.qubits = new long[NumQubits];
        }

        private void ExtendQubitArray()
        {
            long oldNumQubits = NumQubits;
            long oldNone = None;
            long oldAllocated = Allocated;
            long oldDisabled = Disabled;
            long oldAllocatedForBorrowing = AllocatedForBorrowing;
            long[] oldQubitsArray = this.qubits;

            UpdateQubitCapacity(oldNumQubits*2); // This changes Allocated, Disabled, AllocatedForBorrowing markers.

            for (long i = 0; i < oldNumQubits; i++)
            {
                if (oldQubitsArray[i] == oldNone) {
                    // Point to the first new (free) element
                    Debug.Assert(false,"Why do we extend an array, when we still have available slots?");
                    this.qubits[i] = oldNumQubits; 
                } else if (oldQubitsArray[i] == oldAllocated) {
                    // Allocated qubits are marked differently now.
                    this.qubits[i] = Allocated;
                }
                else if (oldQubitsArray[i] == oldDisabled)
                {
                    // Disabled qubits are marked differently now.
                    this.qubits[i] = Disabled;
                }
                else if (oldQubitsArray[i] >= oldAllocatedForBorrowing) {
                    // This updates refCounts
                    this.qubits[i] = (oldQubitsArray[i] - oldAllocatedForBorrowing) + AllocatedForBorrowing ;
                }
            }

            for (long i = oldNumQubits; i < NumQubits; i++)
            {
                this.qubits[i] = i + 1;
            }
            Debug.Assert(this.qubits[NumQubits - 1] == None);

            if (free == oldNone)
            {
                free = oldNumQubits;
            } else
            {
                Debug.Assert(false, "Why do we extend an array, when we still have available slots?");
            }
        }

        public bool IsValid(Qubit qubit)
        {
            if (qubit == null) { return false; }
            if (qubit.Id >= NumQubits) { return false; }
            if (qubit.Id < 0) { return false; }
            return true;
        }

        public bool IsFree(Qubit qubit)
        {
            if (!IsValid(qubit)) { return false; }
            return IsFree(qubit.Id);
        }

        private bool IsFree(long id)
        {
            return qubits[id] < Allocated;
        }

        public bool IsDisabled(Qubit qubit)
        {
            if (!IsValid(qubit)) { return false; }
            return IsDisabled(qubit.Id);
        }

        private bool IsDisabled(long id)
        {
            return (qubits[id] == Disabled);
        }

        private bool IsAllocatedForBorrowing(long id)
        {
            return qubits[id] >= AllocatedForBorrowing;
        }

        // Returns true if qubit needs to be released: It has been allocated for borrowing and is not borrowed any more.
        private bool BorrowingRefCountIsOne(long id)
        {
            if (IsAllocatedForBorrowing(id))
            {
                if (qubits[id] == AllocatedForBorrowing)
                {
                    return true;
                }
            }
            return false;
        }

        // Returns true if qubit needs to be released: It has been allocated for borrowing and is not borrowed any more.
        private bool DecreaseBorrowingRefCount(long id)
        {
            if (IsAllocatedForBorrowing(id)) {
                if (qubits[id] == AllocatedForBorrowing)
                {
                    return true;
                }
                else
                {
                    qubits[id]--;
                    return false;
                }
            } else
            {
                return false;
            }
        }

        private void IncreaseBorrowingRefCount(long id)
        {
            if (IsAllocatedForBorrowing(id))
            {
                qubits[id]++;
            }
        }

        /// <summary>
        /// Allocates a qubit.
        /// </summary>
        protected virtual Qubit AllocateOneQubit(bool usedOnlyForBorrowing)
        {
            if (free == None)
            {
                if (MayExtendCapacity)
                {
                    ExtendQubitArray();
                }
                else
                {
                    return null;
                }
            }
            Qubit result = CreateQubitObject(free);
            long temp = free;
            free = qubits[free];
            qubits[temp] = (usedOnlyForBorrowing ? AllocatedForBorrowing : Allocated);

            numAllocatedQubits++;
            return result;
        }

        private class QubitNonAbstract : Qubit
        {
            // This class is only needed because Qubit is abstract. 
            // It is equivalent to Qubit and adds nothing to it except the ability to create it.
            // It should be used only in CreateQubitObject below, and nowhere else.
            // When Qubit stops being abstract, this class should be removed.
            public QubitNonAbstract(int id) : base(id) { }
        }

        public virtual Qubit CreateQubitObject(long id)
        { // User may override it to create his own Qubit object of a derived type.
            return new QubitNonAbstract((int)id);
        }

        /// <summary>
        /// Allocates a qubit.
        /// </summary>
        public virtual Qubit Allocate()
        {
            Qubit qb = AllocateOneQubit(usedOnlyForBorrowing: false);
            if (qb == null)
            {
                throw new NotEnoughQubits(1, GetFreeQubitsCount());
            }
            return qb;
        }

        /// <summary>
        /// Allocates numToAllocate new qubits.
        /// </summary>
        public virtual IQArray<Qubit> Allocate(long numToAllocate)
        {
            if (numToAllocate < 0)
            {
                throw new ArgumentException("Attempt to allocate negative number of qubits.");
            }
            else if (numToAllocate == 0)
            {
                return QArray<Qubit>.Create(0);
            }

            QArray<Qubit> result = QArray<Qubit>.Create(numToAllocate); 

            for (int i = 0; i < numToAllocate; i++)
            {
                result.Modify(i, AllocateOneQubit(usedOnlyForBorrowing: false));
                if (result[i] == null)
                {
                    for (int k = 0; k < i; k++)
                    {
                        Release(result[k]);
                    }
                    throw new NotEnoughQubits(numToAllocate, GetFreeQubitsCount());
                }
            }

            return result;
        }

        protected virtual void ReleaseOneQubit(Qubit qubit, bool usedOnlyForBorrowing)
        {
            if (qubits[qubit.Id] == Disabled)
            {
                // Nothing to do. It will stay disabled.
                // Alternatively, we could mark is as None here.
            }
            else
            {
                long Occupied = (usedOnlyForBorrowing ? AllocatedForBorrowing : Allocated);
                if (qubits[qubit.Id] != Occupied)
                {
                    throw new ArgumentException("Attempt to free qubit that has not been allocated.");
                }
                qubits[qubit.Id] = free;
                free = qubit.Id;

                numAllocatedQubits--;
                Debug.Assert(numAllocatedQubits >= 0);
            }
        }

        /// <summary>
        /// Releases a given qubit.
        /// </summary>
        public virtual void Release(Qubit qubit)
        {
            ReleaseOneQubit(qubit, usedOnlyForBorrowing: false);
        }

        /// <summary>
        /// Releases a set of given qubits.
        /// </summary>
        public virtual void Release(IQArray<Qubit> qubitsToRelease)
        {
            if (qubitsToRelease == null || qubitsToRelease.Length == 0)
            {
                return;
            }

            for (long i = qubitsToRelease.Length-1; i>=0; i--)
            { // Going from the end is more efficient in case we are tracking scope.
                this.ReleaseOneQubit(qubitsToRelease[i], usedOnlyForBorrowing: false);
            }
        }

        protected virtual void DisableOneQubit(Qubit qubit)
        {
            // Note: Borrowed qubits cannot be disabled.
            Debug.Assert(qubits[qubit.Id] == Allocated);
            qubits[qubit.Id] = Disabled;
            numDisabledQubits++;

            numAllocatedQubits--;
            Debug.Assert(numAllocatedQubits >= 0);
        }

        /// <summary>
        /// Disables a given qubit.
        /// Once a qubit is disabled it can never be reallocated.
        /// </summary>
        public virtual void Disable(Qubit qubit)
        {
            DisableOneQubit(qubit);
        }

        /// <summary>
        /// Disables a set of given qubits.
        /// Once a qubit is disabled it can never be reallocated.
        /// </summary>
        public virtual void Disable(IQArray<Qubit> qubitsToDisable)
        {
            if (qubitsToDisable == null || qubitsToDisable.Length == 0)
            {
                return;
            }

            foreach (Qubit qubit in qubitsToDisable)
            {
                this.DisableOneQubit(qubit);
            }
        }


        public long GetQubitsAvailableToBorrowCount(IEnumerable<Qubit> excludedQubitsSortedById)
        {
            // Note: this function is not allowed to call its no-parameters cousin: GetQubitsAvailableToBorrowCount()
            return numAllocatedQubits - excludedQubitsSortedById.Count();
        }

        public virtual long GetQubitsAvailableToBorrowCount()
        {
            return numAllocatedQubits;
        }

        public virtual long GetParentQubitsAvailableToBorrowCount()
        {
            return GetQubitsAvailableToBorrowCount();
        }


        public long GetFreeQubitsCount()
        {
            return NumQubits - numDisabledQubits - numAllocatedQubits;
        }

        public long GetAllocatedQubitsCount()
        {
            return numAllocatedQubits;
        }

        public IEnumerable<long> GetAllocatedIds()
        {
            for (long i = 0; i < qubits.LongLength; i++)
            {
                if (!IsFree(i)) yield return i;
            }
        }

        /// <summary>
        /// Borrows a number of qubits. Chooses them from among already allocated ones.
        /// Makes sure borrowed qubits are not on the exclusion list.
        /// Exclusion list is supposed to contain qubits that can not be borrowed, 
        /// for example those, that are being used (or could be used) in the current context.
        /// If there are not enough qubits to borrow, allocates new ones.
        /// </summary>
        public virtual IQArray<Qubit> Borrow(long numToBorrow, IEnumerable<Qubit> excludedQubitsSortedById) // Note, excluded could be an array of Ids for efficiency, if it is convenient for compiler.
        {
            if (numToBorrow < 0)
            {
                throw new ArgumentException("Attempt to borrow negative number of qubits.");
            }
            else if (numToBorrow == 0)
            {
                return QArray<Qubit>.Create(0);
            }

            if (DisableBorrowing)
            {
                return Allocate(numToBorrow);
            }

            if (excludedQubitsSortedById == null) {
                excludedQubitsSortedById = new Qubit[0];
            }

            QArray<Qubit> result = QArray<Qubit>.Create(numToBorrow); 
            long numBorrowed = TryBorrow(numToBorrow, result, excludedQubitsSortedById);

            if (numBorrowed < numToBorrow)
            { // Not enough qubits to borrow. Allocate what was not borrowed.
                for (long i = numBorrowed; i < numToBorrow; i++)
                {
                    result.Modify(i, AllocateOneQubit(usedOnlyForBorrowing: true));
                    if (result[(int)i] == null)
                    {
                        for (long k = numBorrowed; k < i; k++)
                        {
                            ReleaseOneQubit(result[(int)k], usedOnlyForBorrowing: true);
                        }
                        throw new NotEnoughQubits(numToBorrow, numBorrowed + GetFreeQubitsCount());
                    }
                }
            }

            return result;
        }

        protected virtual Qubit BorrowOneQubit(long id)
        {
            IncreaseBorrowingRefCount(id);
            return CreateQubitObject(id);
        }

        private long TryBorrow(long numToBorrow, QArray<Qubit> result, IEnumerable<Qubit> excludedQubitsSortedById)
        {
            long curQubit = 0;
            long numBorrowed = 0;
            long curBorrowed = 0;
            IEnumerator<Qubit> enumer = excludedQubitsSortedById.GetEnumerator();
            bool exclusionsPresent = enumer.MoveNext();

            numBorrowed = System.Math.Min(GetQubitsAvailableToBorrowCount(excludedQubitsSortedById), numToBorrow);

            while (curBorrowed < numBorrowed)
            {
                while (IsFree(curQubit) || IsDisabled(curQubit))
                {
                    curQubit++;
                    Debug.Assert(curQubit < NumQubits);
                }
                Debug.Assert((!exclusionsPresent) || (enumer.Current.Id >= curQubit));
                if ((!exclusionsPresent) || (enumer.Current.Id != curQubit))
                {
                    result.Modify(curBorrowed, BorrowOneQubit(curQubit));
                    curBorrowed++;
                }
                else
                {
                    exclusionsPresent = enumer.MoveNext();
                }
                curQubit++;
                Debug.Assert(curQubit < NumQubits);
            }
            return numBorrowed;
        }

        protected virtual void ReturnOneQubit(Qubit qubit)
        {
        }

        /// <summary>
        /// Returns true if a qubit has been allocated just for borrowing, has been borrowed exactly once,
        /// and thus will be released after it is returned.
        /// </summary>
        public virtual bool ToBeReleasedAfterReturn(Qubit qubit)
        {
            return BorrowingRefCountIsOne(qubit.Id);
        }

        /// <summary>
        /// Returns a count of input qubits that have been allocated just for borrowing, borrowed exactly once,
        /// and thus will be released after they are returned.
        /// </summary>
        public virtual long ToBeReleasedAfterReturnCount(IQArray<Qubit> qubitsToReturn)
        {
            if (qubitsToReturn == null || qubitsToReturn.Length == 0)
            {
                return 0;
            }

            long count = 0;
            foreach (Qubit qubit in qubitsToReturn)
            {
                if (this.ToBeReleasedAfterReturn(qubit)) 
                { 
                    count++; 
                }
            }
            return count;
        }

        /// <summary>
        /// Returns a given borrowed qubit.
        /// Releases it if it has been allocated just for borrowing.
        /// </summary>
        public virtual void Return(Qubit qubit)
        {
            if (DisableBorrowing)
            {
                this.ReleaseOneQubit(qubit, usedOnlyForBorrowing: false);
            }
            else
            {
                if (DecreaseBorrowingRefCount(qubit.Id))
                {
                    this.ReleaseOneQubit(qubit, usedOnlyForBorrowing: true);
                }
                else
                {
                    this.ReturnOneQubit(qubit);
                }
            }
        }

        /// <summary>
        /// Returns a set of borrowed qubits given.
        /// Releases those that have been allocated just for borrowing.
        /// </summary>
        public virtual void Return(IQArray<Qubit> qubitsToReturn)
        {
            if (qubitsToReturn == null || qubitsToReturn.Length == 0)
            {
                return;
            }

            for (long i = qubitsToReturn.Length - 1; i >= 0; i--)
            { // Going from the end is more efficient in case we are tracking scope.
                this.Return(qubitsToReturn[i]);
            }
        }

        /// <summary>
        ///  Same as Borrow, but allows array of exluded qubits to be unsorted. It is recommended to use Borrow instead.
        /// </summary>
        /// <param name="numToBorrow"></param>
        /// <param name="excludedQubits"></param>
        /// <returns></returns>
        public virtual IQArray<Qubit> BorrowUnsorted(long numToBorrow, IEnumerable<Qubit> excludedQubits) // Note, excluded could be an array of Ids for efficiency, if it is convenient for compiler.
        {
            if (DisableBorrowing)
            {
                return Allocate(numToBorrow);
            }
            return Borrow(numToBorrow, excludedQubits.OrderBy(Qubit => Qubit.Id));
        }
    }

}
