// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

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
        public abstract class StateDumper
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
            /// The QuantumSimautor being reported.
            /// </summary>
            public QuantumSimulator Simulator { get; }

            /// <summary>
            /// Entry method to get the dump of the wave function.
            /// </summary>
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
        /// A simple implementation of a <see cref="StateDumper"/>. It outputs the
        /// a string representation of the state to the given channel.
        /// </summary>
        public class SimpleDumper : StateDumper
        {
            private int _maxCharsStateId;

            public SimpleDumper(QuantumSimulator qsim, Action<string> channel) : base(qsim)
            {
                this.Channel = channel;
            }

            /// <summary>
            /// A method to call to output a string representation of the amplitude of each
            /// state basis vector.
            /// </summary>
            public virtual Action<string> Channel { get; }

            /// <summary>
            /// Returns a string that represents the label for the given base state.
            /// </summary>
            public virtual string FormatBaseState(uint idx) =>
                $"∣{idx.ToString().PadLeft(_maxCharsStateId, ' ')}❭";

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

            /// <summary>
            /// The callback method. Formats the given state and invokes the <see cref="Channel"/>
            /// </summary>
            /// <returns>True, so the entire wave function is dumped.</returns>
            public override bool Callback(uint idx, double real, double img)
            {
                Channel(Format(idx, real, img));
                return true;
            }

            public override bool Dump(IQArray<Qubit>? qubits = null)
            {
                var count = qubits == null
                    ? this.Simulator.QubitManager.AllocatedQubitsCount
                    : qubits.Length;
                this._maxCharsStateId = ((1 << (int)count) - 1).ToString().Length;

                return base.Dump(qubits);
            }
        }
    }
}
