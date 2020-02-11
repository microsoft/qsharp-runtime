// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherExpFrac : Quantum.Intrinsic.ExpFrac
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherExpFrac(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> Body => (_args) =>
            {
                (IQArray<Pauli> paulis, long nom, long den, IQArray<Qubit> qubits) = _args;

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException(
                        $"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);

                Simulator.QuantumProcessor.ExpFrac(newPaulis, nom, den, newQubits);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, long, long, IQArray<Qubit>), QVoid> AdjointBody => (_args) =>
            {
                (IQArray<Pauli> paulis, long nom, long den, IQArray<Qubit> qubits) = _args;
                
                return this.Body.Invoke((paulis, -nom, den, qubits));
            };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid>
                ControlledBody => (_args) =>
                {
                    (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, long nom, long den, IQArray<Qubit> qubits)) = _args;

                    if (paulis.Length != qubits.Length)
                    {
                        throw new InvalidOperationException(
                            $"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                    }

                    CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
                    
                    if ((ctrls == null) || (ctrls.Count == 0))
                    {
                        Simulator.QuantumProcessor.ExpFrac(newPaulis, nom, den, newQubits);
                    }
                    else
                    {
                        Simulator.QuantumProcessor.ControlledExpFrac(ctrls, newPaulis, nom, den, newQubits);
                    }

                    return QVoid.Instance;
                };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)), QVoid>
                ControlledAdjointBody => (_args) =>
                {
                    (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, long nom, long den, IQArray<Qubit> qubits)) = _args;

                    return this.ControlledBody.Invoke((ctrls, (paulis, -nom, den, qubits)));
                };
        }
    }
}
