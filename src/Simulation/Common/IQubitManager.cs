// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Common
{
    using System.Collections.Generic;
    using Microsoft.Quantum.Simulation.Core;

    public interface IQubitManager
    {
        bool DisableBorrowing { get; }

        bool IsValid(Qubit qubit);
        bool IsFree(Qubit qubit);
        bool IsDisabled(Qubit qubit);

        long GetFreeQubitsCount();
        long GetQubitsAvailableToBorrowCount(int stackFrame = 0);
        long GetAllocatedQubitsCount();
        IEnumerable<long> GetAllocatedIds();

        void Disable(Qubit qubit);
        void Disable(IQArray<Qubit> qubits);

        Qubit Allocate();
        IQArray<Qubit> Allocate(long count);

        void Release(Qubit qubit);
        void Release(IQArray<Qubit> qubits);

        Qubit Borrow();
        IQArray<Qubit> Borrow(long count);

        void Return(Qubit q);
        void Return(IQArray<Qubit> qubits);

        /// <summary>
        /// Callback to notify QubitManager that an operation execution has started. 
        /// This helps manage qubits scope.
        /// </summary>
        void OnOperationStart(ICallable operation, IApplyData values);

        /// <summary>
        /// Callback to notify QubitManager that an operation execution has ended. 
        /// This helps manage qubits scope.
        /// </summary>
        void OnOperationEnd(ICallable operation, IApplyData values);
    }
}
