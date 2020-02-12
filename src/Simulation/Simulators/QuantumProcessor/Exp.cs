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

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Body => (_args) =>
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

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> AdjointBody => (_args) =>
            {
                (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits) = _args;
                
                return this.Body.Invoke((paulis, -angle, qubits));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledBody => (_args) =>
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

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledAdjointBody => (_args) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits)) = _args;

                return this.ControlledBody.Invoke((ctrls, (paulis, -angle, qubits)));
            };
        }
    }
}
