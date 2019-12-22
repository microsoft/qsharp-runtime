// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{ 
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherBorrow : Intrinsic.Borrow
        {
            private readonly QuantumProcessorDispatcher sim;
            public QuantumProcessorDispatcherBorrow(QuantumProcessorDispatcher m) : base(m){
                sim = m;
            }

            public override Qubit Apply()
            {
                IQArray<Qubit> qubits = sim.QubitManager.Borrow(1);
                sim.QuantumProcessor.OnBorrowQubits(qubits);
                return qubits[0];
            }

            public override IQArray<Qubit> Apply(long count)
            {
                IQArray<Qubit> qubits = sim.QubitManager.Borrow(count);
                sim.QuantumProcessor.OnBorrowQubits(qubits);
                return qubits;
            }
        }
    }
}