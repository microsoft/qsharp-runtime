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
        private static IList<(double, IList<Pauli>)> ReadMixedPauliData(ref Utf8JsonReader reader)
        {
            var results = new List<(double, IList<Pauli>)>();
            reader.Require(JsonTokenType.StartArray, read: false);
            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndArray)
                {
                    break;
                }

                reader.Require(JsonTokenType.StartArray, read: false);
                reader.Read();
                var p = reader.GetDouble();
                var ops = new List<Pauli>();
                reader.Require(JsonTokenType.StartArray);
                while (reader.Read())
                {
                    if (reader.TokenType == JsonTokenType.EndArray)
                    {
                        break;
                    }

                    ops.Add(reader.GetString() switch
                    {
                        "I" => Pauli.PauliI,
                        "X" => Pauli.PauliX,
                        "Y" => Pauli.PauliY,
                        "Z" => Pauli.PauliZ,
                        var unknown => throw new JsonException($"Expected I, X, Y, or Z for a Pauli value, but got {unknown}.")
                    });
                }
                reader.Require(JsonTokenType.EndArray);

                results.Add((p, ops));
            }
            return results;
        }

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
                    "MixedPauli" => ReadMixedPauliData(ref reader).Bind(
                        (int nQubits, IList<(double, IList<Pauli>)> data) => new MixedPauliProcess(nQubits, data)
                    ),
                    "Sequence" => JsonSerializer.Deserialize<IList<Process>>(ref reader).Bind(
                        (int nQubits, IList<Process> processes) => new SequenceProcess(nQubits, processes)
                    ),
                    "ChpDecomposition" => JsonSerializer.Deserialize<IList<ChpOperation>>(ref reader).Bind(
                        (int nQubits, IList<ChpOperation> operations) => new ChpDecompositionProcess(nQubits, operations)
                    ),
                    "Unsupported" => (null as object).Bind(
                        (int nQubits, object? _) => new UnsupportedProcess(nQubits)
                    ),
                    _ => throw new JsonException($"Process kind {kind} not supported for deserialization.")
                }
            );
        }

        public override void Write(Utf8JsonWriter writer, Process value, JsonSerializerOptions options)
        {
            var arrayConverter = new ComplexArrayConverter();

            writer.WriteStartObject();
                writer.WriteNumber("n_qubits", value.NQubits);

                writer.WritePropertyName("data");
                if (value is UnsupportedProcess)
                {
                    writer.WriteStringValue("Unsupported");
                }
                else
                {
                    writer.WriteStartObject();
                        writer.WritePropertyName(
                            value switch
                            {
                                UnitaryProcess _ => "Unitary",
                                KrausDecompositionProcess _ => "KrausDecomposition",
                                MixedPauliProcess _ => "MixedPauli",
                                SequenceProcess _ => "Sequence",
                                ChpDecompositionProcess _ => "ChpDecomposition",
                                _ => throw new JsonException()
                            }
                        );

                        if (value is ArrayProcess { Data: var data })
                        {
                            arrayConverter.Write(writer, data, options);
                        }
                        else if (value is MixedPauliProcess mixedPauliProcess)
                        {
                            writer.WriteStartArray();
                            foreach (var op in mixedPauliProcess.Operators)
                            {
                                writer.WriteStartArray();
                                    writer.WriteNumberValue(op.Item1);
                                    writer.WriteStartArray();
                                    foreach (var p in op.Item2)
                                    {
                                        writer.WriteStringValue(p switch
                                        {
                                            Pauli.PauliI => "I",
                                            Pauli.PauliX => "X",
                                            Pauli.PauliY => "Y",
                                            Pauli.PauliZ => "Z",
                                            var unknown => throw new JsonException($"Unexpected Pauli value {unknown}.")
                                        });
                                    }
                                    writer.WriteEndArray();
                                writer.WriteEndArray();
                            }
                            writer.WriteEndArray();
                        }
                        else if (value is ChpDecompositionProcess chpDecomposition)
                        {
                            JsonSerializer.Serialize(writer, chpDecomposition.Operations);
                        }
                        else if (value is SequenceProcess sequence)
                        {
                            JsonSerializer.Serialize(writer, sequence.Processes);
                        }
                    writer.WriteEndObject();
                }
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

    public class MixedPauliProcess : Process
    {
        public IList<(double, IList<Pauli>)> Operators;

        internal MixedPauliProcess(int nQubits, IList<(double, IList<Pauli>)> operators) : base(nQubits)
        {
            this.Operators = operators;
        }
    }

    public class ChpDecompositionProcess : Process
    {
        public IList<ChpOperation> Operations;

        internal ChpDecompositionProcess(int nQubits, IList<ChpOperation> operations) : base(nQubits)
        {
            this.Operations = operations;
        }
    }

    public class SequenceProcess : Process
    {
        public IList<Process> Processes;

        internal SequenceProcess(int nQubits, IList<Process> processes) : base(nQubits)
        {
            this.Processes = processes;
        }
    }

    public class UnsupportedProcess : Process
    {
        internal UnsupportedProcess(int nQubits) : base(nQubits)
        { }
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
