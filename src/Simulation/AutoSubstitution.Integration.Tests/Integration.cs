// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Simulators;
using Xunit;

namespace Microsoft.Quantum.AutoSubstitution.Testing
{
    public class CodeGenerationTests
    {
        [Fact]
        public void CanSimulateWithAlternativeSimulator()
        {
            var sim = new ToffoliSimulator();
            TestQuantumSwap.Run(sim).Wait();
        }
    }
}
