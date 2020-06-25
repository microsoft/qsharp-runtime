// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using static System.Math;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

namespace Microsoft.Quantum.Simulation.Simulators
{

    // ToffoliSimulator is implemented based on `QuantumProcessorDispatcher`,
    // which is constructed using a specialization `QuantumProcessorBase`.  The
    // specialization overrides methods to specify actions on intrinsic
    // operations in the Q# code.
    class ToffoliSimulatorProcessor : QuantumProcessorBase
    {
        // This property controls whether to throw an exception when a qubit is
        // released that is not in the zero state.
        public bool ThrowOnReleasingQubitsNotInZeroState { get; set; } = true;

        // The simulation values are stored in the bits of a BitArray, which
        // can use integers to store several bits at once.  We initialize the
        // bit array to contain up to 64 bits and will dynamically grow it,
        // whenever this capacity is exceeded.
        public BitArray SimulationValues { get; private set; }

        public ToffoliDumpFormat DumpFormat { get; set; } = ToffoliDumpFormat.Automatic;

        // A property that must be assigned from the dispatcher to return the allocated
        // qubit ids from the qubit manager
        public Func<IEnumerable<long>>? GetAllocatedIds { get; set; }

        // A property that must be assigned from the dispatcher to print a Q# message
        public Action<String>? Message { get; set; }

        private Dictionary<Qubit, Stack<bool>> borrowedQubitStates { get; } = new Dictionary<Qubit, Stack<bool>>();
        private const double Tolerance = 1.0E-10;

        public ToffoliSimulatorProcessor(uint qubitCount, bool throwOnReleasingQubitsNotInZeroState)
        {
            SimulationValues = new BitArray((int)qubitCount);
            ThrowOnReleasingQubitsNotInZeroState = throwOnReleasingQubitsNotInZeroState;
        }

        // Three helper functions manipulate the bits in the bit array given a
        // qubit as input. GetValue returns the simulation value at the
        // corresponding index.
        private bool GetValue(Qubit qubit)
        {
            return SimulationValues[qubit.Id];
        }

        // SetValue sets the simulation value at the corresponding index.
        private void SetValue(Qubit qubit, bool value)
        {
            SimulationValues[qubit.Id] = value;
        }

        // InvertValue inverts the simulation value at the corresponding index.
        private void InvertValue(Qubit qubit)
        {
            SimulationValues[qubit.Id] = !SimulationValues[qubit.Id];
        }

        // When allocating a qubit whose index equals or exceeds the current
        // number of simulation values stored in the bit array, the bit array is
        // resized to twice its current size.
        public override void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            if (qubits.Count == 0) return;

            long maxId = qubits.Max(q => q.Id);
            if (maxId >= SimulationValues.Length)
            {
                SimulationValues.Length = (int)Ceiling(Log((maxId + 1) / (double)SimulationValues.Length) / Log(2.0));
            }
        }

        // When releasing qubits that are not in the zero state, their value is
        // reset to false.  If the ThrowOnReleasingQubitsNotInZeroState property
        // is assigned true, an exception is thrown.
        public override void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            foreach (var qubit in qubits)
            {
                if (GetValue(qubit))
                {
                    if (ThrowOnReleasingQubitsNotInZeroState)
                    {
                        throw new ReleasedQubitsAreNotInZeroState();
                    }
                    SetValue(qubit, false);
                }
            }
        }

        // The borrowed qubits' states are stored on a stack together with their current value.
        // The value is used for comparison when the qubit is returned.
        public override void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
            foreach (var qubit in qubits)
            {
                Stack<bool> stack;
                if (!borrowedQubitStates.TryGetValue(qubit, out stack))
                {
                    stack = new Stack<bool>();
                    borrowedQubitStates.Add(qubit, stack);
                }
                stack.Push(GetValue(qubit));
            }
        }

        // A qubit must be returned in its original value when borrowed.
        public override void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            foreach (var qubit in qubits)
            {
                var stack = borrowedQubitStates[qubit];
                if (stack.Pop() != GetValue(qubit))
                {
                    throw new ExecutionFailException("Borrowed qubit returned not in the original state");
                }

                if (stack.Count == 0)
                {
                    borrowedQubitStates.Remove(qubit);
                }
            }
        }

        // An X operation inverts the bit in the `simulationValues` variable at
        // the position of the qubit's index.
        public override void X(Qubit qubit)
        {
            InvertValue(qubit);
        }

        // If the simulation values of all control qubits are assigned true,
        // the simulation value of the target qubit is inverted.
        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.All(control => GetValue(control)))
            {
                InvertValue(qubit);
            }
        }

        // SWAP interchanges the simulation values at two locations.
        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            bool tmp = GetValue(qubit1);
            SetValue(qubit1, GetValue(qubit2));
            SetValue(qubit2, tmp);
        }

        public override void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            if (controls.All(control => GetValue(control)))
            {
                bool tmp = GetValue(qubit1);
                SetValue(qubit1, GetValue(qubit2));
                SetValue(qubit2, tmp);
            }
        }

        /// <summary>
        /// Make sure that a rotation is either the identity or an X, up to global phase.
        /// Assumes that the rotation is exp(i*theta*sigma(axis)), where sigma(axis) is
        /// the appropriate Pauli matrix normalized to +/-1 eigenvalues.
        /// Throws an exception if the rotation is invalid.
        /// </summary>
        /// <param name="axis">The rotation axis</param>
        /// <param name="theta">The rotation angle, properly normalized</param>
        /// <returns>A pair of flags. The first indicates whether the rotation is
        /// equivalent to X; the second whether or not the rotation is exactly equal
        /// to the identity (no phase), and thus may be controlled.</returns>
        private (bool isX, bool safe) CheckRotation(Pauli axis, double theta)
        {
            // Rotations around X of odd multiples of pi/2 are X (up to global phase).
            // Rotations around any axis of multiples of pi are I (up to global phase).
            // Rotations of any angle around I are I.
            // Rotations around any axis of even multiples of pi are safe to control.

            double piOverTwoRatio = Abs(theta) / (PI / 2.0);
            if (Abs(piOverTwoRatio - Round(piOverTwoRatio)) > Tolerance)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform rotations of multiples of pi/2.");
            }

            var piOverTwoCount = (int)Round(piOverTwoRatio);

            bool equivalentToX = (axis == Pauli.PauliX) && (piOverTwoCount % 2 == 1);
            bool safeToControl = piOverTwoCount % 4 == 0;

            if ((axis == Pauli.PauliZ || axis == Pauli.PauliY) && (piOverTwoCount % 2 == 1))
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform non-identity rotations around the X axis.");
            }

            return (equivalentToX, safeToControl);
        }

        /// <summary>
        /// Make sure that a rotation defined as a fraction of a power of two is either
        /// the identity or an X, up to global phase.
        /// Assumes that the rotation is exp(i*pi*numerator/(2^power)*sigma(axis)),
        /// where sigma(axis) is the appropriate Pauli matrix normalized to +/-1 eigenvalues.
        /// Throws an exception if the rotation is invalid.
        /// </summary>
        /// <param name="axis">The rotation axis</param>
        /// <param name="numerator">The numerator of the rotation angle</param>
        /// <param name="power">The power of two for the denominator of the
        /// rotation angle</param>
        /// <returns>A pair of flags. The first indicates whether the rotation is
        /// equivalent to X; the second whether or not the rotation is exactly equal
        /// to the identity (no phase), and thus may be controlled.</returns>
        private (bool isX, bool safe) CheckRotation(Pauli axis, long numerator, long power)
        {
            // Rotations around X of odd multiples of pi/2 are X (up to global phase).
            // Rotations around any axis of multiples of pi are I (up to global phase).
            // Rotations of any angle around I are I.
            // Rotations around any axis of even multiples of pi are safe to control.
            // The angle here is pi*numerator/(2^power).

            // The sign of the numerator doesn't matter.
            // Reduce the numerator and power in case there are factors of 2 in the numerator.
            numerator = Abs(numerator);
            while (power > 0 && numerator % 2 == 0)
            {
                numerator /= 2;
                power--;
            }

            bool equivalentToX = false;
            bool safeToControl = false;

            // If the power < 0, we're guaranteed to be a multiple of 2*pi, so exactly the identity.
            if (power < 0)
            {
                equivalentToX = false;
                safeToControl = true;
            }
            // If power > 1, then we're an odd multiple of pi/4, so illegal
            else if (power > 1)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform rotations of multiples of pi/2.");
            }
            // If power == 1, then we're an odd multiple of pi/2, so X if the axis is X, 
            // I if the axis is I, and illegal otherwise.
            else if (power == 1)
            {
                switch (axis)
                {
                    case Pauli.PauliI:
                        equivalentToX = false;
                        safeToControl = false;
                        break;
                    case Pauli.PauliX:
                        equivalentToX = true;
                        safeToControl = false;
                        break;
                    case Pauli.PauliY:
                    case Pauli.PauliZ:
                        throw new InvalidOperationException($"The Toffoli simulator can only perform non-identity rotations around the X axis.");
                }
            }
            // If power == 0, then we're a multiple of pi, possible an even multiple.
            else
            {
                equivalentToX = false;
                safeToControl = numerator % 2 == 0;
            }

            return (equivalentToX, safeToControl);
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            if (CheckRotation(axis, theta / 2.0).isX)
            {
                X(qubit);
            }
        }

        public override void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            if (!CheckRotation(axis, theta / 2.0).safe)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
            }
        }

        public override void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            if (CheckRotation(axis, numerator, power).isX)
            {
                X(qubit);
            }
        }

        public override void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            if (!CheckRotation(axis, numerator, power).safe)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
            }
        }

        public override void Exp(IQArray<Pauli> bases, double theta, IQArray<Qubit> qubits)
        {
            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (bases, qubits), must be of same size.");
            }

            foreach (var (qubit, pauli) in qubits.Zip(bases, (q, p) => (q, p)))
            {
                if (CheckRotation(pauli, theta).isX)
                {
                    X(qubit);
                }
            }
        }

        public override void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> bases, double theta, IQArray<Qubit> qubits)
        {
            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (bases, qubits), must be of same size.");
            }

            foreach (var (qubit, pauli) in qubits.Zip(bases, (q, p) => (q, p)))
            {
                if (!CheckRotation(pauli, theta).safe)
                {
                    throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
                }
            }
        }

        public override void ExpFrac(IQArray<Pauli> bases, long numerator, long power, IQArray<Qubit> qubits)
        {
            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (bases, qubits), must be of same size.");
            }

            foreach (var (qubit, pauli) in qubits.Zip(bases, (q, p) => (q, p)))
            {
                if (CheckRotation(pauli, numerator, power).isX)
                {
                    X(qubit);
                }
            }
        }

        public override void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> bases, long numerator, long power, IQArray<Qubit> qubits)
        {
            if (qubits.Length != bases.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Exp (bases, qubits), must be of same size.");
            }

            foreach (var (qubit, pauli) in qubits.Zip(bases, (q, p) => (q, p)))
            {
                if (!CheckRotation(pauli, numerator, power).safe)
                {
                    throw new InvalidOperationException($"The Toffoli simulator can only perform controlled rotations of multiples of 2*pi.");
                }
            }
        }

        // If the simulation value of qubit is true, when it's being reset, we
        // restore it to false.
        public override void Reset(Qubit qubit)
        {
            SetValue(qubit, false);
        }

        // Measuring the qubit corresponds to translating the current simulation
        // value into a Result value.
        public override Result M(Qubit qubit) =>
            GetValue(qubit).ToResult();


        private Func<Pauli, Qubit, Qubit?> PauliFilter(string operation) =>
            (Pauli p, Qubit q) =>
                p switch
                {
                    Pauli.PauliI => null,
                    Pauli.PauliZ => q,
                    _ => throw new InvalidOperationException($"{operation} on bases other than PauliI and PauliZ not supported")
                };

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            if (bases.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Measure (bases, qubits), must be of same size.");
            }

            var qubitsToMeasure = bases.Zip(qubits, PauliFilter("Measure")).WhereNotNull();
            bool result = qubitsToMeasure.Aggregate(false, (accu, qubit) => accu ^ GetValue(qubit));
            return result.ToResult();
        }

        // Overriding the Assert methods enables the use of statements such as
        // `AssertQubit(Zero, q)` inside a Q# program.
        public override void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result expected, string msg)
        {
            if (bases.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for Assert (bases, qubits), must be of same size.");
            }

            // All qubits are considered whose corresponding measurement basis
            // is PauliZ.  Measurement in PauliI basis are ignored, and other
            // bases will raise an exception.
            var qubitsToMeasure = bases.Zip(qubits, PauliFilter("Assert")).WhereNotNull();

            // A multi-qubit measurement in the PauliZ basis corresponds to
            // computing the parity of all involved qubits' measurement values.
            // (see also https://docs.microsoft.com/quantum/concepts/pauli-measurements#multiple-qubit-measurements)
            // We use Aggregate to successively XOR a qubit's simulation value
            // to an accumulator value `accu` that is initialized to `false`.
            bool actual = qubitsToMeasure.Aggregate(false, (accu, qubit) => accu ^ GetValue(qubit));
            if (actual.ToResult() != expected)
            {
                // If the expected value does not correspond to the actual measurement
                // value, we throw a Q# specific Exception together with the user
                // defined message `msg`.
                throw new ExecutionFailException(msg);
            }
        }

        public override void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tolerance)
        {
            if (bases.Length != qubits.Length)
            {
                throw new InvalidOperationException($"Both input arrays for AssertProb (bases, qubits), must be of same size.");
            }

            if ((probabilityOfZero + tolerance >= 1.0) && (probabilityOfZero - tolerance <= 0.0))
            {
                return;
            }

            // If there are any X- or Y-basis measurements, then the probability is 50%
            if (bases.Any(p => p == Pauli.PauliX || p == Pauli.PauliY))
            {
                if (Abs(0.5 - probabilityOfZero) > tolerance)
                {
                    throw new ExecutionFailException(msg);
                }
            }
            else
            {
                // Pick out just the Z measurements
                var qubitsToMeasure = bases.Zip(qubits, PauliFilter("AssertProb")).WhereNotNull();
                double actual = qubitsToMeasure.Aggregate(false, (accu, qubit) => accu ^ GetValue(qubit)) ? 0.0 : 1.0;

                if (Abs(actual - probabilityOfZero) > tolerance)
                {
                    throw new ExecutionFailException(msg);
                }
            }
        }

        public override void OnDumpMachine<T>(T location)
        {
            if (location == null) { throw new ArgumentNullException(nameof(location)); }

            var filename = location is QVoid ? "" : location.ToString();
            DumpState(GetAllocatedIds!().Select(id => (int)id), filename);
        }

        public override void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
            var ids = qubits.OrderBy(q => q.Id).Select(q => q.Id);
            var filename = location is QVoid ? "" : location.ToString();
            DumpState(ids, filename);
        }

        private void DumpState(IEnumerable<int> ids, String filename)
        {
            var data = ids.Select(id => SimulationValues[id]).ToArray();
            Action<Action<string>> dump = DumpFormat switch
            {
                ToffoliDumpFormat.Automatic => channel => data.Dump(channel),
                ToffoliDumpFormat.Bits => channel => data.DumpAsBits(channel),
                ToffoliDumpFormat.Hex => channel => data.DumpAsHex(channel),
                _ => throw new ArgumentException($"Invalid format: ${DumpFormat}")
            };

            if (string.IsNullOrWhiteSpace(filename))
            {
                dump((msg) => Message!(msg));
            }
            else
            {
                try
                {
                    using var file = new System.IO.StreamWriter(filename);
                    dump(file.WriteLine);
                }
                catch (Exception e)
                {
                    Message!($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
        }
    }
}
