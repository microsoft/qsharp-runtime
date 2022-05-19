// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Text.Json;
using DataModel = Microsoft.Quantum.Simulation.OpenSystems.DataModel;

namespace Microsoft.Quantum.Simulation.Simulators.Tests;

public class StateSerializationTests
{
    [Fact]
    public void StabilizerStateSerializesCorrectly()
    {
        var state = new DataModel.StabilizerState
        {
            NQubits = 2,
            Table = new DataModel.StabilizerState.TableArray(
                Data: new List<bool>
                {
                    true, false, false, false, true, false
                },
                Dimensions: new List<int> { 2, 3 }
            )
        };
        var json = JsonSerializer.Serialize<DataModel.State>(state);
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
        var array = JsonSerializer.Deserialize<DataModel.StabilizerState.TableArray>(ref reader).AsArray;
        Assert.Equal(new[] { 2, 3 }, array.Shape.Dimensions);
        Assert.Equal<bool>(true, array[0, 0]);
        Assert.Equal<bool>(false, array[0, 1]);
        Assert.Equal<bool>(false, array[0, 2]);
        Assert.Equal<bool>(false, array[1, 0]);
        Assert.Equal<bool>(true, array[1, 1]);
        Assert.Equal<bool>(false, array[1, 2]);
    }
}
