// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.Quantum.Simulation.Simulators.Exceptions
{
    public class NotDistinctQubits : Exception
    {
        public NotDistinctQubits(Qubit q)
            : base($"Trying to apply an intrinsic operation with a qubit repeated in the argument list (qubit:{q}).")
        {
        }
    }
}
