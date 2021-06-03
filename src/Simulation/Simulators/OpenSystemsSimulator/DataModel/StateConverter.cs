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
            var (nQubits, kind, data) = ComplexArrayConverter.ReadQubitSizedArray(ref reader, options);
            return kind switch
            {
                "Pure" => new PureState(nQubits, data),
                "Mixed" => new MixedState(nQubits, data),
                // TODO: read tableaus here.
                _ => throw new JsonException($"Unknown state kind {kind}.")
            };
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

                    arrayConverter.Write(writer, value.Data, options);
                writer.WriteEndObject();
            writer.WriteEndObject();
        }
    }

}
