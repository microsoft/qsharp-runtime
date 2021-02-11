// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherRelease : Intrinsic.Release
        {
            private readonly QuantumProcessorDispatcher sim;
            public QuantumProcessorDispatcherRelease(QuantumProcessorDispatcher m) : base(m){
                sim = m;
            }

            public override void Apply(Qubit q)
            {
                sim.QuantumProcessor.OnReleaseQubits(new QArray<Qubit>(q));
                sim.QubitManager.Release(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                sim.QuantumProcessor.OnReleaseQubits(qubits);
                sim.QubitManager.Release(qubits);
            }
        }
    }
}