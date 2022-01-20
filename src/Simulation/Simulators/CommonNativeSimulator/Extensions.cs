// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation
{

    public static partial class Extensions
    {
        /// <summary>
        /// Returns the ids of a qubit array as a uint[]
        /// </summary>
        public static uint[] GetIds(this IQArray<Qubit> qubits)
        {
            Debug.Assert(qubits != null, "Can't get Ids from a null array of qubits");
            if (qubits == null) { return new uint[0]; }

            return (from q in qubits where q != null select (uint)q.Id).ToArray();
        }

        /// <summary>
        ///  Automatically identifies and registers a Type's BuiltIn operations. 
        ///  It recursively checks on this and its BaseType for all NestedTypes that are
        ///  a subclass of T and registers as the override of the BaseType 
        ///  it implements.
        /// </summary>
        public static void InitBuiltinOperations<T>(this Factory<T> factory, Type t)
        {
            if (t == null)
            {
                return;
            }

            InitBuiltinOperations(factory, t.BaseType);

            var overrideTypes = t.GetNestedTypes(
                System.Reflection.BindingFlags.Public | 
                System.Reflection.BindingFlags.NonPublic);

            var ops =
                from op in overrideTypes
                where op.IsSubclassOf(typeof(T))
                select op;

            foreach (var op in ops)
            {
                factory.Register(op.BaseType, op);
            }
        }

        internal static long NextLongBelow(this System.Random random, long upperExclusive)
        {
            // Don't allow sampling non-positive numbers, so that we don't break
            // Math.Log2.
            if (upperExclusive <= 0)
            {
                throw new ArgumentException(
                    $"Must be positive, got {upperExclusive}.",
                    nameof(upperExclusive)
                );
            }
            long SampleNBits(int nBits)
            {
                // Note that we can assume that nBytes is never more than 8,
                // since we got there by looking at the bit length of
                // upperExclusive, which is itself a 64-bit integer.
                var nBytes = (nBits + 7) / 8;
                var nExcessBits = nBytes * 8 - nBits;
                var bytes = new byte[nBytes];
                random.NextBytes(bytes);
                
                // ToInt64 requires an array of exactly eight bytes.
                // We can use IsLittleEndian to check which side we
                // need to pad on to get there.
                var padded = new byte[8];
                bytes.CopyTo(padded,
                    // ToInt64 requires an array of exactly eight bytes.
                    // We can use IsLittleEndian to check which side we
                    // need to pad on to get there.
                    System.BitConverter.IsLittleEndian
                    ? 0
                    : 8 - nBytes
                );
                return System.BitConverter.ToInt64(padded) >> nExcessBits;
            };
            
            var nBits = (int) (System.Math.Log(upperExclusive, 2) + 1);
            var sample = SampleNBits(nBits);
            while (sample >= upperExclusive)
            {
                sample = SampleNBits(nBits);
            }
            return sample;
        }

        internal static long NextLong(this System.Random random, long lower, long upper)
        {
            var delta = upper - lower;
            return lower + random.NextLongBelow(delta + 1);
        }

    }
}
