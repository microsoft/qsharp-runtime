// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Quantum.Simulation.Simulators;
using NumSharp;

// Qualify this import so that Process does not collide with the DataModel
// definition.
using Debug = System.Diagnostics.Debug;

namespace Microsoft.Quantum.Simulation.OpenSystems.DataModel;

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
        reader.Require(JsonTokenType.StartObject, readCurrent: false);
        var arrayConverter = new ComplexArrayConverter();
        return reader.ReadQubitSizedData<Generator>((ref Utf8JsonReader reader, string kind) =>
        {
            switch (kind)
            {
                case "Unsupported":
                    return (int nQubits) => new UnsupportedGenerator(nQubits);

                case "ExplicitEigenvalueDecomposition":
                    NDArray? eigenvectors = null;
                    NDArray? eigenvalues = null;

                    while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
                    {

                        // If it's not the end of the object, the current token needs
                        // to be a property name.
                        if (reader.TokenType != JsonTokenType.PropertyName)
                        {
                            throw new JsonException();
                        }

                        var propertyName = reader.GetString();
                        reader.Read();

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
                                throw reader.CurrentState.Exception($"Unknown property {propertyName}.");
                        }

                    }

                    if (eigenvalues == null)
                    {
                        throw reader.CurrentState.Exception($"Generator kind was ExplicitEigenvalueDecomposition, but no eigenvalues were provided.");
                    }
                    Debug.Assert(eigenvalues is not null);

                    if (eigenvectors == null)
                    {
                        throw reader.CurrentState.Exception($"Generator kind was ExplicitEigenvalueDecomposition, but no eigenvectors were provided.");
                    }
                    Debug.Assert(eigenvectors is not null);

                    return (int nQubits) => new ExplicitEigenvalueDecomposition(nQubits, eigenvalues, eigenvectors);

                default:
                    throw reader.CurrentState.Exception($"Unknown generator kind {kind}.");
            }
        });
    }

    public override void Write(Utf8JsonWriter writer, Generator value, JsonSerializerOptions options)
    {
        var arrayConverter = new ComplexArrayConverter();

        using (writer.WriteObject())
        {
            writer.WriteNumber("n_qubits", value.NQubits);

            writer.WritePropertyName("data");
            if (value is ExplicitEigenvalueDecomposition eig)
            {
                using (writer.WriteObject())
                {
                    writer.WritePropertyName("ExplicitEigenvalueDecomposition");
                    using (writer.WriteObject())
                    {
                        writer.WritePropertyName("values");
                        arrayConverter.Write(writer, eig.Eigenvalues, options);
                        writer.WritePropertyName("vectors");
                        arrayConverter.Write(writer, eig.Eigenvectors, options);
                    }
                }
            }
            else if (value is UnsupportedGenerator _)
            {
                writer.WriteStringValue("Unsupported");
            }
            else
            {
                throw new JsonException($"Object of type {value.GetType()} is not a valid generator.");
            }
        }
    }
}
