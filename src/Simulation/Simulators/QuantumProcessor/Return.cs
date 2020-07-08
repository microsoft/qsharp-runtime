// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    using Microsoft.Quantum.Simulation.Core;

    public partial class QuantumProcessorDispatcher<TProcessor>
    {
        public class QuantumProcessorDispatcherReturn : Intrinsic.Return
        {
            private readonly QuantumProcessorDispatcher sim;
            public QuantumProcessorDispatcherReturn(QuantumProcessorDispatcher m) : base(m){
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                long count = (sim.QubitManager.ToBeReleasedAfterReturn(q) ? 1 : 0);
                sim.QuantumProcessor.OnReturnQubits(new QArray<Qubit>(q), count);
                sim.QubitManager.Return(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                long count = sim.QubitManager.ToBeReleasedAfterReturnCount(qubits);
                sim.QuantumProcessor.OnReturnQubits(qubits, count);
                sim.QubitManager.Return(qubits);
            }
        }
    }
}