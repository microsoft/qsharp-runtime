// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Used by <see cref="DepthCounter"/>
    /// </summary>
    public class QubitTimeMetrics
    {
        // TODO: Qubit Ids are already available in qubits, but DepthCounter doesn't have access to it
        // in OnPrimitiveOperation because it's not part of IQCTraceSimulatorListener interface.
        // Consider changing architecture to pass qubits rather than metrics in IQCTraceSimulatorListener.
        public long QubitId { get; }

        public QubitTimeMetrics(long qubitId)
        {
            QubitId = qubitId;
        }
    }
}
