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
using static System.Math;

namespace Microsoft.Quantum.Experimental
{
    public class ProcessConverter : JsonConverter<Process>
    {

        public override Process Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var (nQubits, kind, data) = ComplexArrayConverter.ReadQubitSizedArray(ref reader, options);
            return kind switch
            {
                "Unitary" => new UnitaryProcess(nQubits, data),
                "KrausDecomposition" => new KrausDecompositionProcess(nQubits, data),
                _ => throw new JsonException($"Unknown state kind {kind}.")
            };
        }

        public override void Write(Utf8JsonWriter writer, Process value, JsonSerializerOptions options)
        {
            var arrayConverter = new ComplexArrayConverter();

            writer.WriteStartObject();
                writer.WriteNumber("n_qubits", value.NQubits);

                writer.WritePropertyName("data");
                writer.WriteStartObject();
                    writer.WritePropertyName(
                        value switch
                        {
                            UnitaryProcess _ => "Unitary",
                            KrausDecompositionProcess _ => "KrausDecomposition",
                            _ => throw new JsonException()
                        }
                    );

                    arrayConverter.Write(writer, value.Data, options);
                writer.WriteEndObject();
            writer.WriteEndObject();
        }
    }

    [JsonConverter(typeof(ProcessConverter))]
    public abstract class Process
    {
        public int NQubits { get; }

        // NB: NDArray instances are mutable, but marking this as read-only
        //     means that the shape is at least fixed at initialization time.
        public NDArray Data { get; }

        internal Process(int nQubits, NDArray data)
        {
            NQubits = nQubits;
            Data = data;
        }
    }

    // TODO: Add class for mixed pauli processes as well.
    // public class MixedPauliProcess : Process
    // {
    // }

    public class UnitaryProcess : Process
    {
        public UnitaryProcess(int nQubits, NDArray data) : base(nQubits, data)
        {
            // Unitary matrices should be of dimension (2^n, 2^n, 2), with the last
            // index indicating real-vs-imag.
            var dim = (int) Pow(2, nQubits);
            if (data.shape.Length != 3 || data.shape[0] != dim || data.shape[1] != dim || data.shape[2] != 2)
            {
                throw new ArgumentException("Expected (2^nQubits, 2) array.", nameof(data));
            }
        }

        public override string ToString() =>
            $@"Unitary process on {NQubits} qubits: {Data.AsTextMatrixOfComplex(rowSep: " ")}";
    }
    public class KrausDecompositionProcess : Process
    {
        public KrausDecompositionProcess(int nQubits, NDArray data) : base(nQubits, data)
        {
            // Kraus decompositions should have between 1 and 4^n operators,
            // each of which should be 2^n by 2^n, for a final dims of
            // [k, 2^n, 2^n, 2] where 1 ≤ k ≤ 4^n.
            var dim = (int) Pow(2, nQubits);
            var superDim = dim * dim;

            if (data.shape.Length != 4 || data.shape[0] > superDim || data.shape[0] < 1
                                       || data.shape[1] != dim
                                       || data.shape[2] != dim
                                       || data.shape[3] != 2)
            {
                throw new ArgumentException("Expected (k, 2^nQubits, 2^nQubits, 2) array.", nameof(data));
            }
        }

        public override string ToString()
        {
            var ops = String.Join(",",
                Data.IterateOverLeftmostIndex()
                    .Select(op => op.AsTextMatrixOfComplex(rowSep: " "))
            );
            return $@"Kraus decomposition of process on {NQubits} qubits: {ops}";
        }
    }

}
