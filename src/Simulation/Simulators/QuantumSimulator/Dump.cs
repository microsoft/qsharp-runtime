// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        /// <summary>
        /// Dumps the wave function for the given qubits into the given target. 
        /// If the target is QVoid or an empty string, it dumps it to the console
        /// using the `Message` function, otherwise it dumps the content into a file
        /// with the given name.
        /// If the given qubits is null, it dumps the entire wave function, otherwise
        /// it attemps to create the wave function or the resulting subsystem; if it fails
        /// because the qubits are entangled with some external qubit, it just generates a message.
        /// </summary>
        protected virtual QVoid Dump<T>(T target, IQArray<Qubit>? qubits = null)
        {
            var filename = (target is QVoid) ? "" : target.ToString();

            QVoid process(Action<string> channel)
            {
                var ids = qubits?.Select(q => (uint)q.Id).ToArray() ?? QubitIds;

                var dumper = new SimpleDumper(this, channel);
                channel($"# wave function for qubits with ids (least to most significant): {string.Join(";", ids)}");

                if (!dumper.Dump(qubits))
                {
                    channel("## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##");
                }

                return QVoid.Instance;
            }

            var logMessage = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();

            // If no file provided, use `Message` to generate the message into the console;
            if (string.IsNullOrWhiteSpace(filename))
            {
                // var op = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
                // return process((msg) => op.Apply(msg));
                new JupyterDisplayDumper(this/*, channel*/)
                    //.Configure(configurationSource)
                    .Dump(qubits);
            }
            else
            {
                try
                {
                    using (var file = new StreamWriter(filename))
                    {
                        return process(file.WriteLine);
                    }
                }
                catch (Exception e)
                {
                    logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
            return QVoid.Instance;
        }

        public class QsimDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T> // Is inherited (and replaced at runtime)
        {                                                                    // by (iqsharp's) JupyterDumpMachine<T>.
            private QuantumSimulator Simulator { get; }
            ////
            // internal IConfigurationSource? ConfigurationSource = null;
            // internal IChannel? Channel = null;
            // internal ICommsRouter? Router = null;
            ////

            public QsimDumpMachine(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                // ////
                // if (!(location is QVoid) && location.ToString().Length != 0)
                // {
                //     Console.Out.WriteLine("Falling back to base DumpMachine.");
                //     return Simulator.Dump(location);
                // }
                // // Debug.Assert(
                // //     Channel != null,
                // //     "No display channel was provided when this operation was registered. " +
                // //     "This is an internal error, and should never occur."
                // // );
                // // Debug.Assert(
                // //     ConfigurationSource != null,
                // //     "No configuration source was provided when this operation was registered. " +
                // //     "This is an internal error, and should never occur."
                // // );
                // // Debug.Assert(
                // //     Channel.CommsRouter != null,
                // //     "No comms router was provided when this operation was registered. " +
                // //     "This is an internal error, and should never occur."
                // // );
                // // return JupyterDisplayDumper.DumpToChannel(Simulator, Channel, ConfigurationSource);


                // // Generate DisplayableState instance.

                // Simulator.MaybeDisplayDiagnostic(/*DisplayableState instance*/ /*Simulator.QubitIds*/);
                // return QVoid.Instance;                
                // ////

                return Simulator.Dump(location);
            };
        }

        public class QSimDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T> // Is inherited (and replaced at runtime)
        {                                                                      // by (iqsharp's) JupyterDumpRegister<T>.
            private QuantumSimulator Simulator { get; }

            public QSimDumpRegister(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                Simulator.CheckAndPreserveQubits(qubits);

                return Simulator.Dump(location, qubits);
                // var qIds = qubits.Select(q => (uint)q.Id).ToArray();
                // Simulator.MaybeDisplayDiagnostic(qIds);
                // return QVoid.Instance;                
            };
        }
    }
}
