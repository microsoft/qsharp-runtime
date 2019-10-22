// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Common
{
    using Microsoft.Quantum.Simulation.Core;
    using System.Collections.Generic;

    public interface IQubitManager
    {
        Qubit Allocate();
        IQArray<Qubit> Allocate(long count);

        void Release(Qubit qubit);
        void Release(IQArray<Qubit> qubits);

        void Disable(Qubit qubit);
        void Disable(IQArray<Qubit> qubits);

        Qubit Borrow();
        IQArray<Qubit> Borrow(long count);

        void Return(Qubit q);
        void Return(IQArray<Qubit> qubits);

        bool IsValid(Qubit qubit);
        bool IsFree(Qubit qubit);

        long GetFreeQubitsCount();
        long GetQubitsAvailableToBorrowCount();
        long GetParentQubitsAvailableToBorrowCount(); // Required for GetAvailableQubitsToBorrow
        long GetAllocatedQubitsCount();
        IEnumerable<long> GetAllocatedIds();

        bool DisableBorrowing { get; }

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
