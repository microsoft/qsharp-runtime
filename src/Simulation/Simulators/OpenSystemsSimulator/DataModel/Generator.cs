// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Serialization;
using NumSharp;
using static System.Math;

namespace Microsoft.Quantum.Experimental;

public record class GeneratorCoset(
    [property: JsonPropertyName("pre")]
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    Process? Pre,

    [property: JsonPropertyName("post")]
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    Process? Post,

    [property: JsonPropertyName("generator")]
    Generator Generator 
);

[JsonConverter(typeof(GeneratorConverter))]
public abstract record class Generator(
    int NQubits = 1
);

public record class ExplicitEigenvalueDecomposition(
    int NQubits,
    NDArray Eigenvalues,
    NDArray Eigenvectors
) : Generator(NQubits);

public record class UnsupportedGenerator(
    int NQubits
) : Generator(NQubits);

public class GeneratorConverter : JsonConverter<Generator>
{
    public override Generator Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        reader.Require(JsonTokenType.StartObject, read: false);
        var arrayConverter = new ComplexArrayConverter();
        return reader.ReadQubitSizedData<Generator>((ref Utf8JsonReader reader, string kind) =>
        {
            switch (kind)
            {
                case "Unsupported":
                    return (int nQubits) => new UnsupportedGenerator(nQubits);

                case "ExplicitEigenvalueDecomposition":
                    reader.Require(JsonTokenType.StartObject, read: true);
                    NDArray? eigenvectors = null;
                    NDArray? eigenvalues = null;

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
                            case "vectors":
                                eigenvectors = arrayConverter.Read(
                                    ref reader, typeof(NDArray), options
                                );
                                break;

                            case "values":
                                eigenvalues = arrayConverter.Read(
                                    ref reader, typeof(NDArray), options
                                );
                                break;

                            default:
                                throw new JsonException($"Unknown property {propertyName}.");
                        }

                    }

                    if (eigenvalues == null)
                    {
                        throw new JsonException($"Generator kind was ExplicitEigenvalueDecomposition, but no eigenvalues were provided.");
                    }
                    Debug.Assert(eigenvalues != null);

                    if (eigenvectors == null)
                    {
                        throw new JsonException($"Generator kind was ExplicitEigenvalueDecomposition, but no eigenvectors were provided.");
                    }
                    Debug.Assert(eigenvectors != null);

                    return (int nQubits) => new ExplicitEigenvalueDecomposition(nQubits, eigenvalues, eigenvectors);

                default:
                    throw new JsonException($"Unknown generator kind {kind}.");
            }
        });
    }

    public override void Write(Utf8JsonWriter writer, Generator value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}
