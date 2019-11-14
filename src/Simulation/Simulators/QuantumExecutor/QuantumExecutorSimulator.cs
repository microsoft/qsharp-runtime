// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    /// <summary>
    /// Simulator that redirects all the calls to a class implementing <see cref="IQuantumExecutor"/> interface.
    /// </summary>
    public partial class QuantumExecutorSimulator : SimulatorBase
    {
        private const int PreallocatedQubitCount = 1000;
        /// <summary>
        /// Random number generator used for <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> 
        /// </summary>
        public readonly System.Random random;

        public override string Name => "QuantumExecutorSimulator";

        /// <summary>
        /// An instance of a class implementing <see cref="IQuantumExecutor"/> interface that this simulator wraps.
        /// </summary>
        public IQuantumExecutor QuantumExecutor
        {
            get;
            private set;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="quantumExecutor">An instance of a class implementing <see cref="IQuantumExecutor"/> interface to be wrapped. If the parameter is null <see cref="EmptyQuantumExecutor"/> is used.</param>
        /// <param name="qubitManager">An instance of a class implementing <see cref="IQubitManager"/> interface. If the parameter is null <see cref="QubitManagerTrackingScope"/> is used.</param>
        /// <param name="randomSeed">A seed to be used by Q# <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.random">Microsoft.Quantum.Intrinsic.Random</a> operation.</param>
        public QuantumExecutorSimulator(IQuantumExecutor quantumExecutor = null, IQubitManager qubitManager = null, int? randomSeed = null)
            : base(qubitManager ?? new QubitManagerTrackingScope(PreallocatedQubitCount, mayExtendCapacity:true, disableBorrowing:false))
        {
            random = new System.Random(randomSeed == null ? DateTime.Now.Millisecond : randomSeed.Value);
            QuantumExecutor = quantumExecutor ?? new EmptyQuantumExecutor();
            OnOperationStart += QuantumExecutor.OnOperationStart;
            OnOperationEnd += QuantumExecutor.OnOperationEnd;
            OnFail += QuantumExecutor.OnFail;
            OnLog += QuantumExecutor.OnMessage;
        }

    }
}
