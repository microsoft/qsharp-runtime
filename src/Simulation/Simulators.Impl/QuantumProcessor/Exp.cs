// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherExp : Quantum.Intrinsic.Exp
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherExp(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> __Body__ => (_args) =>
            {
                (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException(
                        $"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);

                Simulator.QuantumProcessor.Exp(newPaulis, angle, newQubits);

                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> __AdjointBody__ => (_args) =>
            {
                (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits) = _args;
                
                return this.__Body__.Invoke((paulis, -angle, qubits));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> __ControlledBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits)) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException(
                        $"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }
                
                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
                
                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.Exp(newPaulis, angle, newQubits);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledExp(ctrls, newPaulis, angle, newQubits);
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> __ControlledAdjointBody__ => (_args) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits)) = _args;

                return this.__ControlledBody__.Invoke((ctrls, (paulis, -angle, qubits)));
            };
        }
    }
}
