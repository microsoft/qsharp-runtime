// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        /// <summary>
        ///     Returns the list of the qubits' ids currently allocated in the simulator.
        /// </summary>
        public uint[] QubitIds
        {
            get
            {
                var ids = new List<uint>();
                sim_QubitsIdsNative(this.Id, ids.Add);
                Debug.Assert(this.QubitManager != null);
                Debug.Assert(ids.Count == this.QubitManager.AllocatedQubitsCount);
                return ids.ToArray();
            }
        }

        public override uint[] GetQubitIds()
        {
            return QubitIds;
        }

        // protected override QVoid process(Action<string> channel, IQArray<Qubit>? qubits)
        // {
        //     var ids = qubits?.Select(q => (uint)q.Id).ToArray() ?? QubitIds;

        //     var dumper = new SimpleDumper(this, channel);
        //     channel($"# wave function for qubits with ids (least to most significant): {string.Join(";", ids)}");

        //     if (!dumper.Dump(qubits))
        //     {
        //         channel("## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##");
        //     }

        //     return QVoid.Instance;
        // }
    }
}
