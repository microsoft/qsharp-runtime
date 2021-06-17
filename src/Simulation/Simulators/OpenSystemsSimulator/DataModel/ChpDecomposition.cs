// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Microsoft.Quantum.Experimental
{

    public class ChpOperationConverter : JsonConverter<ChpOperation>
    {
        public override ChpOperation Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            reader.Require(JsonTokenType.StartObject, read: false);
            reader.Require(JsonTokenType.PropertyName);
            ChpOperation? operation = null;
            ulong idx;
            switch (reader.GetString())
            {
                case "Cnot":
                    var idxs = JsonSerializer.Deserialize<List<ulong>>(ref reader);
                    operation = new ChpOperation.Cnot
                    {
                        IdxControl = idxs[0],
                        IdxTarget = idxs[1]
                    };
                    break;

                case "Hadamard":
                    reader.Read();
                    idx = reader.GetUInt64();
                    operation = new ChpOperation.Hadamard
                    {
                        IdxTarget = idx
                    };
                    break;

                case "Phase":
                    reader.Read();
                    idx = reader.GetUInt64();
                    operation = new ChpOperation.Phase
                    {
                        IdxTarget = idx
                    };
                    break;

                case "AdjointPhase":
                    reader.Read();
                    idx = reader.GetUInt64();
                    operation = new ChpOperation.AdjointPhase
                    {
                        IdxTarget = idx
                    };
                    break;
            }
            if (operation == null)
            {
                throw new JsonException("Did not read an operation.");
            }
            reader.Require(JsonTokenType.EndObject);
            return operation;
        }

        public override void Write(Utf8JsonWriter writer, ChpOperation value, JsonSerializerOptions options)
        {
            writer.WriteStartObject();
                writer.WritePropertyName(
                    value switch
                    {
                        ChpOperation.Cnot _ => "Cnot",
                        ChpOperation.Hadamard _ => "Hadamard",
                        ChpOperation.Phase _ => "Phase",
                        ChpOperation.AdjointPhase _ => "AdjointPhase",
                        _ => throw new JsonException()
                    }
                );
                if (value is ChpOperation.Cnot cnot)
                {
                    writer.WriteStartArray();
                        writer.WriteNumberValue(cnot.IdxControl);
                        writer.WriteNumberValue(cnot.IdxTarget);
                    writer.WriteEndArray();
                }
                else
                {
                    writer.WriteNumberValue(
                        value switch
                        {
                            ChpOperation.AdjointPhase { IdxTarget: var target } => target,
                            ChpOperation.Phase { IdxTarget: var target } => target,
                            ChpOperation.Hadamard { IdxTarget: var target } => target,
                            _ => throw new JsonException()
                        }
                    );
                }
            writer.WriteEndObject();
        }
    }

    [JsonConverter(typeof(ChpOperationConverter))]
    public abstract class ChpOperation
    {
        private ChpOperation()
        { }

        public class Cnot : ChpOperation
        {
            public ulong IdxControl { get; set; }
            public ulong IdxTarget { get; set; }
        }
        
        public class Hadamard : ChpOperation
        {
            public ulong IdxTarget { get; set; }
        }

        public class Phase : ChpOperation
        {
            public ulong IdxTarget { get; set; }
        }

        public class AdjointPhase : ChpOperation
        {
            public ulong IdxTarget { get; set; }
        }
    }

}