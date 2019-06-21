// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.Simulators.Exceptions
{
    public class NotEnoughQubits : Exception
    {
        public NotEnoughQubits(long requested, long available) 
            : base($"Not enough Qubits. Requested {requested} but only {available} are available.")
        {
            this.Requested = requested;
            this.Available = available;
        }

        public long Requested { get; private set; }
        public long Available { get; private set; }
    }
}
