// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using Microsoft.Quantum.Simulation.Core;
    using System.Diagnostics;

    /// <summary>
    /// TraceableQubit holds data associated with a qubit 
    /// for runtime checks, metrics collection and measurement constraints tracking.
    /// Used by <see cref="TraceableQubitManager"/>
    /// </summary>
    public class TraceableQubit : Qubit
    {
        /// <summary>
        /// Objects attached to the qubit
        /// </summary>
        public readonly object[] TraceData;

        /// <param name="traceDataSize">Number of objects that can be attached to each qubit</param>
        public TraceableQubit(int id, int traceDataSize = 0 ) : base(id)
        {
            TraceData = new object[traceDataSize];
        }
    }


}