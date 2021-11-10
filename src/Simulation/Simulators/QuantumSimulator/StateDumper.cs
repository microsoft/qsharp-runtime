// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;   // IComparer
using System.Linq;      // Select
using System.Numerics;  // Complex
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json;  // JsonProperty
using Newtonsoft.Json.Converters;


namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        /// <summary>
        /// This class allows you to dump the state (wave function)
        /// of the QuantumSimulator into a callback function.
        /// The callback function is triggered for every state basis
        /// vector in the wavefunction.
        /// </summary>
        public abstract class StateDumper // Is inherited by (iqsharp's) JupyterDisplayDumper.
        {
            /// <summary>
            /// Basic constructor. Takes the simulator to probe.
            /// </summary>
            public StateDumper(QuantumSimulator qsim)
            {
                this.Simulator = qsim;
            }

            /// <summary>
            /// The callback method that will be used to report the amplitude 
            /// of each basis vector of the wave function.
            /// The method should return 'true' if the QuantumSimulator should 
            /// continue reporting the state of the remaining basis vectors.
            /// </summary>
            /// <param name="idx">The index of the basis state vector being reported.</param>
            /// <param name="real">The real portion of the amplitude of the given basis state vector.</param>
            /// <param name="img">The imaginary portion of the amplitude of the given basis state vector.</param>
            /// <returns>true if dumping should continue, false to stop dumping.</returns>
            public abstract bool Callback(uint idx, double real, double img);

            /// <summary>
            /// The QuantumSimulator being reported.
            /// </summary>
            public QuantumSimulator Simulator { get; }

            /// <summary>
            /// Entry method to get the dump of the wave function.
            /// </summary>
            // TODO(rokuzmin): What does it return?
            public virtual bool Dump(IQArray<Qubit>? qubits = null)
            {
                if (qubits == null)
                {
                    sim_Dump(Simulator.Id, Callback);
                    return true;
                }
                else
                {
                    var ids = qubits.GetIds();
                    return sim_DumpQubits(Simulator.Id, (uint)ids.Length, ids, Callback);
                }
            }
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
            ///     ID for an HTML element where the vertical measurement probability histogram
            ///     will be displayed.
            /// </summary>
            [JsonProperty("div_id")]
            public string DivId { get; set; } = string.Empty;

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
            ///     <see cref="Microsoft.Quantum.Simulation.Simulators.QuantumSimulator.StateDumper.Dump" />.
            /// </remarks>
            [JsonProperty("amplitudes")]
            public Complex[]? Amplitudes { get; set; }


            // TODO(rokuzmin): Make this an extension method for `QuantumSimulator.DisplayableState` in IQSharp repo:

            // /// <summary>
            // ///     An enumerable source of the significant amplitudes of this state
            // ///     vector and their labels, where significance and labels are
            // ///     defined by the values loaded from <paramref name="configurationSource" />.
            // /// </summary>
            // public IEnumerable<(Complex, string)> SignificantAmplitudes(
            //     IConfigurationSource configurationSource
            // ) => SignificantAmplitudes(
            //     configurationSource.BasisStateLabelingConvention,
            //     configurationSource.TruncateSmallAmplitudes,
            //     configurationSource.TruncationThreshold
            // );

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

            public override string ToString()
            {
                if(Amplitudes == null)
                {
                    return "";
                }

                string retVal = "";
                uint idx = 0;
                foreach (Complex complexNum in Amplitudes)
                {
                    // Prepend all the lines with '\n', except the first-most one:
                    retVal = ((retVal == "") ? "" : '\n' + retVal)
                           + Format(idx, complexNum.Real, complexNum.Imaginary);
                    ++idx;
                }

                return retVal;
            }
        } // public class DisplayableState


        /// <summary>
        ///     A state dumper that encodes dumped states into displayable
        ///     objects.
        /// </summary>
        public class DisplayableStateDumper : StateDumper
        {
            private long _count = -1;
            private Complex[]? _data = null;

            // /// <summary>
            // ///     Whether small amplitudes should be truncated when dumping
            // ///     states.
            // /// </summary>
            // public bool TruncateSmallAmplitudes { get; set; } = false;

            // /// <summary>
            // ///     The threshold for truncating measurement probabilities when
            // ///     dumping states. Computational basis states whose measurement
            // ///     probabilities (i.e: squared magnitudes) are below this threshold
            // ///     are subject to truncation when
            // ///     <see cref="IConfigurationSource.TruncateSmallAmplitudes" />
            // ///     is <c>true</c>.
            // /// </summary>
            // public double TruncationThreshold { get; set; } = 1e-10;

            // /// <summary>
            // ///     The labeling convention to be used when labeling computational
            // ///     basis states.
            // /// </summary>
            // public BasisStateLabelingConvention BasisStateLabelingConvention { get; set; } = BasisStateLabelingConvention.Bitstring;

            // /// <summary>
            // ///     Whether the measurement probabilities will be displayed as an
            // ///     interactive histogram.
            // /// </summary>
            // private bool ShowMeasurementDisplayHistogram { get; set; } = false;

            // /// <summary>
            // ///     Sets the properties of this display dumper from a given
            // ///     configuration source.
            // /// </summary>
            // public JupyterDisplayDumper Configure(IConfigurationSource configurationSource)
            // {
            //     configurationSource
            //         .ApplyConfiguration<bool>("dump.measurementDisplayHistogram", value => ShowMeasurementDisplayHistogram = value)
            //         .ApplyConfiguration<bool>("dump.truncateSmallAmplitudes", value => TruncateSmallAmplitudes = value)
            //         .ApplyConfiguration<double>("dump.truncationThreshold", value => TruncationThreshold = value)
            //         .ApplyConfiguration<BasisStateLabelingConvention>(
            //             "dump.basisStateLabelingConvention", value => BasisStateLabelingConvention = value
            //         );
            //     return this;
            // }

            /// <summary>
            /// A method to call to output a string representation.
            /// </summary>
            public virtual Action<string>? FileWriter { get; }

            /// <summary>
            ///     Constructs a new display dumper for a given simulator.
            /// </summary>
            public DisplayableStateDumper(QuantumSimulator sim, Action<string>? fileWriter = null) : base(sim)
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
            ///     Dumps the state of a register of qubits as a Jupyter displayable
            ///     object.
            /// </summary>
            // TODO(rokuzmin): What does it return?
            public override bool Dump(IQArray<Qubit>? qubits = null)
            {
                _count = qubits == null
                            ? this.Simulator.QubitManager?.AllocatedQubitsCount ?? 0
                            : qubits.Length;
                _data = new Complex[1 << ((int)_count)];
                var result = base.Dump(qubits);

                // At this point, _data should be filled with the full state
                // vector, so let's display it, counting on the right display
                // encoder to be there to pack it into a table.

                var id = System.Guid.NewGuid();
                var state = new DisplayableState
                {
                    // We cast here as we don't support a large enough number
                    // of qubits to saturate an int.
                    QubitIds = qubits?.Select(q => q.Id) ?? Simulator.QubitIds.Select(q => (int)q) ?? Enumerable.Empty<int>(),
                    NQubits = (int)_count,
                    Amplitudes = _data,
                    DivId = $"dump-machine-div-{id}" 
                };

                if(this.FileWriter != null)
                {
                    this.FileWriter(state.ToString());
                }
                else
                {
                    Simulator.MaybeDisplayDiagnostic(state);
                }


                // TODO(rokuzmin): Work on this thoroughly on the IQSharp side:

                // if (ShowMeasurementDisplayHistogram)
                // {
                //     Debug.Assert(Channel.CommsRouter != null, "Display dumper requires comms router.");
                //     Channel.CommsRouter.OpenSession(
                //         "iqsharp_state_dump",
                //         new MeasurementHistogramContent()
                //         {
                //             State = state
                //         }
                //     ).Wait();
                // }

                // Clean up the state vector buffer.
                _data = null;

                return result;
            }

        }
    }
}
