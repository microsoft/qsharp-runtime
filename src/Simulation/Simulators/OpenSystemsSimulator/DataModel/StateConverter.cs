// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text.Json;
using System.Text.Json.Serialization;
using NumSharp;
using Microsoft.Quantum.Simulation.Simulators;
namespace Microsoft.Quantum.Simulation.OpenSystems.DataModel;
public class StateConverter : JsonConverter<State>
{

    /*
        We expect JSON of the form:

            {
                "n_qubits": 1,
                "data": {
                    "Mixed": {
                        "v": 1,
                        "dim": [2, 2],
                        "data": [
                            [1, 0],
                            [0, 0],
                            [0, 0],
                            [0, 0]
                        ]
                    }
                }
            }

    Here, the presence of either $.data.Mixed or $.data.Pure tells us how
    to interpret data.
    */

    public override State Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        reader.Require(JsonTokenType.StartObject, readCurrent: false);

        var arrayConverter = new ComplexArrayConverter();
        return reader.ReadQubitSizedData<State>((ref Utf8JsonReader reader, string kind) =>
            kind switch
            {
                "Pure" => arrayConverter.Read(ref reader, typeof(NDArray), options).Bind(
                    (int nQubits, NDArray data) => new PureState(nQubits, data)
                ),
                "Mixed" => arrayConverter.Read(ref reader, typeof(NDArray), options).Bind(
                    (int nQubits, NDArray data) => new MixedState(nQubits, data)
                ),
                "Stabilizer" => JsonSerializer.Deserialize<StabilizerState>(ref reader).Bind(
                    (int nQubits, StabilizerState? state) =>
                    {
                        System.Diagnostics.Debug.Assert((state?.Data as object) != null);
                        System.Diagnostics.Debug.Assert(nQubits == state.NQubits);
                        return state;
                    }
                ),
                _ => throw new JsonException($"Unknown state kind {kind}.")
            }
        );
    }

    public override void Write(Utf8JsonWriter writer, State value, JsonSerializerOptions options)
    {
        try
        {
            using (writer.WriteObject())
            {
                writer.WriteNumber("n_qubits", value.NQubits);

                writer.WritePropertyName("data");
                using (writer.WriteObject())
                {
                    writer.WritePropertyName(
                        value switch
                        {
                            PureState _ => "Pure",
                            MixedState _ => "Mixed",
                            StabilizerState _ => "Stabilizer",
                            _ => throw new JsonException($"Unknown state type {value.GetType()}.")
                        }
                    );

                    if (value is ArrayState { Data: var data })
                    {
                        new ComplexArrayConverter().Write(writer, data, options);
                    }
                    else if (value is StabilizerState stabilizerState)
                    {
                        if (stabilizerState.Data is null)
                        {
                            throw new JsonException("Failure serializing stabilizer state as JSON: did not expect Data to be null.");
                        }
                        var array = new StabilizerState.TableArray(
                            Data: stabilizerState.Data.flat.ToArray<bool>().ToList(),
                            Dimensions: stabilizerState.Data.Shape.Dimensions.ToList()
                        );
                        using (writer.WriteObject())
                        {
                            writer.WritePropertyName("n_qubits");
                            writer.WriteNumberValue(stabilizerState.NQubits);
                            writer.WritePropertyName("table");
                            JsonSerializer.Serialize(writer, array);
                        }
                    }
                }
            }
        }
        finally
        {
            // Since there's a few places we can throw an exception here, we'll
            // make sure to flush in those cases.
            writer.Flush();
        }
    }
}
