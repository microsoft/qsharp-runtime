using System;
using System.IO;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        /// <summary>
        /// Dumps the wave function for the given qubits into the given target. 
        /// If the target is QVoid or an empty string, it dumps it to the console
        /// using the `Message` function, otherwise it dumps the content into a file
        /// with the given name.
        /// DumpMachine dumps the entire wave function,
        /// DumpRegister attempts to create the wave function or the resulting subsystem; if it fails
        /// because the qubits are entangled with some external qubit, it just generates a message.
        /// </summary>
        protected virtual QVoid DumpMachine<T>(T target)
        {
            QuantumExecutor.OnDumpMachine<T>(target);
            return QVoid.Instance;
        }

        protected virtual QVoid DumpRegister<T>(T target, IQArray<Qubit> qubits)
        {
            QuantumExecutor.OnDumpRegister<T>(target, qubits);
            return QVoid.Instance;
        }

        public class QuantumExecutorSimDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private QuantumExecutorSimulator Simulator { get; }

            public QuantumExecutorSimDumpMachine(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> Body => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                return Simulator.DumpMachine(location);
            };
        }

        public class QuantumExecutorSimDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private QuantumExecutorSimulator Simulator { get; }


            public QuantumExecutorSimDumpRegister(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> Body => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                return Simulator.DumpRegister(location, qubits);
            };
        }
    }
}
