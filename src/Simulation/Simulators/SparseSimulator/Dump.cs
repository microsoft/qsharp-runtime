// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

#nullable enable
namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.UInt32;

    public partial class SparseSimulator
    {
        /// <summary>
        ///     Returns the list of the qubits' ids currently allocated in the simulator.
        /// </summary>
        public override uint[] QubitIds
        {
            get
            {
                var ids = new List<QubitIdType>();
                
                QubitIds_cpp(this.Id, ids.Add);
                //Debug.Assert(this.QubitManager != null);
                //Debug.Assert(ids.Count == this.QubitManager.AllocatedQubitsCount);
                return ids.Select(id => (uint)id).ToArray();
            }
        }
    }
}
