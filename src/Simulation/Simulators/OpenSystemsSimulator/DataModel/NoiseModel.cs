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
    // NB: To make this compatible with Newtonsoft.Json as well as
    //     System.Text.Json, we use a Newtonsoft converter that delegates to
    //     S.T.Json.
    [Newtonsoft.Json.JsonConverter(typeof(DelegatedConverter<NoiseModel>))]
    public class NoiseModel
    {
        [JsonPropertyName("initial_state")]
        public State? InitialState { get; set; }

        [JsonPropertyName("cnot")]
        public Channel? Cnot { get; set; }

        [JsonPropertyName("i")]
        public Channel? I { get; set; }

        [JsonPropertyName("s")]
        public Channel? S { get; set; }

        [JsonPropertyName("s_adj")]
        public Channel? SAdj { get; set; }

        [JsonPropertyName("t")]
        public Channel? T { get; set; }

        [JsonPropertyName("t_adj")]
        public Channel? TAdj { get; set; }

        [JsonPropertyName("h")]
        public Channel? H { get; set; }

        [JsonPropertyName("x")]
        public Channel? X { get; set; }

        [JsonPropertyName("y")]
        public Channel? Y { get; set; }

        [JsonPropertyName("z")]
        public Channel? Z { get; set; }

        [JsonPropertyName("z_meas")]
        public Instrument? ZMeas { get; set; }

        public static NoiseModel Ideal => NativeInterface.IdealNoiseModel();
    }
}
