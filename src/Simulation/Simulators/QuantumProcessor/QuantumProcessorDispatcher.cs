// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    
    /// <summary>
    /// Dispatcher (Simulator) that redirects all the calls to a class implementing <see cref="IQuantumProcessor"/> interface.
    /// </summary>
    public partial class QuantumProcessorDispatcher<TProcessor> : SimulatorBase
    where TProcessor: class, IQuantumProcessor
    {
        private const int PreallocatedQubitCount = 256;
        /// <summary>
        /// Random number generator used for <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> 
        /// </summary>
        public readonly System.Random random;

        public override string Name => "QuantumProcessorDispatcher";

        /// <summary>
        /// An instance of a class implementing the <see cref="IQuantumProcessor"/> interface that this simulator wraps.
        /// </summary>
        public TProcessor QuantumProcessor
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
        public QuantumProcessorDispatcher(TProcessor quantumProcessor, IQubitManager? qubitManager = null, int? randomSeed = null)
            : base(qubitManager ?? new QubitManagerTrackingScope(PreallocatedQubitCount, mayExtendCapacity:true, disableBorrowing:false))
        {
            random = new System.Random(randomSeed == null ? DateTime.Now.Millisecond : randomSeed.Value);
            QuantumProcessor = quantumProcessor;
            OnOperationStart += QuantumProcessor.OnOperationStart;
            OnOperationEnd += QuantumProcessor.OnOperationEnd;
            OnFail += QuantumProcessor.OnFail;
            OnLog += QuantumProcessor.OnMessage;

            // If our quantum processor supports it, forward any diagnostic data that
            // it produces to SimulatorBase.
            if (quantumProcessor is IDiagnosticDataSource dataSource)
            {
                dataSource.OnDisplayableDiagnostic += MaybeDisplayDiagnostic;
            }
        }

    }

    
    /// <summary>
    /// Dispatcher (Simulator) that redirects all the calls to a class implementing <see cref="IQuantumProcessor"/> interface.
    /// </summary>
    public class QuantumProcessorDispatcher : QuantumProcessorDispatcher<IQuantumProcessor>
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="quantumProcessor">An instance of a class implementing <see cref="IQuantumProcessor"/> interface to be wrapped. If the parameter is null <see cref="QuantumProcessorBase"/> is used.</param>
        /// <param name="qubitManager">An instance of a class implementing <see cref="IQubitManager"/> interface. If the parameter is null <see cref="QubitManagerTrackingScope"/> is used.</param>
        /// <param name="randomSeed">A seed to be used by Q# <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> operation.</param>
        public QuantumProcessorDispatcher(IQuantumProcessor? quantumProcessor = null, IQubitManager? qubitManager = null, int? randomSeed = null)
        : base(
            quantumProcessor: quantumProcessor ?? new QuantumProcessorBase(),
            qubitManager: qubitManager,
            randomSeed: randomSeed
        )
        { }

    }

}
