using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public static class BigIntegerExtensions
    {
        public static string Reverse(this string s)
        {
           char[] charArray = s.ToCharArray();
            Array.Reverse(charArray);
            return new string(charArray);
        }

        public static string ToUnsignedBitString(this BigInteger bigInt, int qubitCount, bool bigEndian = false)
        {
            byte[] bytes = bigInt.ToByteArray();    // `bytes[0]` is the least significant byte.
            System.Text.StringBuilder sb = new System.Text.StringBuilder(bytes.Length * 8);
            for(uint idx = 0; idx < bytes.Length; ++idx)
            {
                sb.Append(System.Convert.ToString(bytes[idx],   // 0x4
                                                  2)            // "100"
                            .PadLeft(qubitCount, '0')           // "000100" (qubitCount: 6)
                            .Reverse()); //.ToString());        // "001000" (4 in little endian bit string)
            }
            string retVal = sb.ToString();
            return (bigEndian ? retVal.Reverse()/*.ToString()*/ : retVal);
        }

        public static BigInteger ParseUnsignedLEBitString(string str/*, bool bigEndian = false*/)
        {
            // string tmpStr = (bigEndian ? str : str.Reverse().ToString());
            // var tmpStr = str;
            string tmpStr = str.Reverse();  //.ToString();

            BigInteger retVal = 0;
            foreach(char c in tmpStr)
            {
                retVal <<= 1;
                retVal += (c - '0');
            }
            return retVal;
        }
    }

    public partial class CommonNativeSimulator
    {
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
                    Comparer<BigInteger>.Default.Compare(
                        //BigInteger.Parse(label1), BigInteger.Parse(label2)
                        BigIntegerExtensions.ParseUnsignedLEBitString(label1), 
                        BigIntegerExtensions.ParseUnsignedLEBitString(label2)
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
            // public IDictionary<string, Complex>? Amplitudes { get; set; }
            public IDictionary<BigInteger, Complex>? Amplitudes { get; set; }

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
                        .Where(item =>
                            System.Math.Pow(item.Value.Magnitude, 2.0) >= truncationThreshold
                        )
                    : Amplitudes
                )
                .Select(
                    item => (item.Value, BasisStateLabel(convention, item.Key))
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
                // BasisStateLabelingConvention convention, string index // index is a string of bits
                BasisStateLabelingConvention convention, BigInteger index // index is a string of bits
            ) => convention switch
                {
                    BasisStateLabelingConvention.Bitstring =>
                        //index,
                        // UnsignedBitStringFromBigInt(index),
                        index.ToUnsignedBitString(NQubits),
                    BasisStateLabelingConvention.BigEndian =>
                        // DecimalFromBitString(index),
                        // UnsignedBitStringFromBigInt(index, true),
                        //index.ToUnsignedBitString(NQubits, true),
                        BigIntegerExtensions.ParseUnsignedLEBitString(index.ToUnsignedBitString(NQubits, true)).ToString(),
                        //index.ToUnsignedBitString(NQubits),
                    BasisStateLabelingConvention.LittleEndian =>
                        // DecimalFromBitString(index, false),
                        // UnsignedBitStringFromBigInt(index),
                        //index.ToUnsignedBitString(NQubits),
                        index.ToString(),
                    _ => throw new ArgumentException($"Invalid basis state labeling convention {convention}.")
                };

            // private string UnsignedBitStringFromBigInt(BigInteger bigInt, bool bigEndian = false)
            // {
            //     byte[] bytes = bigInt.ToByteArray();
            //     System.Text.StringBuilder sb = new System.Text.StringBuilder(bytes.Length * 8);
            //     for(uint idx = 0; idx < bytes.Length; ++idx)
            //     {
            //         sb.Append(System.Convert.ToString(bytes[idx], 2)    .PadLeft(8, '0')          .Reverse().ToString());
            //             //                               0x3        "11"                "00000011"          "11000000"
            //     }
            //     string retVal = sb.ToString();
            //     return (bigEndian ? retVal.Reverse().ToString() : retVal);
            // }

            // /// <summary>
            // ///     Convert a bitstring string to a string containing the decimal number
            // ///     that corresponds to the bitstring.
            // /// </summary>
            // private string DecimalFromBitString(string bitString, bool bigEndian=true)
            // {
            //     var integer = BigInteger.Zero;

            //     foreach (var c in (bigEndian ? bitString : bitString.Reverse()))
            //     {
            //         integer <<= 1;
            //         if (c == '1')
            //         {
            //             integer |= 1;
            //         }
            //     }

            //     return integer.ToString();
            // }

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

    }
}
