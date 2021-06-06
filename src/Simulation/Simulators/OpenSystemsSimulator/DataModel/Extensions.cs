// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text.Json;
using System.Collections.Generic;
using System.Linq;
using NumSharp;
using System;

namespace Microsoft.Quantum.Experimental
{
    internal delegate Func<TCompletion, TResult> ReaderContinuation<TCompletion, TResult>(ref Utf8JsonReader reader, string variant);
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
                // Try to read what it actually was.
                string? value = reader.TokenType switch
                {
                    JsonTokenType.String => reader.GetString(),
                    JsonTokenType.Number => reader.GetDecimal().ToString(),
                    JsonTokenType.True => "true",
                    JsonTokenType.False => "false",
                    JsonTokenType.Null => "null",
                    JsonTokenType.PropertyName => reader.GetString(),
                    _ => null
                };
                throw new JsonException($"Expected a JSON token of type {type}, got {reader.TokenType} instead.{(value == null ? "" : $"\nValue: {value}")}");
            }
        }
        public static bool IsComplexLike(this NDArray array) =>
            array.dtype == typeof(double) &&
            array.shape[^1] == 2;

        public static Func<TCompletion, TResult> Bind<TInput, TCompletion, TResult>(this TInput input, Func<TCompletion, TInput, TResult> action) =>
            (completion) => action(completion, input);

        internal static TResult ReadQubitSizedData<TResult>(this ref Utf8JsonReader reader, ReaderContinuation<int, TResult> readData)
        {
            
            reader.Require(JsonTokenType.StartObject, read: false);

            int? nQubits = null;
            Func<int, TResult>? completion = null;

            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndObject)
                {
                    // We're at the end of the object, and can break out of the
                    // read loop.
                    break;
                }

                // If it's not the end of the object, the current token needs
                // to be a property name.
                if (reader.TokenType != JsonTokenType.PropertyName)
                {
                    throw new JsonException();
                }

                var propertyName = reader.GetString();

                switch (propertyName)
                {
                    case "n_qubits":
                        reader.Read();
                        nQubits = reader.GetInt32();
                        break;

                    case "data":
                        // In most cases, we expect an object with one property
                        // indicating
                        // the kind of data for the object.
                        // For variants of type unit, it's just the string.
                        reader.Read();
                        if (reader.TokenType == JsonTokenType.StartObject)
                        {
                            reader.Require(JsonTokenType.PropertyName);
                            var kind = reader.GetString();

                            reader.Read();
                            completion = readData(ref reader, kind);

                            // Finally, require an end to the object.
                            reader.Require(JsonTokenType.EndObject);
                        }
                        else if (reader.TokenType == JsonTokenType.String)
                        {
                            var kind = reader.GetString();
                            completion = readData(ref reader, kind);
                        }
                        else
                        {
                            throw new JsonException($"Expected either the start of an object or a string.");
                        }
                        break;

                    default:
                        throw new JsonException($"Unexpected property name {propertyName}.");
                }
            }

            if (nQubits == null) throw new JsonException(nameof(nQubits));
            if (completion == null) throw new JsonException();

            return completion(nQubits.Value);
        }
    }
}
