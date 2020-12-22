// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Used by <see cref="DepthCounter"/>
    /// </summary>
    public class QubitTimeMetrics
    {
        // Qubit Ids are already available in qubits, but DepthCounter doesn't have access to them
        // in OnPrimitiveOperation because they are not part of IQCTraceSimulatorListener interface.
        // Consider changing architecture to pass qubits rather than metrics in IQCTraceSimulatorListener.
        public long QubitId { get; }

        // If qubit is not fixed in time, this is depth of single-qubit-gate chain on this qubit
        // If qubit is fixed in time, this is the busy interval end time for this qubit
        internal ComplexTime EndTime { get; set; }


        // If qubit is not fixed in time, this is ComplexTime.MinValue
        // If qubit is fixed in time, this is the busy interval start time
        internal ComplexTime StartTime { get; set; }

        public QubitTimeMetrics(long qubitId)
        {
            QubitId = qubitId;
        }

        public override string ToString() {
            return $"{QubitId}: {StartTime} - {EndTime}";
        }
    }
}
