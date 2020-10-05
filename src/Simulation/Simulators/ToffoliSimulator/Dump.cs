// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class ToffoliSimulator
    {
        /// <summary>
        /// Implementation of the DumpMachine operation for the Toffoli simulator.
        /// </summary>
        public class DumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private ToffoliSimulator simulator { get; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public DumpMachine(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                var ids = this.simulator.QubitManager.GetAllocatedIds().ToArray();
                var filename = (location is QVoid) ? "" : location.ToString();
                this.simulator.DumpState(ids, filename);

                return QVoid.Instance;
            };
        }

        /// <summary>
        /// Implementation of the DumpRegister operation for the Toffoli simulator.
        /// </summary>
        public class DumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private ToffoliSimulator simulator { get; }

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public DumpRegister(ToffoliSimulator m) : base(m)
            {
                this.simulator = m;
            }

            /// <summary>
            /// The implementation of the operation.
            /// </summary>
            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                var ids = qubits.GetIds().OrderBy(id => id).Select(id => (long)id).ToArray();
                var filename = (location is QVoid) ? "" : location.ToString();
                this.simulator.DumpState(ids, filename);

                return QVoid.Instance;
            };
        }
    }
}
