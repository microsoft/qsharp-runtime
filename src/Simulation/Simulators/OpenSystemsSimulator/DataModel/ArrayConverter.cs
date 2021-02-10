// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Serialization;
using NumSharp;

namespace Microsoft.Quantum.Experimental
{
    /// <summary>
    ///     Converts <see cref="NDArray" /> instances of dtype <c>double</c>
    ///     and with a trailing index of length 2 to and from a JSON
    ///     serialization.
    /// </summary>
    /// <remarks>
    ///   <para>    
    ///     The JSON representation consumed and produced by this converter is
    ///     compatible with the representation used by Rust's <c>ndarray</c>
    ///     and <c>serde</c> crates.
    ///   </para>
    ///   <para>
    ///     In particular, each JSON object produced by this converter has
    ///     three properties:
    ///   </para>
    ///   <list type="bullet">
    ///     <item><c>"v"</c>: Indicates the <c>ndarray</c> format version being
    ///       being used. Always <c>1</c> for this implementation.</item>
    ///     <item><c>"dim"</c>: Lists the dimensions of the array being
    ///       serialized. Will always contain one less dimension than the
    ///       original array, as one dimension represents the real and imaginary
    ///       components of each element.
    ///     <item><c>"data"</c>: Lists the elements of the array, with the
    ///       right-most dimension varying the fastest (defined by <c>ndarray</c>
    ///       as "logical order", and by NumPy as "C-ordered").
    ///   </list>
    /// </remarks>
    public class ComplexArrayConverter : JsonConverter<NDArray>
    {
        public override NDArray Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            // By the end, we need to have read "v", "dim", and "data".
            int? version = null;
            List<int>? dims = null;
            List<Complex>? data = null;

            // We require that the reader be in the right state to read an
            // object.
            if (reader.TokenType != JsonTokenType.StartObject)
            {
                throw new JsonException();
            }

            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndObject)
                {
                    // We're at the end of the array, and can break out of the
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
                    case "v":
                        reader.Read();
                        version = reader.GetInt32();
                        break;

                    case "dim":
                        dims = new List<int>();
                        reader.Require(JsonTokenType.StartArray);
                        while (reader.Read() && reader.TokenType != JsonTokenType.EndArray)
                        {
                            dims.Add(reader.GetInt32());
                        }
                        break;

                    case "data":
                        data = new List<Complex>();
                        reader.Require(JsonTokenType.StartArray);

                        while (reader.Read() && reader.TokenType != JsonTokenType.EndArray)
                        {
                            // We expect an inner array at this point, so
                            // go on and read the begin array token.
                            reader.Require(JsonTokenType.StartArray, read: false);

                            reader.Read();
                            var real = reader.GetDouble();

                            reader.Read();
                            var imag = reader.GetDouble();

                            reader.Require(JsonTokenType.EndArray);

                            data.Add(new Complex(real, imag));
                        }
                        break;

                    default:
                        throw new JsonException();
                }
            }

            // At this point, none of version, dims, or data should be null.
            if (version == null) throw new JsonException(nameof(version));
            if (dims == null) throw new JsonException(nameof(dims));
            if (data == null) throw new JsonException(nameof(data));

            // We now know we have everything we need to make the new array.
            // In doing so, we allocate an ndarray with of shape (nElements, 2)
            // where the last index represents real-vs-imag. We'll reshape
            // it to the correct shape at the end.
            var array = np.zeros((data.Count, 2));
            foreach (var idx in Enumerable.Range(0, data.Count))
            {
                var element = data[idx];
                array[idx, 0] = element.Real;
                array[idx, 1] = element.Imaginary;
            }
            return np.reshape(array, dims.Concat(new [] { 2 }).ToArray());
        }

        public override void Write(Utf8JsonWriter writer, NDArray value, JsonSerializerOptions options)
        {
            // Before proceeding, check that `value` is complex-like. That is,
            // that `value` is of dtype double, and has a trailing dimension
            // of length 2.
            if (!value.IsComplexLike())
            {
                throw new ArgumentException($"Cannot serialize ndarray, as it is not complex-like: {value}");
            }

            writer.WriteStartObject();
                writer.WriteNumber("v", 1);

                writer.WritePropertyName("dim");
                writer.WriteStartArray();
                    foreach (var dim in value.shape[0..^1])
                    {
                        writer.WriteNumberValue(dim);
                    }
                writer.WriteEndArray();

                writer.WritePropertyName("data");
                writer.WriteStartArray();
                    // By default, NumSharp reshapes in C-order, matching
                    // ndarray's logical ordering. Thus, we reshape down to
                    // a two-axis array, and loop over the left most axis
                    // (corresponding to elements of the serialized array),
                    // leaving the second axis (corresponding to
                    // real-vs-imag).
                    var nElements = value.shape[0..^1].Aggregate((acc, dim) => acc * dim);
                    var flattened = value.reshape((nElements, 2));
                    foreach (var idx in Enumerable.Range(0, flattened.shape[0]))
                    {
                        var element = flattened[idx];
                        // Each element is a JSON array `[real, imag]`.
                        writer.WriteStartArray();
                            writer.WriteNumberValue((double) element[0]);
                            writer.WriteNumberValue((double) element[1]);
                        writer.WriteEndArray();
                    }
                writer.WriteEndArray();
            writer.WriteEndObject();
        }

        public static (int nQubits, string kind, NDArray data) ReadQubitSizedArray(ref Utf8JsonReader reader, JsonSerializerOptions options)
        {

            var arrayConverter = new ComplexArrayConverter();
            int? nQubits = null;
            NDArray? data = null;
            string? kind = null;

            // We require that the reader be in the right state to read an
            // object.
            if (reader.TokenType != JsonTokenType.StartObject)
            {
                throw new JsonException();
            }

            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndObject)
                {
                    // We're at the end of the array, and can break out of the
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
                        // Here, we expect an object with one property indicating
                        // the kind of state. The value of that property can
                        // be read using the complexarrayconverter from above.
                        reader.Require(JsonTokenType.StartObject);
                        reader.Require(JsonTokenType.PropertyName);
                        kind = reader.GetString();

                        // Advance the reader onto the array itself and use
                        // the converter.
                        reader.Read();
                        data = arrayConverter.Read(ref reader, typeof(NDArray), options);

                        // Finally, require an end to the object.
                        reader.Require(JsonTokenType.EndObject);
                        break;

                    default:
                        throw new JsonException($"Unexpected property name {propertyName}.");
                }
            }

            if (nQubits == null) throw new JsonException(nameof(nQubits));
            if (data == null) throw new JsonException(nameof(data));
            if (kind == null) throw new JsonException(nameof(kind));

            return (nQubits.Value, kind!, data!);
        }
    }
}
