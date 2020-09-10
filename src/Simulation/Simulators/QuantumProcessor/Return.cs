// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    using Microsoft.Quantum.Simulation.Core;

    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherReturn : Intrinsic.Return
        {
            private readonly QuantumProcessorDispatcher sim;
            public QuantumProcessorDispatcherReturn(QuantumProcessorDispatcher m) : base(m){
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                long allocatedBefore = sim.QubitManager.AllocatedQubitsCount;
                sim.QubitManager.Return(q);
                long allocatedAfter = sim.QubitManager.AllocatedQubitsCount;
                sim.QuantumProcessor.OnReturnQubits(new QArray<Qubit>(q), allocatedBefore - allocatedAfter);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                long allocatedBefore = sim.QubitManager.AllocatedQubitsCount;
                sim.QubitManager.Return(qubits);
                long allocatedAfter = sim.QubitManager.AllocatedQubitsCount;
                sim.QuantumProcessor.OnReturnQubits(qubits, allocatedBefore - allocatedAfter);
            }
        }
    }
}