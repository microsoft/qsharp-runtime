// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {

        public class QuantumProcessorApplyGate : Extensions.Gate
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyGate(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(long, IQArray<Qubit>, IQArray<Pauli>, IQArray<long>, IQArray<double>, IQArray<bool>, IQArray<Result>, IQArray<string>), QVoid> Body => (q) =>
            {
                (long gateId, IQArray<Qubit> qubits, IQArray<Pauli> paulis, IQArray<long> longs, IQArray<double> doubles, IQArray<bool> bools, IQArray<Result> results, IQArray<string> strings) = q;
                Simulator.QuantumProcessor.Gate(gateId, qubits, paulis, longs, doubles, bools, results, strings);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (long, IQArray<Qubit>, IQArray<Pauli>, IQArray<long>, IQArray<double>, IQArray<bool>, IQArray<Result>, IQArray<string>)), QVoid> ControlledBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (long gateId, IQArray<Qubit> qubits, IQArray<Pauli> paulis, IQArray<long> longs, IQArray<double> doubles, IQArray<bool> bools, IQArray<Result> results, IQArray<string> strings)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.QuantumProcessor.Gate(gateId, qubits, paulis, longs, doubles, bools, results, strings);
                }
                else
                {
                    Simulator.QuantumProcessor.ControlledGate(gateId, ctrls, qubits, paulis, longs, doubles, bools, results, strings);
                }
                return QVoid.Instance;
            };

        }

    }
}
