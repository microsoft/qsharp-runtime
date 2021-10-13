﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class NativeCommonSimulator
    {
        protected virtual QVoid process(Action<string> channel, IQArray<Qubit>? qubits)
        {
            return QVoid.Instance;
        }

        /// <summary>
        /// Dumps the wave function for the given qubits into the given target. 
        /// If the target is QVoid or an empty string, it dumps it to the console
        /// using the `Message` function, otherwise it dumps the content into a file
        /// with the given name.
        /// If the given qubits is null, it dumps the entire wave function, otherwise
        /// it attempts to create the wave function or the resulting subsystem; if it fails
        /// because the qubits are entangled with some external qubit, it just generates a message.
        /// </summary>
        protected virtual QVoid Dump<T>(T target, IQArray<Qubit>? qubits = null)
        {
            var filename = (target is QVoid) ? "" : target.ToString();
            var logMessage = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();

            // If no file provided, use `Message` to generate the message into the console;
            if (string.IsNullOrWhiteSpace(filename))
            {
                var op = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
                return process((msg) => op.Apply(msg), qubits);
            }
            else
            {
                try
                {
                    using (var file = new StreamWriter(filename))
                    {
                        return process(file.WriteLine, qubits);
                    }
                }
                catch (Exception e)
                {
                    logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                    return QVoid.Instance;
                }
            }
        }

        // TODO(rokuzmin): QsimDumpMachine is never used?
        public class QsimDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private NativeCommonSimulator Simulator { get; }

            public QsimDumpMachine(NativeCommonSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                return Simulator.Dump(location);
            };
        }

        // TODO(rokuzmin): QSimDumpRegister is never used?
        public class QSimDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private NativeCommonSimulator Simulator { get; }

            public QSimDumpRegister(NativeCommonSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                Simulator.CheckAndPreserveQubits(qubits);

                return Simulator.Dump(location, qubits);
            };
        }
    }
}
