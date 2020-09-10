// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

#nullable enable

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// Manages allocation, release, borrowing and return of qubits.
    /// Reuse of qubit Ids is allowed if they have been released.
    /// Allocation and release are O(1) operations.
    /// QubitManager uses memory - sizeof(long)*qubitCapacity. qubitCapacity is passed in to the constructor.
    /// </summary>
    public class QubitManager : IQubitManager
    {
        /// <summary>
        /// Total number of qubits this QubitManager is capable of handling.
        /// </summary>
        protected long NumQubits;
        /// <summary>
        /// The number of currently allocated qubits.
        /// </summary>
        protected long NumAllocatedQubits;
        /// <summary>
        /// The number of disabled qubits.
        /// </summary>
        protected long NumDisabledQubits;
        /// <summary>
        /// Tracks the allocation state of all qubits.
        /// </summary>
        protected long[] qubits; 

        private long None; // Indicates the end of the list of free qubits. If we reach it - we are out of qubits.
        private long Allocated; // All qubits allocated by user will be marked with this number.
        private long Disabled; // All qubits disabled via DisableQubit interface will be marked with this number.
        private long AllocatedForBorrowing; // All qubits allocated only for borrowing, will be marked with this number or higher.
        private long free; // Points to the first free (unallocated) qubit.
        private long freeTail; // Points to the last free (unallocated) qubit. Only valid iff (!EncourageReuse).

        // Options
        protected readonly bool MayExtendCapacity;
        protected readonly bool EncourageReuse;
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

        // stack frame management needed to support borrowing qubits
        #region StackFrameManagement

        protected class StackFrame
        {
            internal IApplyData? Data;
            internal IEnumerable<Qubit>? QubitsInArgument => Data?.Qubits;
            private List<Qubit>? _locals; // Qubits allocated/borrowed in the current operation

            public StackFrame(IApplyData data = null)
            {
                Data = data;
            }

            public List<Qubit> Locals
            {
                get
                {
                    if (_locals == null)
                    {
                        _locals = new List<Qubit>();
                    }

                    return _locals;
                }
            }
        }

        protected readonly Stack<StackFrame> operationStack; // Stack of operation calls, including the current frame for the current scope

        public virtual void OnOperationStart(ICallable _, IApplyData values)
        {
            if (!DisableBorrowing)
            {
                operationStack.Push(new StackFrame(values));
            }
        }

        public virtual void OnOperationEnd(ICallable _, IApplyData values)
        {
            if (!DisableBorrowing)
            {
                operationStack.Pop();
            }
        }

        protected IEnumerable<Qubit> QubitsInUse(StackFrame frame)
        {
            if (DisableBorrowing || frame == null)
            {
                return Qubit.NO_QUBITS;
            }

            return frame.Locals.Concat(frame.QubitsInArgument ?? Array.Empty<Qubit>())
                .Where(q => q != null && !this.IsDisabled(q));
        }

        protected int QubitsInUseCount(StackFrame frame)
        {
            // The following is not really efficient, but let's wait to see if distinct can be part of the contract
            // for the qubitsInArgument parameter of StartOperation call.
            // Well, we are talking about really small arrays here anyway.
            return QubitsInUse(frame).Distinct().Count();
        }

        #endregion

        /// <summary>
        /// Creates and initializes QubitManager that can handle up to numQubits qubits
        /// </summary>
        public QubitManager(
            long qubitCapacity, 
            bool mayExtendCapacity = false, 
            bool disableBorrowing = false, 
            bool encourageReuse = true)
        {
            MayExtendCapacity = mayExtendCapacity;
            EncourageReuse = encourageReuse;
            DisableBorrowing = disableBorrowing;

            if (qubitCapacity <= 0) { qubitCapacity = MinQubitCapacity; }

            UpdateQubitCapacity(qubitCapacity);

            for (long i = 0; i < NumQubits; i++)
            {
                this.qubits[i] = i + 1;
            }
            Debug.Assert(this.qubits[NumQubits - 1] == None);

            free = 0;
            freeTail = NumQubits - 1;
            NumAllocatedQubits = 0;
            NumDisabledQubits = 0;

            if (!DisableBorrowing)
            {
                operationStack = new Stack<StackFrame>();
                operationStack.Push(new StackFrame());
            }
        }

        private class QubitNonAbstract : Qubit
        {
            // This class is only needed because Qubit is abstract. 
            // It is equivalent to Qubit and adds nothing to it except the ability to create it.
            // It should be used only in CreateQubitObject below, and nowhere else.
            // When Qubit stops being abstract, this class should be removed.
            public QubitNonAbstract(int id) : base(id) { }
        }

        /// <summary>
        /// May be overriden to create a custom Qubit object of a derived type.
        /// </summary>
        /// <param name="id">unique qubit id</param>
        /// <returns>a newly instantiated qubit</returns>
        public virtual Qubit CreateQubitObject(long id)
        { 
            if (id >= Int32.MaxValue)
            {
                throw new NotSupportedException($"Qubit id out of range.");
            }
            return new QubitNonAbstract((int)id);
        }

        public virtual bool IsValid(Qubit qubit)
        {
            if (qubit == null) { return false; }
            if (qubit.Id >= NumQubits) { return false; }
            if (qubit.Id < 0) { return false; }
            return true;
        }

        private bool IsFree(long id)
        {
            return qubits[id] < Allocated;
        }

        public virtual bool IsFree(Qubit qubit)
        {
            return IsValid(qubit) && IsFree(qubit.Id);
        }

        private bool IsDisabled(long id)
        {
            return (qubits[id] == Disabled);
        }

        public virtual bool IsDisabled(Qubit qubit)
        {
            return IsValid(qubit) && IsDisabled(qubit.Id);
        }

        private bool IsAllocatedForBorrowing(long id)
        {
            return qubits[id] >= AllocatedForBorrowing;
        }

        public virtual long QubitsAvailableToBorrowCount(int stackFrame)
        {
            if (DisableBorrowing)
            {
                return 0;
            }

            var popped = new Stack<StackFrame>();
            while (--stackFrame > 0)
            {
                popped.Push(operationStack.Pop());
            }
            StackFrame frame = operationStack.Peek();
            while (popped.TryPop(out var f))
            {
                operationStack.Push(f);
            }
            return NumAllocatedQubits - QubitsInUseCount(frame);
        }

        public long FreeQubitsCount => NumQubits - NumDisabledQubits - NumAllocatedQubits;

        public long AllocatedQubitsCount => NumAllocatedQubits;

        public virtual IEnumerable<long> AllocatedIds()
        {
            for (long i = 0; i < qubits.LongLength; i++)
            {
                if (!IsFree(i)) yield return i;
            }
        }

        #region Disable

        /// <summary>
        /// Disables a given qubit.
        /// Once a qubit is disabled it can never be reallocated.
        /// </summary>
        public virtual void Disable(Qubit qubit)
        {
            qubits[qubit.Id] = Disabled;
            NumDisabledQubits++;

            NumAllocatedQubits--;
            Debug.Assert(NumAllocatedQubits >= 0);
        }

        /// <summary>
        /// Disables a set of given qubits.
        /// Once a qubit is disabled it can never be reallocated.
        /// </summary>
        public void Disable(IQArray<Qubit> qubitsToDisable)
        {
            if (qubitsToDisable == null || qubitsToDisable.Length == 0)
            {
                return;
            }

            foreach (Qubit qubit in qubitsToDisable)
            {
                this.Disable(qubit);
            }
        }

        #endregion

        #region Allocate

        /// <summary>
        /// Allocates a qubit.
        /// Returns null if the qubit cannot be allocated.
        /// </summary>
        protected virtual Qubit? Allocate(bool usedOnlyForBorrowing)
        {
            if (free == None)
            {
                if (!MayExtendCapacity)
                {
                    return null;
                }

                long oldNumQubits = NumQubits;
                long oldNone = None;
                long oldAllocated = Allocated;
                long oldDisabled = Disabled;
                long oldAllocatedForBorrowing = AllocatedForBorrowing;
                long[] oldQubitsArray = this.qubits;

                UpdateQubitCapacity(oldNumQubits * 2); // This changes Allocated, Disabled, AllocatedForBorrowing markers.

                for (long i = 0; i < oldNumQubits; i++)
                {
                    if (oldQubitsArray[i] == oldNone)
                    {
                        // Point to the first new (free) element
                        this.qubits[i] = oldNumQubits;
                    }
                    else if (oldQubitsArray[i] == oldAllocated)
                    {
                        // Allocated qubits are marked differently now.
                        this.qubits[i] = Allocated;
                    }
                    else if (oldQubitsArray[i] == oldDisabled)
                    {
                        // Disabled qubits are marked differently now.
                        this.qubits[i] = Disabled;
                    }
                    else if (oldQubitsArray[i] >= oldAllocatedForBorrowing)
                    {
                        // This updates refCounts
                        this.qubits[i] = (oldQubitsArray[i] - oldAllocatedForBorrowing) + AllocatedForBorrowing;
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
                    freeTail = NumQubits - 1;
                }
            }

            Qubit ret = CreateQubitObject(free);
            long temp = free;
            free = qubits[free];
            qubits[temp] = (usedOnlyForBorrowing ? AllocatedForBorrowing : Allocated);

            NumAllocatedQubits++;
            if (!DisableBorrowing)
            {
                operationStack.Peek().Locals.Add(ret);
            }
            return ret;
        }

        /// <summary>
        /// Allocates a qubit.
        /// Throws a NotEnoughQubits exception if the qubit cannot be allocated. 
        /// </summary>
        public Qubit Allocate()
        {
            Qubit? qb = Allocate(usedOnlyForBorrowing: false);
            if (qb == null)
            {
                throw new NotEnoughQubits(1, this.FreeQubitsCount);
            }
            return qb;
        }

        /// <summary>
        /// Allocates numToAllocate new qubits.
        /// Throws a NotEnoughQubits exception without allocating any qubits if the qubits cannot be allocated. 
        /// </summary>
        public IQArray<Qubit> Allocate(long numToAllocate)
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
                Qubit? allocated = Allocate(usedOnlyForBorrowing: false);
                if (allocated == null)
                {
                    for (int k = 0; k < i; k++)
                    {
                        Release(result[k], wasUsedOnlyForBorrowing: false);
                    }
                    throw new NotEnoughQubits(numToAllocate, this.FreeQubitsCount);
                }
                result.Modify(i, allocated);
            }

            return result;
        }

        #endregion

        #region Release

        protected virtual void Release(Qubit qubit, bool wasUsedOnlyForBorrowing)
        {
            if (qubits[qubit.Id] == Disabled)
            {
                // Nothing to do. It will stay disabled.
                return;
            }

            if (qubits[qubit.Id] != (wasUsedOnlyForBorrowing ? AllocatedForBorrowing : Allocated))
            {
                throw new ArgumentException("Attempt to free qubit that has not been allocated.");
            }

            if (EncourageReuse) { 
                qubits[qubit.Id] = free;
                free = qubit.Id;
            } 
            else
            {
                // If we are allowed to extend capacity we will never reuse this qubit, 
                // otherwise we need to add it to the free qubits list.
                if (!MayExtendCapacity)
                {
                    if (qubits[freeTail] != None)
                    {
                        // There were no free qubits at all
                        free = qubit.Id;
                    }
                    else
                    {
                        qubits[freeTail] = qubit.Id;
                    }
                }
                qubits[qubit.Id] = None;
                freeTail = qubit.Id;
            }

            NumAllocatedQubits--;
            Debug.Assert(NumAllocatedQubits >= 0);

            if (!DisableBorrowing)
            {
                bool success = operationStack.Peek().Locals.Remove(qubit);
                Debug.Assert(success, "Releasing qubit that is not a local variable in scope.");
            }
        }

        /// <summary>
        /// Releases a given qubit.
        /// </summary>
        public void Release(Qubit qubit)
        {
            Release(qubit, wasUsedOnlyForBorrowing: false);
        }

        /// <summary>
        /// Releases a set of given qubits.
        /// </summary>
        public void Release(IQArray<Qubit> qubitsToRelease)
        {
            if (qubitsToRelease == null || qubitsToRelease.Length == 0)
            {
                return;
            }

            for (long i = qubitsToRelease.Length-1; i>=0; i--)
            { // Going from the end is more efficient in case we are tracking scope.
                this.Release(qubitsToRelease[i], wasUsedOnlyForBorrowing: false);
            }
        }

        #endregion

        #region Borrow

        /// <summary>
        /// Returns a qubit that is allocated, not disabled, and not listed as in use, whose id is in [minId, maxId).
        /// </summary>
        /// <param name="qubitsInUseSortedById">Contains the qubits that cannot be borrowed, where the qubits with the lowest ids are queued first.</param>
        /// <param name="minId">Only qubits whose id is larger or equal to minId will be considered for borrowing. Set to 0 if unspecified.</param>
        /// <param name="maxId">Only qubits whose id is smaller than maxId will be considered for borrowing. Set to NumQubits if unspecified.</param>
        /// <returns></returns>
        protected virtual Qubit? Borrow(Stack<Qubit> qubitsInUseSortedById, long minId = 0, long maxId = -1)
        {
            maxId = maxId < 0 ? NumQubits : maxId;
            for (long curQubit = System.Math.Max(0, minId); curQubit < maxId; curQubit++)
            {
                if (IsFree(curQubit) || IsDisabled(curQubit))
                {
                    continue;
                }

                bool gotNextInUse = qubitsInUseSortedById.TryPeek(out Qubit nextInUse);
                if (gotNextInUse && nextInUse.Id == curQubit)
                {
                    qubitsInUseSortedById.Pop();
                    continue;
                }

                if (IsAllocatedForBorrowing(curQubit))
                {
                    qubits[curQubit]++;
                }

                Qubit ret = CreateQubitObject(curQubit);
                if (!DisableBorrowing)
                {
                    operationStack.Peek().Locals.Add(ret);
                }
                return ret;
            }
            return null;
        }

        // internal for testing purposes
        internal IQArray<Qubit> Borrow(long numToBorrow, IEnumerable<Qubit> qubitsInUse)
        {
            var inUse = new Stack<Qubit>(qubitsInUse.Distinct().OrderByDescending(q => q.Id));
            var borrowed = QArray<Qubit>.Create(numToBorrow);
            long numBorrowed = System.Math.Min(NumAllocatedQubits - inUse.Count, numToBorrow);

            long lastBorrowedId = -1;
            for (long curBorrowed = 0; curBorrowed < numBorrowed; ++curBorrowed)
            {
                Qubit? bq = Borrow(inUse, minId: lastBorrowedId + 1);
                if (bq == null) // should not happen
                {
                    numBorrowed = curBorrowed;
                    break;
                }
                borrowed.Modify(curBorrowed, bq);
                lastBorrowedId = borrowed[curBorrowed].Id;
            }

            if (numBorrowed < numToBorrow)
            { // Not enough qubits to borrow. Allocate what was not borrowed.
                for (long i = numBorrowed; i < numToBorrow; i++)
                {
                    Qubit? allocated = Allocate(usedOnlyForBorrowing: true);
                    if (allocated == null)
                    {
                        for (long k = numBorrowed; k < i; k++)
                        {
                            Release(borrowed[(int)k], wasUsedOnlyForBorrowing: true);
                        }
                        throw new NotEnoughQubits(numToBorrow, numBorrowed + this.FreeQubitsCount);
                    }
                    borrowed.Modify(i, allocated);
                }
            }

            return borrowed;
        }

        /// <summary>
        /// Borrows a number of qubits. Chooses them from among already allocated ones.
        /// If there are not enough qubits to borrow, allocates new ones.
        /// </summary>
        public IQArray<Qubit> Borrow(long numToBorrow) 
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

            return Borrow(numToBorrow, QubitsInUse(operationStack.Peek()));
        }

        public Qubit Borrow()
        {
            if (DisableBorrowing)
            {
                return Allocate();
            }

            var inUse = new Stack<Qubit>(QubitsInUse(operationStack.Peek()).Distinct().OrderByDescending(q => q.Id));
            return NumAllocatedQubits == inUse.Count ? Allocate() : (Borrow(inUse) ?? Allocate());
        }

        #endregion

        #region Return

        /// <summary>
        /// Returns a given borrowed qubit.
        /// Releases it if it has been allocated just for borrowing.
        /// </summary>
        public virtual void Return(Qubit qubit)
        {
            if (DisableBorrowing)
            {
                this.Release(qubit, wasUsedOnlyForBorrowing: false);
            }
            else
            {
                var needsToBeReleased = false;
                if (IsAllocatedForBorrowing(qubit.Id))
                {
                    if (qubits[qubit.Id] == AllocatedForBorrowing)
                    {
                        needsToBeReleased = true;
                    }
                    else
                    {
                        qubits[qubit.Id]--;
                    }
                }

                if (needsToBeReleased)
                {
                    this.Release(qubit, wasUsedOnlyForBorrowing: true);
                }
                else
                {
                    bool success = operationStack.Peek().Locals.Remove(qubit); // Could be more efficient here going from the end manually.
                    Debug.Assert(success, "Returning qubit that is not a local variable in scope.");
                }
            }
        }

        /// <summary>
        /// Returns a set of borrowed qubits given.
        /// Releases those that have been allocated just for borrowing.
        /// </summary>
        public void Return(IQArray<Qubit> qubitsToReturn)
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
    }

    #endregion
}
