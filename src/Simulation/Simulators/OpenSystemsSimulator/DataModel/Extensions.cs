// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text.Json;
using System.Collections.Generic;
using System.Linq;
using NumSharp;

namespace Microsoft.Quantum.Experimental
{
    internal static class Extensions
    {
        internal static bool HasProperty(this JsonElement element, string propertyName) =>
            element.TryGetProperty(propertyName, out var _);

        internal static string AsLaTeXMatrixOfComplex(this NDArray array) =>
            // NB: Assumes 𝑛 × 𝑛 × 2 array, where the trailing index is
            //     [real, imag].
            // TODO: Consolidate with logic at:
            //       https://github.com/microsoft/QuantumLibraries/blob/505fc27383c9914c3e1f60fb63d0acfe60b11956/Visualization/src/DisplayableUnitaryEncoders.cs#L43
            string.Join(
                "\\\\\n",
                Enumerable
                    .Range(0, array.Shape[0])
                    .Select(
                        idxRow => string.Join(" & ",
                            Enumerable
                                .Range(0, array.Shape[1])
                                .Select(
                                    idxCol => $"{array[idxRow, idxCol, 0]} + {array[idxRow, idxCol, 1]} i"
                                )
                        )
                    )
            );

        internal static IEnumerable<NDArray> IterateOverLeftmostIndex(this NDArray array)
        {
            foreach (var idx in Enumerable.Range(0, array.shape[0]))
            {
                yield return array[idx, Slice.Ellipsis];
            }
        }

        internal static string AsTextMatrixOfComplex(this NDArray array, string rowSep = "\n") =>
            // NB: Assumes 𝑛 × 𝑛 × 2 array, where the trailing index is
            //     [real, imag].
            // TODO: Consolidate with logic at:
            //       https://github.com/microsoft/QuantumLibraries/blob/505fc27383c9914c3e1f60fb63d0acfe60b11956/Visualization/src/DisplayableUnitaryEncoders.cs#L43
            "[" + rowSep + string.Join(
                rowSep,
                Enumerable
                    .Range(0, array.Shape[0])
                    .Select(
                        idxRow => "[" + string.Join(", ",
                            Enumerable
                                .Range(0, array.Shape[1])
                                .Select(
                                    idxCol => $"{array[idxRow, idxCol, 0]} + {array[idxRow, idxCol, 1]} i"
                                )
                        ) + "]"
                    )
            ) + rowSep + "]";

        public static void Require(this ref Utf8JsonReader reader, JsonTokenType type, bool read = true)
        {
            if (read) reader.Read();
            if (reader.TokenType != type)
            {
                throw new JsonException($"Expected a JSON token of type {type}, got {reader.TokenType} instead.");
            }
        }
        public static bool IsComplexLike(this NDArray array) =>
            array.dtype == typeof(double) &&
            array.shape[^1] == 2;
    }
}
