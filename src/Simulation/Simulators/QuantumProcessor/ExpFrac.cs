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

                //We are intentionally not pruning identities here as we expect the implementation to do so
                Simulator.QuantumProcessor.ExpFrac(paulis, nom, den, qubits);
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
 
                    if ((ctrls == null) || (ctrls.Count == 0))
                    {
                        Simulator.QuantumProcessor.ExpFrac(paulis, nom, den, qubits);
                    }
                    else
                    {
                        Simulator.QuantumProcessor.ControlledExpFrac(ctrls, paulis, nom, den, qubits);
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
