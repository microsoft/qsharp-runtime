// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Tracks time when qubits were last used and therefore, time when qubits become available.
    /// Tracking is done by qubit id, which survives during reuse of qubit.
    /// </summary>
    internal class QubitAvailabilityTimeTracker
    {
        /// <summary>
        /// Availability time of all qubits starts at 0.
        /// </summary>
        private double DefaultAvailabilityTime = 0.0;

        /// <summary>
        /// This tracks time when a qubit was last used, indexed by qubit id.
        /// </summary>
        private List<double> QubitAvailableAt;

        internal QubitAvailabilityTimeTracker(int initialCapacity, double defaultAvailabilityTime)
        {
            DefaultAvailabilityTime = defaultAvailabilityTime;
            QubitAvailableAt = new List<double>(initialCapacity);
        }

        internal double this[long qubitId]
        {
            get
            {
                if (qubitId < QubitAvailableAt.Count)
                {
                    return QubitAvailableAt[(int)qubitId];
                }
                return DefaultAvailabilityTime;
            }
            set
            {
                if (qubitId == QubitAvailableAt.Count)
                {
                    QubitAvailableAt.Add(value);
                    return;
                }
                else if (qubitId >= int.MaxValue)
                {
                    throw new IndexOutOfRangeException("Too many qubits to track.");
                }
                else if (qubitId > QubitAvailableAt.Count)
                {
                    QubitAvailableAt.AddRange(Enumerable.Repeat(DefaultAvailabilityTime, (int)qubitId - QubitAvailableAt.Count + 1));
                }
                QubitAvailableAt[(int)qubitId] = value;
            }
        }

    }

}
