// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.Json;
using Microsoft.Quantum.Experimental;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json.Linq;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class ProcessSerializationTests
    {
        [Fact]
        public void MixedPauliSerializesCorrectly()
        {
            var mixedPauli = new MixedPauliProcess(
                1,
                new List<(double, IList<Pauli>)>
                {
                    (0.9, new List<Pauli> { Pauli.PauliI }),
                    (0.1, new List<Pauli> { Pauli.PauliX }),
                }
            );
            var actualJson = JsonSerializer.Serialize<Process>(mixedPauli);
            @"{
                ""n_qubits"": 1,
                ""data"": {
                    ""MixedPauli"": [
                        [0.9, [""I""]],
                        [0.1, [""X""]]
                    ]
                }
            }".AssertJsonIsEqualTo(actualJson);
        }

        [Fact]
        public void MixedPauliRoundTripsCorrectly()
        {
            var mixedPauli = new MixedPauliProcess(
                1,
                new List<(double, IList<Pauli>)>
                {
                    (0.9, new List<Pauli> { Pauli.PauliI }),
                    (0.1, new List<Pauli> { Pauli.PauliX }),
                }
            );
            var expectedJson = JsonSerializer.Serialize<Process>(mixedPauli);
            var actualJson = JsonSerializer.Serialize(JsonSerializer.Deserialize<Process>(expectedJson));
            expectedJson.AssertJsonIsEqualTo(actualJson);
        }

        [Fact]
        public void CnotSerializesCorrectly()
        {
            var cnot = new ChpOperation.Cnot
            {
                IdxControl = 0,
                IdxTarget = 1
            };
            var json = JsonSerializer.Serialize<ChpOperation>(cnot);
            var expectedJson = @"{
                ""Cnot"": [0, 1]
            }";

            expectedJson.AssertJsonIsEqualTo(json);
        }

        [Fact]
        public void HadamardSerializesCorrectly()
        {
            var h = new ChpOperation.Hadamard
            {
                IdxTarget = 1
            };
            var json = JsonSerializer.Serialize<ChpOperation>(h);
            var expectedJson = @"{
                ""Hadamard"": 1
            }";

            expectedJson.AssertJsonIsEqualTo(json);
        }

        [Fact]
        public void PhaseSerializesCorrectly()
        {
            var s = new ChpOperation.Phase
            {
                IdxTarget = 1
            };
            var json = JsonSerializer.Serialize<ChpOperation>(s);
            var expectedJson = @"{
                ""Phase"": 1
            }";

            expectedJson.AssertJsonIsEqualTo(json);
        }

        [Fact]
        public void AdjointPhaseSerializesCorrectly()
        {
            var sAdj = new ChpOperation.AdjointPhase
            {
                IdxTarget = 1
            };
            var json = JsonSerializer.Serialize<ChpOperation>(sAdj);
            var expectedJson = @"{
                ""AdjointPhase"": 1
            }";

            expectedJson.AssertJsonIsEqualTo(json);
        }
    }
}
