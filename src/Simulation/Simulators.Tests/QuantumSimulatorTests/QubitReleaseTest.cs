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
        [Fact]
        public async Task ZeroStateQubitReleaseTest()
        {
            var sim = new QuantumSimulator();

            await Assert.ThrowsAsync<ReleasedQubitsAreNotInZeroState>(() => UsingQubitCheck.Run(sim));
        }

        [Fact]
        public async Task MeasuredQubitReleaseTest()
        {
            var sim = new QuantumSimulator();

            //should not throw an exception
            await UsingMeasuredQubitCheck.Run(sim);
        }
    }
}
