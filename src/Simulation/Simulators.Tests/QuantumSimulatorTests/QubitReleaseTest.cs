// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public partial class QuantumSimulatorTests
    {
        //test to check that qubit cannot be released if it is not in zero state
        [Fact]
        public async Task ZeroStateQubitReleaseTest()
        {
            var sim = new QuantumSimulator();

            await Assert.ThrowsAsync<ReleasedQubitsAreNotInZeroState>(() => UsingQubitCheck.Run(sim));
        }

        //test to check that qubit can be released if measured
        [Fact]
        public async Task MeasuredQubitReleaseTest()
        {
            var sim = new QuantumSimulator();

            //should not throw an exception, as Measured qubits are allowed to be released, and the release aspect is handled in the C++ code
            await ReleaseMeasuredQubitCheck.Run(sim);
        }
    }
}
