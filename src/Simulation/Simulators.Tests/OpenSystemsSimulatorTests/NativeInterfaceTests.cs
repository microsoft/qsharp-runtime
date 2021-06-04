// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Xunit;

namespace Microsoft.Quantum.Experimental
{
    public partial class NativeInterfaceTests
    {
        [Fact]
        public void GetNoiseModelByNameWorks()
        {
            var ideal = NativeInterface.GetNoiseModelByName("ideal");
            var idealStabilizer = NativeInterface.GetNoiseModelByName("ideal_stabilizer");
            // TODO: Add assertions here to check properties of each noise model.
        }

        [Fact]
        public void GetNoiseModelByNameThrowsExceptionForInvalidNames()
        {
            Assert.Throws<SimulationException>(() => {
                NativeInterface.GetNoiseModelByName("invalid");
            });
        }

    }
}