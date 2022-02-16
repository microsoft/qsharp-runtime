// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Linq;

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
                return ids.Select(id => (uint)id).ToArray();
            }
        }
    }
}
