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
    public class InstrumentConverter : JsonConverter<Instrument>
    {
        public override Instrument Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            // We use the technique at
            //     https://stackoverflow.com/questions/58074304/is-polymorphic-deserialization-possible-in-system-text-json/59744873#59744873
            // to implement polymorphic deserialization, based on the property name.
            reader.Require(JsonTokenType.StartObject, read: false);
            reader.Require(JsonTokenType.PropertyName);

            var variant = reader.GetString();

            var result = variant switch
            {
                "Effects" => new EffectsInstrument
                {
                    Effects = JsonSerializer.Deserialize<List<Process>>(ref reader)
                },
                _ => throw new JsonException($"Enum variant {variant} not yet supported.")
            };

            reader.Require(JsonTokenType.EndObject);

            return result;
        }

        public override void Write(Utf8JsonWriter writer, Instrument value, JsonSerializerOptions options)
        {
            writer.WriteStartObject();

            switch (value)
            {
                case EffectsInstrument effectsInstrument:
                    writer.WritePropertyName("Effects");
                    JsonSerializer.Serialize(writer, effectsInstrument.Effects);
                    break;

                default:
                    throw new JsonException($"Enum variant {value.GetType()} not yet supported.");
            }

            writer.WriteEndObject();
        }
    }

    [JsonConverter(typeof(InstrumentConverter))]
    public abstract class Instrument
    {

    }

    public class EffectsInstrument : Instrument
    {
        [JsonPropertyName("effects")]
        public IList<Process> Effects { get; set; } = new List<Process>();

        public override string ToString() =>
            $"Instrument {{ Effects = {String.Join(", ", Effects.Select(effect => effect.ToString()))} }}";
    }
}
