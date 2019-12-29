// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherAllocate : Intrinsic.Allocate
        {
            private readonly QuantumProcessorDispatcher sim;
            public QuantumProcessorDispatcherAllocate(QuantumProcessorDispatcher m) : base(m){
                sim = m;
            }

            public override Qubit Apply()
            {
                IQArray<Qubit> qubits = sim.QubitManager.Allocate(1);
                sim.QuantumProcessor.OnAllocateQubits(qubits);
                return qubits[0];
            }

            public override IQArray<Qubit> Apply(long count)
            {
                IQArray<Qubit> qubits = sim.QubitManager.Allocate(count);
                sim.QuantumProcessor.OnAllocateQubits(qubits);
                return qubits;
            }
        }
    }
}