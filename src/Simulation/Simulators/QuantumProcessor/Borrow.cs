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
                long allocatedBefore = sim.QubitManager.GetAllocatedQubitsCount();
                Qubit qubit = sim.QubitManager.Borrow();
                long allocatedAfter = sim.QubitManager.GetAllocatedQubitsCount();
                sim.QuantumProcessor.OnBorrowQubits(new QArray<Qubit>(qubit), allocatedAfter - allocatedBefore);
                return qubit;
            }

            public override IQArray<Qubit> Apply(long count)
            {
                long allocatedBefore = sim.QubitManager.GetAllocatedQubitsCount();
                IQArray<Qubit> qubits = sim.QubitManager.Borrow(count);
                long allocatedAfter = sim.QubitManager.GetAllocatedQubitsCount();
                sim.QuantumProcessor.OnBorrowQubits(qubits, allocatedAfter - allocatedBefore);
                return qubits;
            }
        }
    }
}