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
                sim.QuantumProcessor.OnReturnQubits(new QArray<Qubit>(q));
                sim.QubitManager.Return(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.QuantumProcessor.OnReturnQubits(qubits);
                sim.QubitManager.Return(qubits);
            }
        }
    }
}