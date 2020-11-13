// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherAssert : Microsoft.Quantum.Diagnostics.AssertMeasurement
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherAssert(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __Body__ => (_args) =>
            {
                (IQArray<Pauli> paulis, IQArray<Qubit> qubits, Result result, string msg) = _args;
                if (paulis.Length != qubits.Length)
                {
                    IgnorableAssert.Assert((paulis.Length != qubits.Length), "Arrays length mismatch");
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
                Simulator.QuantumProcessor.Assert(newPaulis, newQubits, result, msg);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __AdjointBody__ => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledBody__ => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledAdjointBody__ => (_args) => { return QVoid.Instance; };
        }
    }
}
