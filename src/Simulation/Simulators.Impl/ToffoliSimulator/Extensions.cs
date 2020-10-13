// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

namespace Microsoft.Quantum.Simulation.Simulators
{
    internal static class Extensions
    {
        public static IEnumerable<IEnumerable<T>> Chunks<T>(this IEnumerable<T> source, int chunkSize)
        {
            if (source == null) { throw new NullReferenceException(nameof(source)); }
            while (source.Any())
            {
                yield return source.Take(chunkSize);
                source = source.Skip(chunkSize);
            }
        }

        public static byte[] ToBytes(this BitArray array)
        {
            if (array == null) { throw new NullReferenceException(nameof(array)); }
            var dest = new byte[array.Length / 8 + (array.Length % 8 == 0 ? 0 : 1)];
            array.CopyTo(dest, 0);
            return dest;
        }

        private static void WriteHeader(Action<string> channel)
        {
            if (channel == null) { throw new NullReferenceException(nameof(channel)); }
            channel("Offset  \tState Data");
            channel("========\t==========");
        }

        public static void Dump(this bool[] data, Action<string> channel, int maxSizeForBitFormat = 32)
        {
            if (data == null) { throw new NullReferenceException(nameof(data)); }
            if (channel == null) { throw new NullReferenceException(nameof(channel)); }
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
            if (data == null) { throw new NullReferenceException(nameof(data)); }
            if (channel == null) { throw new NullReferenceException(nameof(channel)); }
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
            if (data == null) { throw new NullReferenceException(nameof(data)); }
            if (channel == null) { throw new NullReferenceException(nameof(channel)); }
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