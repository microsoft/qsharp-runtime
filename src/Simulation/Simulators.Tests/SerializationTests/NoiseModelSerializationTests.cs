// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Text;
using System.Text.Json;
using Microsoft.Quantum.Experimental;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json.Linq;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.Simulators.Tests;

public record class NoiseModelSerializationTests(ITestOutputHelper Output)
{
    private const string idealJson = @"{""cnot"":{""data"":{""Unitary"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0]],""dim"":[4,4],""v"":1}},""n_qubits"":2},""h"":{""data"":{""Unitary"":{""data"":[[0.7071067811865476,0.0],[0.7071067811865476,0.0],[0.7071067811865476,0.0],[-0.7071067811865476,-0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""i"":{""data"":{""Unitary"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""initial_state"":{""data"":{""Mixed"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""rx"":{""generator"":{""data"":{""ExplicitEigenvalueDecomposition"":{""values"":{""data"":[[-0.5,0.0],[0.5,-0.0]],""dim"":[2],""v"":1},""vectors"":{""data"":[[0.7071067811865476,0.0],[0.7071067811865476,0.0],[0.7071067811865476,0.0],[-0.7071067811865476,0.0]],""dim"":[2,2],""v"":1}}},""n_qubits"":1}},""ry"":{""generator"":{""data"":{""ExplicitEigenvalueDecomposition"":{""values"":{""data"":[[-0.5,0.0],[0.5,-0.0]],""dim"":[2],""v"":1},""vectors"":{""data"":[[0.7071067811865476,0.0],[0.0,0.7071067811865476],[0.7071067811865476,0.0],[0.0,-0.7071067811865476]],""dim"":[2,2],""v"":1}}},""n_qubits"":1}},""rz"":{""generator"":{""data"":{""ExplicitEigenvalueDecomposition"":{""values"":{""data"":[[-0.5,0.0],[0.5,-0.0]],""dim"":[2],""v"":1},""vectors"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]],""dim"":[2,2],""v"":1}}},""n_qubits"":1}},""s"":{""data"":{""Unitary"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,1.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""s_adj"":{""data"":{""Unitary"":{""data"":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.0,-1.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""t"":{""data"":{""Unitary"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.7071067811865476,0.7071067811865476]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""t_adj"":{""data"":{""Unitary"":{""data"":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.7071067811865476,-0.7071067811865476]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""x"":{""data"":{""Unitary"":{""data"":[[0.0,0.0],[1.0,0.0],[1.0,0.0],[0.0,0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""y"":{""data"":{""Unitary"":{""data"":[[0.0,0.0],[-0.0,-1.0],[0.0,1.0],[0.0,0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""z"":{""data"":{""Unitary"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[-1.0,-0.0]],""dim"":[2,2],""v"":1}},""n_qubits"":1},""z_meas"":{""Effects"":[{""data"":{""KrausDecomposition"":{""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]],""dim"":[1,2,2],""v"":1}},""n_qubits"":1},{""data"":{""KrausDecomposition"":{""data"":[[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]],""dim"":[1,2,2],""v"":1}},""n_qubits"":1}]}}";

    [Fact]
    public void IdealNoiseModelDeserializes()
    {
        var idealNoiseModel = JsonSerializer.Deserialize<NoiseModel>(idealJson);

        // Assert some stuff about the ideal noise model to make sure we got it right.
        idealNoiseModel.ZMeas.AssertTypeAnd<EffectsInstrument>(instrument =>
        {
            Assert.Equal(2, instrument.Effects.Count);
        });
        idealNoiseModel.Z.AssertTypeAnd<UnitaryProcess>(process =>
        {
            Assert.Equal(1, process.NQubits);
        });
    }

    [Fact]
    public void IdealNoiseModelRoundTrips()
    {
        var idealNoiseModel = (
            NoiseModel.TryGetByName("ideal", out var model)
            ? model
            : throw new Exception("Failed to get noise model by name.")
        );
        idealNoiseModel.AssertSerializationRoundTrips(Output);
    }

    [Fact]
    public void IdealStabilizerNoiseModelRoundTrips()
    {
        var idealStabilizerModel = (
            NoiseModel.TryGetByName("ideal_stabilizer", out var model)
            ? model
            : throw new Exception("Could not get noise model by name.")
        );
        idealStabilizerModel.AssertSerializationRoundTrips(Output);
    }
}
