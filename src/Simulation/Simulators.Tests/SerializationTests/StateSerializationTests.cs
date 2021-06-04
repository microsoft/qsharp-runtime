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
            var state = new StabilizerState(1, new StabilizerState.TableArray
            {
                Data = new List<bool>
                {
                    true, false, false, false, true, false
                },
                Dimensions = new List<int> { 2, 3 }
            });
            var json = JsonSerializer.Serialize(state);
            var expectedJson = @"{
                ""n_qubits"": 1,
                ""data"": {
                    ""Stabilizer"": {
                        ""n_qubits"": 1,
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
    }
}
