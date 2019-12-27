// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using static System.Math;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public enum ToffoliDumpFormat
    {
        Bits,
        Hex,
        Automatic
    }

    /// <summary>
    /// The Toffoli simulator implementation class.
    /// </summary>
    public partial class ToffoliSimulator : SimulatorBase
    {
        /// <summary>
        /// The default number of qubits to allocate.
        /// Note that this simulator does not allow resizing after construction.
        /// </summary>
        public const uint DEFAULT_QUBIT_COUNT = 65536;
        private const double Tolerance = 1.0E-10;

        public ToffoliDumpFormat DumpFormat { get; set; } = ToffoliDumpFormat.Automatic;

        /// <summary>
        /// Constructs a default Toffoli simulator instance.
        /// </summary>
        public ToffoliSimulator() : this(DEFAULT_QUBIT_COUNT) { }

        /// <summary>
        /// Constructs a Toffoli simulator instance with the specified qubit count.
        /// </summary>
        /// <param name="qubitCount">The number of qubits to allocate.
        /// There is an overhead of one byte of memory usage per allocated qubit.
        /// There is no time overhead from allocating more qubits.</param>
        public ToffoliSimulator(uint qubitCount) 
            : base(new QubitManagerTrackingScope(qubitCapacity: qubitCount, mayExtendCapacity: false, disableBorrowing: false))
        {
            this.State = new bool[qubitCount];
            this.borrowedQubitStates = new Dictionary<int, Stack<bool>>();
        }

        /// <summary>
        /// The name of an instance of this simulator.
        /// </summary>
        public override string Name
        {
            get
            {
                return "Toffoli Simulator";
            }
        }

        /// <summary>
        /// The state of the simulator; always a simple product state in the computational (Z) basis.
        /// Note that "true" bits are in the Z=One state.
        /// </summary>
        public bool[] State { get; private set; } // Could be private except for tests
        private Dictionary<int, Stack<bool>> borrowedQubitStates { get; set; }

        internal void DoX(Qubit q)
        {
            State[q.Id] = !State[q.Id];
        }

        internal bool GetX(Qubit q) => State[q.Id];

        internal void DoSwap(Qubit q1, Qubit q2)
        {
            var temp = State[q1.Id];
            State[q1.Id] = State[q2.Id];
            State[q2.Id] = temp;
        }

        /// <summary>
        /// Gets the parity of a group of qubits.
        /// Specifically, this counts the number of qubits in the One state, and returns 
        /// true if the number is odd and false if it's even.
        /// </summary>
        /// <param name="qubits">The sequence of qubits</param>
        /// <returns>true if there are an odd number of qubits in the true (One) state, 
        /// and false if there are an even number in the true state</returns>
        internal bool GetParity(IEnumerable<Qubit> qubits)
        {
            var result = false;
            foreach (var q in qubits)
            {
                result ^= GetX(q);
            }
            return result;
        }

        /// Verify the qubits for a controlled operation with a single target,
        /// including checking that all qubits are distinct.
        internal void CheckControlQubits(IQArray<Qubit> ctrls, Qubit target)
        {
            CheckQubits(ctrls, "ctrls");

            CheckQubit(target, "target");

            var inUse = new HashSet<int>();
            foreach (var c in ctrls)
            {
                if (!inUse.Add(c.Id))
                {
                    throw new NotDistinctQubits(c);
                }
            }
            if (inUse.Contains(target.Id))
            {
                throw new NotDistinctQubits(target);
            }
        }

        /// Verify the qubits for a controlled operation with multiple targets,
        /// including checking that all qubits are distinct.
        internal void CheckControlQubits(IQArray<Qubit> ctrls, IQArray<Qubit> targets)
        {
            CheckQubits(ctrls, "ctrls");
            CheckQubits(targets, "targets");

            var inUse = new HashSet<int>();
            foreach (var c in ctrls)
            {
                if (!inUse.Add(c.Id))
                {
                    throw new NotDistinctQubits(c);
                }
            }
            foreach (var t in targets)
            {
                if (!inUse.Add(t.Id))
                {
                    throw new NotDistinctQubits(t);
                }
            }
        }

        /// <summary>
        /// Verify that all of the control qubits for an operation are in the 1 state
        /// </summary>
        /// <param name="ctrls"></param>
        /// <returns></returns>
        internal bool VerifyControlCondition(IQArray<Qubit> ctrls)
        {
            return ctrls.All(c => State[c.Id]);
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
        internal static (bool, bool) CheckRotation(Pauli axis, double theta)
        {
            // Rotations around X of odd multiples of pi/2 are X (up to global phase).
            // Rotations around any axis of multiples of pi are I (up to global phase).
            // Rotations of any angle around I are I.
            // Rotations around any axis of even multiples of pi are safe to control.

            var piOverTwoRatio = Abs(theta) / (PI / 2.0);
            if (Abs(piOverTwoRatio - Round(piOverTwoRatio)) > Tolerance)
            {
                throw new InvalidOperationException($"The Toffoli simulator can only perform rotations of multiples of pi/2.");
            }

            var piOverTwoCount = (int)Round(piOverTwoRatio);

            var equivalentToX = (axis == Pauli.PauliX) && (piOverTwoCount % 2 == 1);
            var safeToControl = (piOverTwoCount % 4 == 0);

            if (((axis == Pauli.PauliZ) || (axis == Pauli.PauliY)) && (piOverTwoCount % 2 == 1))
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
        internal static (bool, bool) CheckRotation(Pauli axis, long numerator, long power)
        {
            // Rotations around X of odd multiples of pi/2 are X (up to global phase).
            // Rotations around any axis of multiples of pi are I (up to global phase).
            // Rotations of any angle around I are I.
            // Rotations around any axis of even multiples of pi are safe to control.
            // The angle here is pi*numerator/(2^power).

            // The sign of the numerator doesn't matter.
            // Reduce the numerator and power in case there are factors of 2 in the numerator.
            numerator = Abs(numerator);
            while ((power > 0) && (numerator % 2 == 0))
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
                safeToControl = (numerator % 2 == 0);
            }

            return (equivalentToX, safeToControl);
        }

        /// <summary>
        /// Mark a qubit as being borrowed, tracking its state before borrowing.
        /// </summary>
        /// <param name="q">The qubit being borrowed.</param>
        internal void BorrowQubit(Qubit q)
        {
            Stack<bool> stack;
            if (!borrowedQubitStates.TryGetValue(q.Id, out stack))
            {
                stack = new Stack<bool>();
                borrowedQubitStates.Add(q.Id, stack);
            }
            stack.Push(State[q.Id]);
        }

        /// <summary>
        /// Mark a group of qubits as being borrowed, tracking their states before borrowing.
        /// </summary>
        /// <param name="qs">The qubits being borrowed.</param>
        internal void BorrowQubits(IEnumerable<Qubit> qs)
        {
            foreach (var q in qs)
            {
                BorrowQubit(q);
            }
        }

        /// <summary>
        /// Validate that a borrowed qubit is being returned in its original state.
        /// </summary>
        /// <param name="q">The qubit being returned.</param>
        internal void ReturnQubit(Qubit q)
        {
            var stack = borrowedQubitStates[q.Id];
            if (stack.Pop() != State[q.Id])
            {
                throw new ExecutionFailException("Borrowed qubit returned not in the original state");
            }

            if (stack.Count == 0)
            {
                borrowedQubitStates.Remove(q.Id);
            }
        }

        /// <summary>
        /// Validate that a group of borrowed qubits are being returned in their original states.
        /// </summary>
        /// <param name="qs">The qubits being returned.</param>
        internal void ReturnQubits(IEnumerable<Qubit> qs)
        {
            foreach (var q in qs)
            {
                ReturnQubit(q);
            }
        }

        /// <summary>
        /// Dumps the state of a set of qubits for debugging purposes.
        /// </summary>
        /// <param name="ids">The ids of the qubits to dump</param>
        /// <param name="filename">The name of the file to write to; if null or the empty string
        /// or just whitespace, the console is written to</param>
        internal void DumpState(long[] ids, string filename)
        {
            var data = ids.Select(id => State[id]).ToArray();
            Action<Action<string>> dump = DumpFormat switch
            {
                ToffoliDumpFormat.Automatic => (channel) => data.Dump(channel),
                ToffoliDumpFormat.Bits => (channel) => data.DumpAsBits(channel),
                ToffoliDumpFormat.Hex => (channel) => data.DumpAsHex(channel),
                _ => throw new ArgumentException($"Invalid format: ${DumpFormat}")
            };

            var logMessage = Get<ICallable<string, QVoid>, Microsoft.Quantum.Intrinsic.Message>();

            if (string.IsNullOrWhiteSpace(filename))
            {
                dump((msg) => logMessage.Apply(msg));
            }
            else
            {
                try
                {
                    using (var file = new System.IO.StreamWriter(filename))
                    {
                        dump(file.WriteLine);
                    }
                }
                catch (Exception e)
                {
                    logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
        }

        /// <summary>
        /// Implementation of the (internal) Release operation for the Toffoli simulator.
        /// </summary>
        public class TSRelease : Intrinsic.Release
        {
            private ToffoliSimulator simulator { get; }
            private IQubitManager manager;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public TSRelease(ToffoliSimulator m) : base(m)
            {
                simulator = m;
                manager = m.QubitManager;
            }

            /// <summary>
            /// Releases a single qubit.
            /// </summary>
            /// <param name="q">The qubit to release.</param>
            public override void Apply(Qubit q)
            {
                if (simulator.State[q.Id])
                {
                    throw new ReleasedQubitsAreNotInZeroState();
                }
                manager.Release(q);
            }

            /// <summary>
            /// Releases an array of qubits.
            /// </summary>
            /// <param name="qubits">The qubits to release.</param>
            public override void Apply(IQArray<Qubit> qubits)
            {
                // Note that we need to handle null array pointers (as opposed to empty arrays)
                if (qubits != null)
                {
                    foreach (var q in qubits)
                    {
                        if (simulator.State[q.Id])
                        {
                            throw new ReleasedQubitsAreNotInZeroState();
                        }
                    }
                }
                manager.Release(qubits);
            }
        }

        /// <summary>
        /// Implementation of the (internal) Borrow operation for the Toffoli simulator.
        /// </summary>
        public class TSBorrow : Intrinsic.Borrow
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public TSBorrow(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// Borrows a single qubit.
            /// </summary>
            /// <returns>The borrowed qubit.</returns>
            public override Qubit Apply()
            {
                var qb = simulator.QubitManager.Borrow();
                simulator.BorrowQubit(qb);
                return qb;
            }

            /// <summary>
            /// Borrows multiple qubits.
            /// </summary>
            /// <param name="count">The number of qubits to borrow.</param>
            /// <returns>The array of borrowed qubits.</returns>
            public override IQArray<Qubit> Apply(long count)
            {
                var qubits = simulator.QubitManager.Borrow(count);
                simulator.BorrowQubits(qubits);
                return qubits;
            }
        }

        /// <summary>
        /// Implementation of the (internal) Return operation for the Toffoli simulator.
        /// </summary>
        public class TSReturn : Intrinsic.Return
        {
            private ToffoliSimulator simulator;

            /// <summary>
            /// Constructs a new operation instance.
            /// </summary>
            /// <param name="m">The simulator that this operation affects.</param>
            public TSReturn(ToffoliSimulator m) : base(m)
            {
                simulator = m;
            }

            /// <summary>
            /// Returns a single qubit.
            /// </summary>
            /// <param name="q">The qubit to return</param>
            public override void Apply(Qubit q)
            {
                simulator.ReturnQubit(q);
                simulator.QubitManager.Return(q);
            }

            /// <summary>
            /// Returns an array of qubits.
            /// </summary>
            /// <param name="qubits">The qubits to return.</param>
            public override void Apply(IQArray<Qubit> qubits)
            {
                simulator.ReturnQubits(qubits);
                simulator.QubitManager.Return(qubits);
            }
        }
    }
    
    internal static class Extensions
    {
        public static IEnumerable<IEnumerable<T>> Chunks<T>(this IEnumerable<T> source, int chunkSize)
        {
            while (source.Any())
            {
                yield return source.Take(chunkSize);
                source = source.Skip(chunkSize);
            }
        }

        public static byte[] ToBytes(this BitArray array)
        {
            var dest = new byte[array.Length / 8 + (array.Length % 8 == 0 ? 0 : 1)];
            array.CopyTo(dest, 0);
            return dest;
        }

        private static void WriteHeader(Action<string> channel)
        {
            channel("Offset  \tState Data");
            channel("========\t==========");
        }

        public static void Dump(this bool[] data, Action<string> channel, int maxSizeForBitFormat = 32)
        {
            if (data.Length > maxSizeForBitFormat)
            {
                data.DumpAsHex(channel);
            }
            else
            {
                data.DumpAsBits(channel);
            }
        }

        public static void DumpAsHex(this bool[] data, Action<string> channel, int rowLength = 16)
        {
            WriteHeader(channel);
            var bytes = new BitArray(data).ToBytes();
            var offset = 0L;
            
            foreach (var row in bytes.Chunks(rowLength))
            {
                var hex = BitConverter.ToString(row.ToArray()).Replace("-", " ");
                channel($"{offset:x8}\t{hex}");
                offset += rowLength;
            }
        }

        public static void DumpAsBits(this bool[] data, Action<string> channel, int rowLength = 16)
        {
            WriteHeader(channel);
            var offset = 0;
            foreach (var row in data.Chunks(rowLength))
            {
                var bits = String.Join("", row.Select(bit => bit ? "1" : "0"));
                channel($"{offset / 8:x8}\t{bits}");
                offset += rowLength;
            }
        }
    }
}
