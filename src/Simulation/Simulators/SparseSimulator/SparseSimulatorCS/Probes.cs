// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Functions that access the internal wavefunction for diagnostic purposes

using Microsoft.Quantum.Simulation;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using System;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace Microsoft.Quantum.SparseSimulation
{
    public partial class SparseSimulator : QuantumProcessorDispatcher, IDisposable
    {
        // // Converts a big integer into a string label
        // where the label is read over the qubits passed as an argument, in order
        // The label for all other qubits is assumed to be 0
        // That is: Suppose we have 11 = 1011 on qubits 0, 6,9,3.
        // That will output the string 0001001001
        public static string InterleaveLabelByArray(IQArray<Qubit> qubits, System.Numerics.BigInteger label)
        {
            // Converts a big integer into a string label
            // where the label is read over the qubits passed as an argument, in order
            // The label for all other qubits is assumed to be 0
            char[] newlabel = "".PadRight((int)qubits.GetIds().Max() + 1, '0').ToCharArray();
            string test = new string(newlabel);
            for (int idx = 0; idx < (int)qubits.Length; idx++)
            {
                if (((label >> idx) & 1) == 1)
                {
                    int id = qubits[idx].Id;
                    newlabel[id] = '1';
                }
            }
            // std::bitset parses strings backwards
            Array.Reverse(newlabel);
            return new string(newlabel);
        }

        // Dumps the state in qubits to `target` (a filename), if the qubits are 
        // either null or not entangled to the rest of the machine;
        // prints to console if `target` is null
        protected virtual QVoid Dump<T>(T target, IQArray<Qubit> qubits = null)
        {
            
            var filename = (target is QVoid) ? "" : target.ToString();
            var logMessage = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
            // Once it turns `target` into a string action, it calls this process to push output
            // into the string channel
            QVoid process(Action<string> channel)
            {
                // Just to output the ids
                var ids = qubits?.Select(q => q.Id).ToArray() ?? this.QubitManager.AllocatedIds().Select(q => (int)q).ToArray();

                // This will get passed, more or less, to the C++
                SparseSimulatorProcessor.StringCallback callback = (string label, double real, double imag) =>
                {
                    channel(Format(label, real, imag));
                };

                channel($"# wave function for qubits with ids (least to most significant): {string.Join(";", ids)}");

                // Calls the internal SparseSimulatorProcessor, which calls C++.
                // Returns false if the state was entangled.
                if (!((SparseSimulatorProcessor)this.QuantumProcessor).Dump(callback, ids.Max(), qubits))
                {
                    channel("## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##");
                }

                return QVoid.Instance;
            }

            // This generates the channel, then calls it
            // If no file provided, use `Message` to generate the message into the console;
            if (string.IsNullOrWhiteSpace(filename))
            {
                var op = this.Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();
                return process((msg) => op.Apply(msg));
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
                    return QVoid.Instance;
                }
            }
        }


        // Called by the diagnostics functions
        public class SparseSimDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private SparseSimulator Simulator { get; }

            public SparseSimDumpMachine(SparseSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                return Simulator.Dump(location);
            };
        }

        // Called by the diagnostics functions
        public class QSimDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private SparseSimulator Simulator { get; }


            public QSimDumpRegister(SparseSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                return Simulator.Dump(location, qubits);
            };
        }

        private string FormatMagnitude(double magnitude, double phase) =>
                (new String('*', (int)System.Math.Ceiling(20.0 * magnitude))).PadRight(20) + $" [ {magnitude:F6} ]";

        /// <summary>
        /// Returns a string that represents the phase of the amplitude.
        /// </summary>
        private string FormatAngle(double magnitude, double angle)
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
            else if (angle < 0)
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
        private string FormatPolar(double magnitude, double angle) =>
            $"{FormatMagnitude(magnitude, angle)}{FormatAngle(magnitude, angle)}";

        /// <summary>
        /// Returns a string for the amplitude's cartesian representation (real + imagnary).
        /// </summary>
        private string FormatCartesian(double real, double img) =>
            $"{real,9:F6} + {img,9:F6} i";

        /// <summary>
        /// The method to use to format the amplitude into a string.
        /// </summary>
        private string Format(string label, double real, double img)
        {
            var amplitude = (real * real) + (img * img);
            var angle = System.Math.Atan2(img, real);

            return $"{label}:\t" +
                   $"{FormatCartesian(real, img)}\t == \t" +
                   $"{FormatPolar(amplitude, angle)}";

        }

    }

    public partial class SparseSimulatorProcessor : QuantumProcessorBase {


        // These two delegates exist so that C# can use StringCallback (which has a nice
        // string object) and C++ can use DumpCallback (which can handle char*)
        public delegate void StringCallback(string label, double real, double img);

        private delegate void DumpCallback(StringBuilder label, double real, double img);
        [DllImport(simulator_dll)]
        private static extern void Dump_cpp(uint sim, uint max_qubits, DumpCallback callback);

        // This gets called by the base class
        public bool Dump(StringCallback callback,  int max_id, IQArray<Qubit> qubits = null)
        {
            DumpCallback _callback = (StringBuilder label_builder, double real, double imag) =>
            {
                callback(label_builder.ToString(), real, imag);
            };

            // It's expensive for the C++ simulator to separate two parts of a wavefunction,
            // so if we just want the full state, it calls a different function     
            if (qubits == null)
            {
                Dump_cpp(Id, (uint)max_id, _callback);
                return true;
            } else
            {
                return DumpQubits_cpp(Id, qubits.Count(), qubits.Select(x => x.Id).ToArray(), _callback) ;
            }
        }

        [DllImport(simulator_dll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool DumpQubits_cpp(uint sim, int length, int[] qubit_ids, DumpCallback callback);

        [DllImport(simulator_dll)]
        private static extern uint num_qubits_cpp(uint sim);
    }

}
