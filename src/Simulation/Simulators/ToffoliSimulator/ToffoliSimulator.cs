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

    public class ToffoliSimulator : QuantumProcessorDispatcher {
        public const uint DEFAULT_QUBIT_COUNT = 64;
        private ToffoliSimulatorProcessor processor;

        // Whether an exception is thrown when releasing qubits that are in a
        // non-zero state is configured as an argument to the constructor of
        // ReversibleSimulator, defaulted to `true`.
        public ToffoliSimulator(uint qubitCount = DEFAULT_QUBIT_COUNT, bool throwOnReleasingQubitsNotInZeroState = true)
            : base(new ToffoliSimulatorProcessor(qubitCount, throwOnReleasingQubitsNotInZeroState),
                   new QubitManagerTrackingScope(qubitCapacity: qubitCount, mayExtendCapacity: true, disableBorrowing: false)) {
            processor = (ToffoliSimulatorProcessor)QuantumProcessor;

            var message = Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
            processor.Message = text => { message.Apply(text); };
            processor.GetAllocatedIds = () => QubitManager!.GetAllocatedIds();
        }

        public override string Name { get => "Toffoli Simulator"; }
        public BitArray State { get => processor.SimulationValues; }
        public ToffoliDumpFormat DumpFormat {
            get => processor.DumpFormat;
            set => processor.DumpFormat = value;
        }
    }

}
