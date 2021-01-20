// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    /// <summary>
    /// Dispatcher (Simulator) that redirects all the calls to a class implementing <see cref="IQuantumProcessor"/> interface.
    /// </summary>
    public partial class QuantumProcessorDispatcher : SimulatorBase
    {
        private const int PreallocatedQubitCount = 256;

        public override string Name => "QuantumProcessorDispatcher";

        /// <summary>
        /// An instance of a class implementing <see cref="IQuantumProcessor"/> interface that this simulator wraps.
        /// </summary>
        public IQuantumProcessor QuantumProcessor
        {
            get;
            private set;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="quantumProcessor">An instance of a class implementing <see cref="IQuantumProcessor"/> interface to be wrapped.</param>
        /// <param name="qubitManager">An instance of a class implementing <see cref="IQubitManager"/> interface. If the parameter is null <see cref="QubitManager"/> is used.</param>
        /// <param name="randomSeed">A seed to be used by Q# <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> operation.</param>
        /// <param name="onlyOverrideBodyIntrinsic">A boolean that indicates whether only Q# callables that are defined as body intrinsic should be overridden. If false, the C# implementation will always override any Q# implementation. If true, the C# will only override Q# that does not have an implementation and is marked as body intrinsic. The value is false by default.</param>
        public QuantumProcessorDispatcher(IQuantumProcessor quantumProcessor, IQubitManager? qubitManager = null, int? randomSeed = null, bool onlyOverrideBodyIntrinsic = false)
        : base(
            qubitManager ?? new QubitManager(
                PreallocatedQubitCount,
                mayExtendCapacity: true, disableBorrowing: false
            ),
            randomSeed
        )
        {
            QuantumProcessor = quantumProcessor;
            OnOperationStart += QuantumProcessor.OnOperationStart;
            OnOperationEnd += QuantumProcessor.OnOperationEnd;
            OnFail += QuantumProcessor.OnFail;
            OnLog += QuantumProcessor.OnMessage;
        }

    }
}
