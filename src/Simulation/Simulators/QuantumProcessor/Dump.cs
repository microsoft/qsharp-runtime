// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorDispatcherDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorDispatcherDumpMachine(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                this.Simulator.QuantumProcessor.OnDumpMachine<T>(location);
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorDispatcherDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private QuantumProcessorDispatcher Simulator { get; }


            public QuantumProcessorDispatcherDumpRegister(QuantumProcessorDispatcher m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                this.Simulator.QuantumProcessor.OnDumpRegister<T>(location, qubits);
                return QVoid.Instance;
            };
        }
    }
}
