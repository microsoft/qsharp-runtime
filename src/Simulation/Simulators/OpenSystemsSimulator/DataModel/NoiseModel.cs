// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Text.Json.Serialization;
using System.Diagnostics.CodeAnalysis;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Simulation.OpenSystems.DataModel;

// NB: To make this compatible with Newtonsoft.Json as well as
//     System.Text.Json, we use a Newtonsoft converter that delegates to
//     S.T.Json.
[Newtonsoft.Json.JsonConverter(typeof(DelegatedConverter<NoiseModel>))]
public record NoiseModel
{
    [JsonPropertyName("initial_state")]
    public State? InitialState { get; set; }

    [JsonPropertyName("cnot")]
    public Process? Cnot { get; set; }

    [JsonPropertyName("i")]
    public Process? I { get; set; }

    [JsonPropertyName("s")]
    public Process? S { get; set; }

    [JsonPropertyName("s_adj")]
    public Process? SAdj { get; set; }

    [JsonPropertyName("t")]
    public Process? T { get; set; }

    [JsonPropertyName("t_adj")]
    public Process? TAdj { get; set; }

    [JsonPropertyName("h")]
    public Process? H { get; set; }

    [JsonPropertyName("x")]
    public Process? X { get; set; }

    [JsonPropertyName("y")]
    public Process? Y { get; set; }

    [JsonPropertyName("z")]
    public Process? Z { get; set; }

    [JsonPropertyName("z_meas")]
    public Instrument? ZMeas { get; set; }

    [JsonPropertyName("rx")]
    public GeneratorCoset? Rx { get; set; }

    [JsonPropertyName("ry")]
    public GeneratorCoset? Ry { get; set; }

    [JsonPropertyName("rz")]
    public GeneratorCoset? Rz { get; set; }

    public static bool TryGetByName(string name, [NotNullWhen(true)] out NoiseModel? model)
    {
        try
        {
            model = OpenSystemsSimulatorNativeInterface.GetNoiseModelByName(name);
            return true;
        }
        catch (SimulationException)
        {
            model = null;
            return false;
        }
    }
}
