// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_Body() => (_args) =>
        {
            (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits) = _args;

            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException(
                    $"Both input arrays for Exp (paulis,qubits), must be of same size.");
            }

            CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);

            this.QuantumProcessor.Exp(newPaulis, angle, newQubits);

            return QVoid.Instance;
        };

        public Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Exp_AdjointBody() => (_args) =>
        {
            (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits) = _args;
            
            return Exp_Body().Invoke((paulis, -angle, qubits));
        };

        public Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits)) = _args;

            if (paulis.Length != qubits.Length)
            {
                throw new InvalidOperationException(
                    $"Both input arrays for Exp (paulis,qubits), must be of same size.");
            }
            
            CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
            
            if ((ctrls == null) || (ctrls.Count == 0))
            {
                this.QuantumProcessor.Exp(newPaulis, angle, newQubits);
            }
            else
            {
                this.QuantumProcessor.ControlledExp(ctrls, newPaulis, angle, newQubits);
            }

            return QVoid.Instance;
        };

        public Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> Exp_ControlledAdjointBody() => (_args) =>
        {
            (IQArray<Qubit> ctrls, (IQArray<Pauli> paulis, double angle, IQArray<Qubit> qubits)) = _args;

            return Exp_ControlledBody().Invoke((ctrls, (paulis, -angle, qubits)));
        };
    }
}
