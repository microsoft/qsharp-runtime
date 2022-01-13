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
        ///     The convention to be used in labeling computational basis states
        ///     given their representations as strings of classical bits.
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public enum BasisStateLabelingConvention
        {
            /// <summary>
            ///     Label computational states directly by their bit strings.
            /// </summary>
            /// <example>
            ///     Following this convention, the state |0⟩ ⊗ |1⟩ ⊗ |1⟩ is labeled
            ///     by |011⟩.
            /// </example>
            Bitstring,

            /// <summary>
            ///     Label computational states directly by interpreting their bit
            ///     strings as little-endian encoded integers.
            /// </summary>
            /// <example>
            ///     Following this convention, the state |0⟩ ⊗ |1⟩ ⊗ |1⟩ is labeled
            ///     by |6⟩.
            /// </example>
            LittleEndian,

            /// <summary>
            ///     Label computational states directly by interpreting their bit
            ///     strings as big-endian encoded integers.
            /// </summary>
            /// <example>
            ///     Following this convention, the state |0⟩ ⊗ |1⟩ ⊗ |1⟩ is labeled
            ///     by |3⟩.
            /// </example>
            BigEndian
        }
        
        /// <summary>
        ///     Represents a quantum state vector and all metadata needed to display
        ///     that state vector.
        /// </summary>
        public class DisplayableState
        {
            private static readonly IComparer<string> ToIntComparer =
                Comparer<string>.Create((label1, label2) =>
                    Comparer<int>.Default.Compare(
                        Int32.Parse(label1), Int32.Parse(label2)
                    )
                );

            /// <summary>
            ///     Metadata to be used when serializing to JSON, allowing code
            ///     in other languages to determine what representation is used
            ///     for this state.
            /// </summary>
            [JsonProperty("diagnostic_kind")]
            private string DiagnosticKind => "state-vector";

            /// <summary>
            ///     The indexes of each qubit on which this state is defined, or
            ///     <c>null</c> if these indexes are not known.
            /// </summary>
            [JsonProperty("qubit_ids")]
            public IEnumerable<int>? QubitIds { get; set; }

            /// <summary>
            ///     The number of qubits on which this state is defined.
            /// </summary>
            [JsonProperty("n_qubits")]
            public int NQubits { get; set; }

            /// <remarks>
            ///     These amplitudes represent the computational basis states
            ///     labeled in little-endian order, as per the behavior of
            ///     <see cref="Microsoft.Quantum.Simulation.Simulators.CommonNativeSimulator.StateDumper.Dump" />.
            /// </remarks>
            [JsonProperty("amplitudes")]
            public Complex[]? Amplitudes { get; set; }

            /// <summary>
            ///     An enumerable source of the significant amplitudes of this state
            ///     vector and their labels.
            /// </summary>
            /// <param name="convention">
            ///     The convention to be used in labeling each computational basis state.
            /// </param>
            /// <param name="truncateSmallAmplitudes">
            ///     Whether to truncate small amplitudes.
            /// </param>
            /// <param name="truncationThreshold">
            ///     If <paramref name="truncateSmallAmplitudes" /> is <c>true</c>,
            ///     then amplitudes whose absolute value squared are below this
            ///     threshold are suppressed.
            /// </param>
            public IEnumerable<(Complex, string)> SignificantAmplitudes(
                BasisStateLabelingConvention convention,
                bool truncateSmallAmplitudes, double truncationThreshold
            ) =>
                (
                    truncateSmallAmplitudes
                    ? Amplitudes
                        .Select((amplitude, idx) => (amplitude, idx))
                        .Where(item =>
                            System.Math.Pow(item.amplitude.Magnitude, 2.0) >= truncationThreshold
                        )
                    : Amplitudes.Select((amplitude, idx) => (amplitude, idx))
                )
                .Select(
                    item => (item.amplitude, BasisStateLabel(convention, item.idx))
                )
                .OrderBy(
                    item => item.Item2,
                    // If a basis state label is numeric, we want to compare
                    // numerically rather than lexographically.
                    convention switch {
                        BasisStateLabelingConvention.BigEndian => ToIntComparer,
                        BasisStateLabelingConvention.LittleEndian => ToIntComparer,
                        _ => Comparer<string>.Default
                    }
                );

            /// <summary>
            ///     Using the given labeling convention, returns the label for a
            ///     computational basis state described by its bit string as encoded
            ///     into an integer index in the little-endian encoding.
            /// </summary>
            public string BasisStateLabel(
                BasisStateLabelingConvention convention, int index
            ) => convention switch
                {
                    BasisStateLabelingConvention.Bitstring =>
                        String.Concat(
                            System
                                .Convert
                                .ToString(index, 2)
                                .PadLeft(NQubits, '0')
                                .Reverse()
                        ),
                    BasisStateLabelingConvention.BigEndian =>
                        System.Convert.ToInt64(
                            String.Concat(
                                System.Convert.ToString(index, 2).PadLeft(NQubits, '0').Reverse()
                            ),
                            fromBase: 2
                        )
                        .ToString(),
                    BasisStateLabelingConvention.LittleEndian =>
                        index.ToString(),
                    _ => throw new ArgumentException($"Invalid basis state labeling convention {convention}.")
                };


            /// <summary>
            /// Returns a string that represents the label for the given base state.
            /// </summary>
            public virtual string FormatBaseState(uint idx) 
            {
                int qubitCount = Amplitudes?.Length ?? 0;
                int maxCharsStateId = ((1 << qubitCount) - 1).ToString().Length;

                return $"∣{idx.ToString().PadLeft(maxCharsStateId, ' ')}❭";
            }

            /// <summary>
            /// Returns a string that represents the magnitude of the  amplitude.
            /// </summary>
            public virtual string FormatMagnitude(double magnitude, double phase) =>
                (new String('*', (int)System.Math.Ceiling(20.0 * magnitude))).PadRight(20) + $" [ {magnitude:F6} ]";

            /// <summary>
            /// Returns a string that represents the phase of the amplitude.
            /// </summary>
            public virtual string FormatAngle(double magnitude, double angle)
            {
                var PI = System.Math.PI;
                var offset = PI / 16.0;
                if (magnitude == 0.0)
                {
                    return "                   ";
                }

                var chart = "    ---";
                if (angle > 0)
                {
                    if (angle >= (0 * PI / 8) + offset && angle < ((1 * PI / 8) + offset)) { chart = "     /-"; }
                    if (angle >= (1 * PI / 8) + offset && angle < ((2 * PI / 8) + offset)) { chart = "     / "; }
                    if (angle >= (2 * PI / 8) + offset && angle < ((3 * PI / 8) + offset)) { chart = "    +/ "; }
                    if (angle >= (3 * PI / 8) + offset && angle < ((4 * PI / 8) + offset)) { chart = "   ↑   "; }
                    if (angle >= (4 * PI / 8) + offset && angle < ((5 * PI / 8) + offset)) { chart = " \\-    "; }
                    if (angle >= (5 * PI / 8) + offset && angle < ((6 * PI / 8) + offset)) { chart = " \\     "; }
                    if (angle >= (6 * PI / 8) + offset && angle < ((7 * PI / 8) + offset)) { chart = "+\\     "; }
                    if (angle >= (7 * PI / 8) + offset) { chart = "---    "; }
                }
                else  if (angle < 0)
                {
                    var abs_angle = System.Math.Abs(angle);
                    if (abs_angle >= (0 * PI / 8) + offset && abs_angle < ((1 * PI / 8) + offset)) { chart = "     \\+"; }
                    if (abs_angle >= (1 * PI / 8) + offset && abs_angle < ((2 * PI / 8) + offset)) { chart = "     \\ "; }
                    if (abs_angle >= (2 * PI / 8) + offset && abs_angle < ((3 * PI / 8) + offset)) { chart = "    -\\ "; }
                    if (abs_angle >= (3 * PI / 8) + offset && abs_angle < ((4 * PI / 8) + offset)) { chart = "   ↓   "; }
                    if (abs_angle >= (4 * PI / 8) + offset && abs_angle < ((5 * PI / 8) + offset)) { chart = " /+    "; }
                    if (abs_angle >= (5 * PI / 8) + offset && abs_angle < ((6 * PI / 8) + offset)) { chart = " /     "; }
                    if (abs_angle >= (6 * PI / 8) + offset && abs_angle < ((7 * PI / 8) + offset)) { chart = "-/     "; }
                }

                return $" {chart} [ {angle,8:F5} rad ]";
            }

            /// <summary>
            /// Returns a string for the amplitude's polar representation (magnitude/angle).
            /// </summary>
            public virtual string FormatPolar(double magnitude, double angle) =>
                $"{FormatMagnitude(magnitude, angle)}{FormatAngle(magnitude, angle)}";

            /// <summary>
            /// Returns a string for the amplitude's cartesian representation (real + imagnary).
            /// </summary>
            public virtual string FormatCartesian(double real, double img) =>
                $"{real,9:F6} + {img,9:F6} i";

            /// <summary>
            /// The method to use to format the amplitude into a string.
            /// </summary>
            public virtual string Format(uint idx, double real, double img)
            {
                var amplitude = (real * real) + (img * img);
                var angle = System.Math.Atan2(img, real);

                return $"{FormatBaseState(idx)}:\t" +
                       $"{FormatCartesian(real, img)}\t == \t" +
                       $"{FormatPolar(amplitude, angle)}";

            }

            public string ToString(BasisStateLabelingConvention convention,   // Non-override. Parameterized.
                                   bool truncateSmallAmplitudes, 
                                   double truncationThreshold)
            {
                return string.Join('\n', 
                    SignificantAmplitudes(convention, truncateSmallAmplitudes, truncationThreshold)
                        .Select(
                            item =>
                            {
                                var (cmplx, basisLabel) = item;
                                var amplitude = (cmplx.Real * cmplx.Real) + (cmplx.Imaginary * cmplx.Imaginary);
                                var angle = System.Math.Atan2(cmplx.Imaginary, cmplx.Real);
                                return $"|{basisLabel}⟩\t{FormatCartesian(cmplx.Real, cmplx.Imaginary)}\t == \t" +
                                                       $"{FormatPolar(amplitude, angle)}";
                            }));
            }

            public override string ToString() => // An override of the `object.ToString()`.
                ToString(BasisStateLabelingConvention.LittleEndian, false, 0.0);

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
            // TODO(rokuzmin): What does it return?
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

                // var id = System.Guid.NewGuid();
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
