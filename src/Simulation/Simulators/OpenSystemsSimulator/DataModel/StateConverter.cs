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
            reader.Require(JsonTokenType.StartObject, read: false);

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
                        (int nQubits, StabilizerState state) =>
                        {
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
            var arrayConverter = new ComplexArrayConverter();

            writer.WriteStartObject();
                writer.WriteNumber("n_qubits", value.NQubits);

                writer.WritePropertyName("data");
                writer.WriteStartObject();
                    writer.WritePropertyName(
                        value switch
                        {
                            PureState _ => "Pure",
                            MixedState _ => "Mixed",
                            _ => throw new JsonException()
                        }
                    );

                    if (value is ArrayState { Data: var data })
                    {
                        arrayConverter.Write(writer, data, options);
                    }
                    else if (value is StabilizerState stabilizerState)
                    {
                        var array = new StabilizerState.TableArray
                        {
                            Data = stabilizerState.Data.flat.ToArray<bool>().ToList(),
                            Dimensions = stabilizerState.Data.Shape.Dimensions.ToList()
                        };
                        JsonSerializer.Serialize(writer, array);
                    }
                writer.WriteEndObject();
            writer.WriteEndObject();
        }
    }

}
