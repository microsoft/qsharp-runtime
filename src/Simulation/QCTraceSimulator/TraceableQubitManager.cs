// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Common;

    /// <summary>
    /// Qubit manager for TraceableQubit type. Ensures that all the traceable 
    /// qubits are configured as requested during qubit manage construction.
    /// </summary>
    class TraceableQubitManager : QubitManagerTrackingScope
    {
        const long NumQubits = 1024;

        private Func<long, object>[] qubitTraceDataInitializers; // call-backs to initialize tracer data for each of the tracing components
        private readonly int traceDataSize;

        /// <summary>
        /// The qubit manager makes sure that trace data array for qubits 
        /// is initialized with objects created by qubitTraceDataInitializers callbacks
        /// </summary>
        public TraceableQubitManager( Func<long,object>[] qubitTraceDataInitializers ) 
            : base(NumQubits, mayExtendCapacity : true, disableBorrowing : false)
        {
            this.qubitTraceDataInitializers = qubitTraceDataInitializers.Clone() as
                Func<long, object>[];
            traceDataSize = this.qubitTraceDataInitializers.Length;
        }

        public override Qubit CreateQubitObject(long id)
        {
            TraceableQubit q = new TraceableQubit((int)id, traceDataSize);
            for (int j = 0; j < traceDataSize; ++j)
            {
                q.TraceData[j] = qubitTraceDataInitializers[j](id);
            }
            return q;
        }
    }
}