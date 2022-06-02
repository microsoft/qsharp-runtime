using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using Microsoft.Quantum.Simulation.Core;

    /// <summary>
    /// TraceableQubitFactory provide common functionality for traceable qubit managers
    /// to produce qubits with appropriate tracing data.
    /// </summary>
    public class TraceableQubitFactory
    {
        private Func<long, object>[] qubitTraceDataInitializers; // call-backs to initialize tracer data for each of the tracing components
        private readonly int traceDataSize;

        /// <summary>
        /// TraceableQubitFactory makes sure that trace data array for qubits 
        /// is initialized with objects created by qubitTraceDataInitializers callbacks
        /// </summary>
        public TraceableQubitFactory(Func<long, object>[] qubitTraceDataInitializers)
        {
            this.qubitTraceDataInitializers = qubitTraceDataInitializers.Clone() as
                Func<long, object>[];
            traceDataSize = this.qubitTraceDataInitializers.Length;
        }

        /// <summary>
        /// Creates qubit object with appropriate tracing data.
        /// </summary>
        public TraceableQubit CreateQubitObject(long id)
        {
            TraceableQubit q = new TraceableQubit((int)id, traceDataSize);
            for (int j = 0; j < traceDataSize; ++j) {
                q.TraceData[j] = qubitTraceDataInitializers[j](id);
            }
            return q;
        }

    }
}
