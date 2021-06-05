// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.Simulators.Exceptions
{
    [Obsolete("This class is deprecated and will be removed in a future release.")]
    public class ReleasedQubitsAreNotInZeroState : Exception
    {
        public ReleasedQubitsAreNotInZeroState()
            : base("Released qubits are not in zero state.")
        {
        }
    }
}
