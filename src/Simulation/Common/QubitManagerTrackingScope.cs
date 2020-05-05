// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Common
{
    public class QubitManagerTrackingScope : QubitManager, IQubitManager
    {

        private class StackFrame
        {
            internal IApplyData Data;
            internal IEnumerable<Qubit> QubitsInArgument => Data?.Qubits;
            internal List<Qubit> _locals; // Qubits allocated/borrowed in the current operation

            public StackFrame()
            {
                Data = null;
            }

            public StackFrame(IApplyData data)
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

        private Stack<StackFrame> operationStack; // Stack of operation calls.
        private StackFrame curFrame; // Current stack frame - all qubits in current scope are listed here.

        public QubitManagerTrackingScope(long qubitCapacity, bool mayExtendCapacity = false, bool disableBorrowing = false) 
            : base(qubitCapacity, mayExtendCapacity, disableBorrowing)
        {
            if (!DisableBorrowing)
            {
                operationStack = new Stack<StackFrame>();
                curFrame = new StackFrame();
            }
        }

        public void OnOperationStart(ICallable operation, IApplyData values)
        {
            if (!DisableBorrowing)
            {
                operationStack.Push(curFrame);
                curFrame = new StackFrame(values);
            }
        }

        public void OnOperationEnd(ICallable operation, IApplyData values)
        {
            if (!DisableBorrowing)
            {
                curFrame = operationStack.Pop();
            }
        }

        protected override Qubit AllocateOneQubit(bool usedOnlyForBorrowing)
        {
            Qubit ret = base.AllocateOneQubit(usedOnlyForBorrowing);
            if (!DisableBorrowing)
            {
                curFrame.Locals.Add(ret);
            }
            return ret;
        }

        protected override void ReleaseOneQubit(Qubit qubit, bool usedOnlyForBorrowing)
        {
            base.ReleaseOneQubit(qubit, usedOnlyForBorrowing);
            if (!DisableBorrowing)
            {
                bool success = curFrame.Locals.Remove(qubit);
                Debug.Assert(success, "Releasing qubit that is not a local variable in scope.");
            }
        }

        protected override Qubit BorrowOneQubit(long id)
        {
            Qubit ret = base.BorrowOneQubit(id);
            if (!DisableBorrowing)
            {
                curFrame.Locals.Add(ret);
            }
            return ret;
        }

        protected override void ReturnOneQubit(Qubit qubit)
        {
            base.ReturnOneQubit(qubit);
            if (!DisableBorrowing)
            {
                bool success = curFrame.Locals.Remove(qubit); // Could be more efficient here going from the end manually.
                Debug.Assert(success, "Returning qubit that is not a local variable in scope.");
            }
        }

        private IEnumerable<Qubit> ExcludedQubitsForFrame(StackFrame curFrame)
        {
            var qubitsInArgument = curFrame.QubitsInArgument?.ToArray();
            long numExcluded = curFrame.Locals.Count + (qubitsInArgument?.Length ?? 0);
            var excludedQubits = new Qubit[numExcluded];

            int k = 0;
            if (qubitsInArgument != null)
            {
                foreach (Qubit q in qubitsInArgument)
                {
                    excludedQubits[k] = q;
                    k++;
                }
            }
            foreach (Qubit q in curFrame.Locals)
            {
                excludedQubits[k] = q;
                k++;
            }
            Debug.Assert(k == numExcluded);

            // The following is not really efficient, but let's wait to see if distinct can be part of the contract
            // for the qubitsInArgument parameter of StartOperation call.
            // Well, we are talking about really small arrays here anyway.
            return excludedQubits.Where(q => q != null).Distinct().OrderBy(Qubit => Qubit.Id);
        }

        private IEnumerable<Qubit> ConstructExcludedQubitsArray()
        {
            if (DisableBorrowing)
            {
                return Qubit.NO_QUBITS;
            }

            return ExcludedQubitsForFrame(curFrame);
        }

        private IEnumerable<Qubit> ConstructParentExcludedQubitsArray()
        {
            if (DisableBorrowing)
            {
                return Qubit.NO_QUBITS;
            }

            if (operationStack.Count < 1)
            {
                return Qubit.NO_QUBITS;
            }

            // curFrame is the current frame. operationStack only contains "out" frames,
            // but not the current frame. Thus, the top of the stack is the parent frame, 
            // not the current frame.
            return ExcludedQubitsForFrame(operationStack.Peek());
        }

        public virtual Qubit Borrow()
        {
            return base.Borrow(1, ConstructExcludedQubitsArray())[0];
        }

        public virtual IQArray<Qubit> Borrow(long numToBorrow)
        {
            return base.Borrow(numToBorrow, ConstructExcludedQubitsArray());
        }

        public override long GetQubitsAvailableToBorrowCount()
        {
            if (!DisableBorrowing)
            {
                return GetQubitsAvailableToBorrowCount(ConstructExcludedQubitsArray());
            }
            else
            {
                return 0;
            }
        }

        public override long GetParentQubitsAvailableToBorrowCount()
        {
            if (!DisableBorrowing)
            {
                return GetQubitsAvailableToBorrowCount(ConstructParentExcludedQubitsArray());
            }
            else
            {
                return 0;
            }
        }
    }
}
