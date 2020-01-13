// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    /// <summary>
    /// Dispatcher (Simulator) that redirects all the calls to a class implementing <see cref="IQuantumProcessor"/> interface.
    /// </summary>
    public partial class QuantumProcessorDispatcher : SimulatorBase
    {
        private const int PreallocatedQubitCount = 256;
        /// <summary>
        /// Random number generator used for <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> 
        /// </summary>
        public readonly System.Random random;

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
        /// <param name="quantumProcessor">An instance of a class implementing <see cref="IQuantumProcessor"/> interface to be wrapped. If the parameter is null <see cref="QuantumProcessorBase"/> is used.</param>
        /// <param name="qubitManager">An instance of a class implementing <see cref="IQubitManager"/> interface. If the parameter is null <see cref="QubitManagerTrackingScope"/> is used.</param>
        /// <param name="randomSeed">A seed to be used by Q# <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> operation.</param>
        public QuantumProcessorDispatcher(IQuantumProcessor? quantumProcessor = null, IQubitManager? qubitManager = null, int? randomSeed = null)
            : base(qubitManager ?? new QubitManagerTrackingScope(PreallocatedQubitCount, mayExtendCapacity:true, disableBorrowing:false))
        {
            random = new System.Random(randomSeed == null ? DateTime.Now.Millisecond : randomSeed.Value);
            QuantumProcessor = quantumProcessor ?? new QuantumProcessorBase();
            OnOperationStart += QuantumProcessor.OnOperationStart;
            OnOperationEnd += QuantumProcessor.OnOperationEnd;
            OnFail += QuantumProcessor.OnFail;
            OnLog += QuantumProcessor.OnMessage;
        }

    }
}
