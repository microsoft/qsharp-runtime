// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Quantum.Simulation.Core;
using NumSharp;
using static System.Math;

namespace Microsoft.Quantum.Experimental
{
    public class ProcessConverter : JsonConverter<Process>
    {
        public override Process Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            reader.Require(JsonTokenType.StartObject, read: false);

            var arrayConverter = new ComplexArrayConverter();
            return reader.ReadQubitSizedData<Process>((ref Utf8JsonReader reader, string kind) =>
                kind switch
                {
                    "Unitary" => arrayConverter.Read(ref reader, typeof(NDArray), options).Bind(
                        (int nQubits, NDArray data) => new UnitaryProcess(nQubits, data)
                    ),
                    "KrausDecomposition" => arrayConverter.Read(ref reader, typeof(NDArray), options).Bind(
                        (int nQubits, NDArray data) => new KrausDecompositionProcess(nQubits, data)
                    ),
                    "MixedPauli" => JsonSerializer.Deserialize<IList<(double, IList<Pauli>)>>(ref reader).Bind(
                        (int nQubits, IList<(double, IList<Pauli>)> data) => new MixedPauliProcess(nQubits, data)
                    ),
                    _ => throw new JsonException()
                }
            );
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
                            MixedPauliProcess _ => "MixedPauli",
                            _ => throw new JsonException()
                        }
                    );

                    if (value is ArrayProcess { Data: var data })
                    {
                        arrayConverter.Write(writer, data, options);
                    }
                    else if (value is MixedPauliProcess mixedPauliProcess)
                    {
                        JsonSerializer.Serialize(writer, mixedPauliProcess.Operators);
                    }
                writer.WriteEndObject();
            writer.WriteEndObject();
        }
    }

    [JsonConverter(typeof(ProcessConverter))]
    public abstract class Process
    {
        [JsonPropertyName("n_qubits")]
        public int NQubits { get; }

        internal Process(int nQubits)
        {
            NQubits = nQubits;
        }
    }

    public abstract class ArrayProcess : Process
    {
        [JsonPropertyName("data")]
        public NDArray Data { get; }

        internal ArrayProcess(int nQubits, NDArray data) : base(nQubits)
        {
            this.Data = data;
        }
    }

    // TODO: Add class for mixed pauli processes as well.
    public class MixedPauliProcess : Process
    {
        public IList<(double, IList<Pauli>)> Operators;

        internal MixedPauliProcess(int nQubits, IList<(double, IList<Pauli>)> operators) : base(nQubits)
        {
            this.Operators = operators;
        }
    }

    public class UnitaryProcess : ArrayProcess
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
    public class KrausDecompositionProcess : ArrayProcess
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
