// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Used by <see cref="DepthCounter"/>
    /// </summary>
    public class QubitTimeMetrics
    {
        /// <summary>
        /// Time when the qubit becomes available
        /// </summary>
        public double AvailableAt { get; private set; } = 0;

        public QubitTimeMetrics()
        {
        }

        /// <param name="timeAt">Beginning of the execution of the primitive operation on the qubit</param>
        /// <param name="duration">Duration of the primitive operation</param>
        public void RecordQubitUsage(double timeAt, double duration)
        {
            if (timeAt < AvailableAt)
            {
                throw new QubitTimeMetricsException();
            }
            AvailableAt = timeAt + duration;
        }
    }
}