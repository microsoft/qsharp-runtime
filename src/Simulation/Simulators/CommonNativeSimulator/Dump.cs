// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
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
            var filename = ((target == null) || (target is QVoid)) ? "" : target.ToString();

            // If no file provided, output to the console;
            if (string.IsNullOrWhiteSpace(filename))
            {
                new DisplayableStateDumper(this).Dump(qubits);
            }
            else
            {
                try
                {
                    using var file = new StreamWriter(filename);
                    new DisplayableStateDumper(this, file.WriteLine).Dump(qubits);
                }
                catch (Exception e)
                {
                    var logMessage = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
                    logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
            return QVoid.Instance;
        }

        // `QsimDumpMachine` makes an impression that it is never used,
        // but since it inherits from Quantum.Diagnostics.DumpMachine (which is a C# class that corresponds to a
        // Q# operation in our core libraries), it will be automatically used.
        // It is instantiated via reflection, hence we don't see it easily in the code.
        public class QsimDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private CommonNativeSimulator Simulator { get; }

            public QsimDumpMachine(CommonNativeSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                return Simulator.Dump(location);
            };
        }

        // `QSimDumpRegister` makes an impression that it is never used,
        // but since it inherits from Quantum.Diagnostics.QSimDumpRegister (which is a C# class that corresponds to a
        // Q# operation in our core libraries), it will be automatically used.
        // It is instantiated via reflection, hence we don't see it easily in the code.
        public class QSimDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private CommonNativeSimulator Simulator { get; }

            public QSimDumpRegister(CommonNativeSimulator m) : base(m)
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

        /// <summary>
        /// This class allows you to dump the state (wave function)
        /// of the native simulator into a callback function.
        /// The callback function is triggered for every state basis
        /// vector in the wavefunction.
        /// </summary>
        public abstract class StateDumper
        {
            /// <summary>
            /// Basic constructor. Takes the simulator to probe.
            /// </summary>
            public StateDumper(CommonNativeSimulator qsim)
            {
                this.Simulator = qsim;
            }

            /// <summary>
            /// The callback method that will be used to report the amplitude 
            /// of each basis vector of the wave function.
            /// The method should return 'true' if the simulator should 
            /// continue reporting the state of the remaining basis vectors.
            /// </summary>
            /// <param name="idx">The index of the basis state vector being reported.</param>
            /// <param name="real">The real portion of the amplitude of the given basis state vector.</param>
            /// <param name="img">The imaginary portion of the amplitude of the given basis state vector.</param>
            /// <returns>true if dumping should continue, false to stop dumping.</returns>
            public abstract bool Callback(uint idx, double real, double img);

            /// <summary>
            /// The Simulator being reported.
            /// </summary>
            public CommonNativeSimulator Simulator { get; }

            /// <summary>
            /// Entry method to get the dump of the wave function.
            /// </summary>
            public virtual bool Dump(IQArray<Qubit>? qubits = null)
            {
                if (qubits == null)
                {
                    this.Simulator.sim_Dump(Callback);
                    return true;
                }
                else
                {
                    var ids = qubits.GetIds();
                    return this.Simulator.sim_DumpQubits((uint)ids.Length, ids, Callback);
                }
            }
        }

        /// <summary>
        ///     A state dumper that encodes dumped states into displayable
        ///     objects.
        /// </summary>
        public class DisplayableStateDumper : StateDumper
        {
            private long _count = -1;
            private Complex[]? _data = null;

            /// <summary>
            /// A method to call to output a string representation.
            /// </summary>
            public virtual Action<string>? FileWriter { get; }

            /// <summary>
            ///     Constructs a new display dumper for a given simulator.
            /// </summary>
            public DisplayableStateDumper(CommonNativeSimulator sim, Action<string>? fileWriter = null) : base(sim)
            {
                this.FileWriter = fileWriter;
            }

            /// <summary>
            ///     Used by the simulator to provide states when dumping.
            ///     Not intended to be called directly.
            /// </summary>
            public override bool Callback(uint idx, double real, double img)
            {
                if (_data == null) throw new Exception("Expected data buffer to be initialized before callback, but it was null.");
                _data[idx] = new Complex(real, img);
                return true;
            }

            /// <summary>
            ///     Dumps the state of a register of qubits as a displayable object.
            /// </summary>
            public override bool Dump(IQArray<Qubit>? qubits = null)
            {
                System.Diagnostics.Debug.Assert(this.Simulator.QubitManager != null, 
                    "Internal logic error, QubitManager must be assigned");

                _count = qubits == null
                            ? this.Simulator.QubitManager.AllocatedQubitsCount
                            : qubits.Length;
                _data = new Complex[1 << ((int)_count)];    // If 0 qubits are allocated then the array has 
                                                            // a single element. The Hilbert space of the system is 
                                                            // ℂ¹ (that is, complex-valued scalars).
                var result = base.Dump(qubits);

                // At this point, _data should be filled with the full state
                // vector, so let's display it, counting on the right display
                // encoder to be there to pack it into a table.

                var state = new DisplayableState
                {
                    // We cast here as we don't support a large enough number
                    // of qubits to saturate an int.
                    QubitIds = qubits?.Select(q => q.Id) ?? Simulator.GetQubitIds().Select(q => (int)q) ?? Enumerable.Empty<int>(),
                    NQubits = (int)_count,
                    Amplitudes = _data,
                };

                if (this.FileWriter != null)
                {
                    this.FileWriter(state.ToString());
                }
                else
                {
                    Simulator.MaybeDisplayDiagnostic(state);
                }

                // Clean up the state vector buffer.
                _data = null;

                return result;
            }

        }
    }
}
