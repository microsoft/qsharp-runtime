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

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    internal static class SerializationExtensions
    {
        internal static void AssertTypeAnd<T>(this object obj, Action<T> then)
        {
            if (obj is not T t)
            {
                Assert.IsType<T>(obj);
            }
            else
            {
                then(t);
            }
        }

        internal static string Serialize(this JsonDocument document)
        {
            var stream = new MemoryStream();
            var writer = new Utf8JsonWriter(stream);
            document.WriteTo(writer);
            return Encoding.UTF8.GetString(stream.ToArray());
        }

        internal static void AssertJsonIsEqualTo(this string expectedJson, string actualJson)
        {
            // To get a stable text representation, we first parse both strings to JsonDocument
            // objects, then re-serialize them. This avoids numerical precision issues in
            // JToken.DeepEquals, and allows for highlighting diffs more easily.
            var expectedNormalized = JsonDocument.Parse(expectedJson).Serialize();
            var actualNormalized = JsonDocument.Parse(actualJson).Serialize();
            Assert.Equal(expectedNormalized, actualNormalized);
        }
    }

    public class NoiseModelSerializationTests
    {
        private const string idealJson = @"{""initial_state"":{""n_qubits"":1,""data"":{""Mixed"":{""v"":1,""dim"":[2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]]}}},""i"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]]}}},""x"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[0.0,0.0],[1.0,0.0],[1.0,0.0],[0.0,0.0]]}}},""y"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[0.0,0.0],[0.0,1.0],[-0.0,-1.0],[0.0,0.0]]}}},""z"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[-1.0,-0.0]]}}},""h"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[0.7071067811865476,0.0],[0.7071067811865476,0.0],[0.7071067811865476,0.0],[-0.7071067811865476,-0.0]]}}},""s"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,1.0]]}}},""s_adj"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.0,-1.0]]}}},""t"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.7071067811865476,0.7071067811865476]]}}},""t_adj"":{""n_qubits"":1,""data"":{""Unitary"":{""v"":1,""dim"":[2,2],""data"":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.7071067811865476,-0.7071067811865476]]}}},""cnot"":{""n_qubits"":2,""data"":{""Unitary"":{""v"":1,""dim"":[4,4],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0]]}}},""z_meas"":{""Effects"":[{""n_qubits"":1,""data"":{""KrausDecomposition"":{""v"":1,""dim"":[1,2,2],""data"":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]]}}},{""n_qubits"":1,""data"":{""KrausDecomposition"":{""v"":1,""dim"":[1,2,2],""data"":[[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]]}}}]}}";

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
            var idealNoiseModel = JsonSerializer.Deserialize<NoiseModel>(idealJson);
            var roundtripJson = JsonSerializer.Serialize(idealNoiseModel);

            idealJson.AssertJsonIsEqualTo(roundtripJson);
        }
    }
}
