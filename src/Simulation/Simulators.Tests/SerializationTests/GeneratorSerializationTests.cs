// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Text.Json;
using Microsoft.Quantum.Experimental;
using NumSharp;

namespace Microsoft.Quantum.Simulation.Simulators.Tests;

public record class GeneratorSerializationTests(ITestOutputHelper Output)
{
    [Fact]
    public void GeneratorSerializesCorrectly()
    {
        var hz = new ExplicitEigenvalueDecomposition(
            NQubits: 1,
            Eigenvalues: np.array(new[] {new[] {1.0, 0.0}, new[] {-1.0, 0.0}}),
            Eigenvectors: np.array(new[] {new[] {new[] {1.0, 0.0}, new[] {0.0, 0.0}}, new[] {new[] {0.0, 0.0}, new[] {1.0, 0.0}}})
        );
        var json = JsonSerializer.Serialize<Generator>(hz);
        var expectedJson = @"{
            ""n_qubits"": 1,
            ""data"": {
                ""ExplicitEigenvalueDecomposition"": {
                    ""values"": {
                        ""v"": 1,
                        ""dim"": [2],
                        ""data"": [
                            [1, 0],
                            [-1, 0]
                        ]
                    },
                    ""vectors"": {
                        ""v"": 1,
                        ""dim"": [2, 2],
                        ""data"": [
                            [1, 0], [0, 0],
                            [0, 0], [1, 0]
                        ]
                    }
                }
            }
        }";

        expectedJson.AssertJsonIsEqualTo(json);
    }

}
