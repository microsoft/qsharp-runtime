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

        // If qubit only participated in single-qubit gates, its position is not fixed on the timeline of the program.
        // Scheduling of these qubits and gates can be decided later for depth optimization. For such qubits the EndTime
        // keeps the depth of the single-qubit gate chain.
        // If qubit already participated in multi-qubit gates, its position is fixed on the timeline of the program.
        // For such qubits EndTime keeps availability time: the end time of the last gate it prticipated in.
        // Qubit is available to take part in subsequent gates only after the EndTime.
        // This field is only maintained when optimizing for depth.
        internal ComplexTime EndTime { get; set; }


        // If qubit only participated in single-qubit gates StartTime is set to ComplexTime.MinValue.
        // If qubit already participated in multi-qubit gates its position is fixed on the timeline of the program.
        // For such qubits StartTime this is set to the start time of the first gate it participated in.
        // This field is only maintained when optimizing for depth.
        internal ComplexTime StartTime { get; set; }

        public QubitTimeMetrics(long qubitId)
        {
            QubitId = qubitId;
        }

        public override string ToString()
        {
            return $"{QubitId}: {StartTime} - {EndTime}";
        }
    }
}
