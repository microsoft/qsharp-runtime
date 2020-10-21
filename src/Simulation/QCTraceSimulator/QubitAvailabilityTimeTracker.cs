// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    internal class QubitAvailabilityTimeTracker
    {
        private double DefaultAvailabilityTime = 0;
        private List<double> QubitAvailableAt;
        private long MaxQubitId = -1;

        internal QubitAvailabilityTimeTracker(int initialCapacity, double defaultAvailabilityTime)
        {
            DefaultAvailabilityTime = defaultAvailabilityTime;
            QubitAvailableAt = new List<double>(initialCapacity);
        }

        internal double this[long index]
        {
            get
            {
                if (index < QubitAvailableAt.Count)
                {
                    return QubitAvailableAt[(int)index];
                }
                return DefaultAvailabilityTime;
            }
            set
            {
                if (index == QubitAvailableAt.Count)
                {
                    QubitAvailableAt.Add(value);
                    return;
                }
                else if (index >= int.MaxValue)
                {
                    throw new IndexOutOfRangeException("Too many qubits to track.");
                }
                else if (index > QubitAvailableAt.Count)
                {
                    QubitAvailableAt.AddRange(Enumerable.Repeat(DefaultAvailabilityTime, (int)index - QubitAvailableAt.Count + 1));
                }
                QubitAvailableAt[(int)index] = value;
            }
        }

        internal long GetMaxQubitId()
        {
            return MaxQubitId;
        }

        internal void MarkQubitIdUsed(long qubitId)
        {
            MaxQubitId = System.Math.Max(MaxQubitId, qubitId);
        }

    }

}
