// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QuantumProcessor;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public enum ToffoliDumpFormat
    {
        Bits,
        Hex,
        Automatic
    }

    /// <summary>
    /// The Toffoli simulator implementation class.
    /// </summary>
    public class ToffoliSimulator : QuantumProcessorDispatcher
    {
        public const uint DEFAULT_QUBIT_COUNT = 64;
        private ToffoliSimulatorProcessor processor;

        /// <summary>
        /// Constructs a Toffoli simulator instance with the specified qubit count.
        /// </summary>
        /// <param name="qubitCount">The number of qubits to allocate initially.
        /// The simulation values of 64 qubits are stored in a single 64-bit integer.
        /// The capacity is doubled whenever it is exceeded.</param>
        /// <param name="throwOnReleasingQubitsNotInZeroState">If true, an exception is thrown
        /// whenever an allocated qubit is not in the zero state when being released.</param>
        public ToffoliSimulator(uint qubitCount = DEFAULT_QUBIT_COUNT, bool throwOnReleasingQubitsNotInZeroState = true)
            : base(new ToffoliSimulatorProcessor(qubitCount, throwOnReleasingQubitsNotInZeroState),
                   new QubitManagerTrackingScope(qubitCapacity: qubitCount, mayExtendCapacity: true, disableBorrowing: false))
        {
            processor = (ToffoliSimulatorProcessor)QuantumProcessor;

            var message = Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
            processor.Message = text => { message.Apply(text); };
            processor.GetAllocatedIds = () => QubitManager!.GetAllocatedIds();
        }

        /// <summary>
        /// The name of an instance of this simulator.
        /// </summary>
        public override string Name { get => "Toffoli Simulator"; }

        /// <summary>
        /// The state of the simulator; always a simple product state in the computational (Z) basis.
        /// Note that "true" bits are in the Z=One state.
        /// </summary>
        public BitArray State { get => processor.SimulationValues; }
        public ToffoliDumpFormat DumpFormat
        {
            get => processor.DumpFormat;
            set => processor.DumpFormat = value;
        }
    }

}
