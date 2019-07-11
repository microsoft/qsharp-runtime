// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{

    using System;
    using System.Diagnostics;

    class QubitsMetricsUtils
    {
        public static double MaxQubitAvailableTime(QubitTimeMetrics[] qubitMetrics)
        {
            Debug.Assert(qubitMetrics != null);
            if (qubitMetrics.Length == 0)
            {
                return 0; // if there are no qubits to depend on, we start at the beginning e.g. 0
            }

            double maxStartTime = 0;
            for (int i = 0; i < qubitMetrics.Length; ++i)
            {
                maxStartTime = Math.Max(maxStartTime, qubitMetrics[i].AvailableAt);
            }
            return maxStartTime;
        }

        public static double MinQubitAvailableTime(QubitTimeMetrics[] qubitMetrics)
        {
            Debug.Assert(qubitMetrics != null);
            if (qubitMetrics.Length == 0)
            {
                return 0; // if there are no qubits to depend on, we start at the beginning e.g. 0
            }

            double minStartTime = double.MaxValue;
            for (int i = 0; i < qubitMetrics.Length; ++i)
            {
                minStartTime = Math.Min(minStartTime, qubitMetrics[i].AvailableAt);
            }
            return minStartTime;
        }
    }
}