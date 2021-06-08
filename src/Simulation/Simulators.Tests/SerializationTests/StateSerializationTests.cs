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
    public class StateSerializationTests
    {
        [Fact]
        public void StabilizerStateSerializesCorrectly()
        {
            var state = new StabilizerState
            {
                NQubits = 2,
                Table = new StabilizerState.TableArray
                {
                    Data = new List<bool>
                    {
                        true, false, false, false, true, false
                    },
                    Dimensions = new List<int> { 2, 3 }
                }
            };
            var json = JsonSerializer.Serialize<Microsoft.Quantum.Experimental.State>(state);
            var expectedJson = @"{
                ""n_qubits"": 2,
                ""data"": {
                    ""Stabilizer"": {
                        ""n_qubits"": 2,
                        ""table"": {
                            ""v"": 1,
                            ""dim"": [2, 3],
                            ""data"": [true,false,false,false,true,false]
                        }
                    }
                }
            }";

            expectedJson.AssertJsonIsEqualTo(json);
        }

        [Fact]
        public void StabilizerArrayDeserializesCorrectly()
        {
            var expectedJson = @"
                {
                    ""v"": 1,
                    ""dim"": [2, 3],
                    ""data"": [true,false,false,false,true,false]
                }
            ";
            var reader = new Utf8JsonReader(System.Text.Encoding.UTF8.GetBytes(expectedJson));
            var array = JsonSerializer.Deserialize<StabilizerState.TableArray>(ref reader);
            var state = new StabilizerState
            {
                NQubits = 2,
                Table = array
            };
        }
    }
}
