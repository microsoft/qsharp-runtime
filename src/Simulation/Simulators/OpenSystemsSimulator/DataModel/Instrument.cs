// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Immutable;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Microsoft.Quantum.Experimental;

public class InstrumentConverter : JsonConverter<Instrument>
{
    public override Instrument Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        // We use the technique at
        //     https://stackoverflow.com/questions/58074304/is-polymorphic-deserialization-possible-in-system-text-json/59744873#59744873
        // to implement polymorphic deserialization, based on the property name.
        reader.Require(JsonTokenType.StartObject, readCurrent: false);
        reader.Require(JsonTokenType.PropertyName);

        var variant = reader.GetString();
        if (variant is null)
        {
            throw reader.CurrentState.Exception("Instrument variant name was null.");
        }

        Instrument result = variant switch
        {
            "Effects" => new EffectsInstrument
            {
                Effects = JsonSerializer
                    .Deserialize<List<Process>>(ref reader)
                    .ToImmutableList()
            },
            "ZMeasurement" =>
                JsonSerializer.Deserialize<ZMeasurementInstrument>(ref reader)
                is {} zMeas
                ? zMeas
                : throw reader.CurrentState.Exception("Failed to deserialize Z measurement instrument."),
            _ => throw reader.CurrentState.Exception($"Enum variant {variant} not yet supported.")
        };

        reader.Require(JsonTokenType.EndObject);

        return result;
    }

    public override void Write(Utf8JsonWriter writer, Instrument value, JsonSerializerOptions options)
    {

        switch (value)
        {
            case EffectsInstrument effectsInstrument:
                writer.WriteStartObject();
                writer.WritePropertyName("Effects");
                JsonSerializer.Serialize(writer, effectsInstrument.Effects);
                writer.WriteEndObject();
                break;

            case ZMeasurementInstrument zInstrument:
                writer.WriteStartObject();
                writer.WritePropertyName("ZMeasurement");
                JsonSerializer.Serialize(writer, zInstrument);
                writer.WriteEndObject();
                break;

            default:
                throw new JsonException($"Enum variant {value.GetType()} not yet supported.");
        }

    }
}

[JsonConverter(typeof(InstrumentConverter))]
public abstract record Instrument
{

}

public record EffectsInstrument : Instrument
{
    [JsonPropertyName("effects")]
    public IImmutableList<Process> Effects { get; init; } = ImmutableList<Process>.Empty;

    public override string ToString() =>
        $"Instrument {{ Effects = {String.Join(", ", Effects.Select(effect => effect.ToString()))} }}";
}

public record ZMeasurementInstrument : Instrument
{
    [JsonPropertyName("pr_readout_error")]
    public double PrReadoutError { get; init; } = 0.0;

    public override string ToString() =>
        $"Instrument {{ Z measurement with readout error = {PrReadoutError} }}";
}
