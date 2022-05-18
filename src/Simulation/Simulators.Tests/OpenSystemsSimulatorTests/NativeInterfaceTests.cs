// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests;

public partial class NativeInterfaceTests
{
    [Fact]
    public void GetIdealNoiseModelByNameWorks()
    {
        var ideal = OpenSystemsSimulatorNativeInterface.GetNoiseModelByName("ideal");
        // TODO(cgranade): Add assertions here to check properties of the above noise model.
    }

    [Fact]
    public void GetIdealStabilizerNoiseModelByNameWorks()
    {
        var idealStabilizer = OpenSystemsSimulatorNativeInterface.GetNoiseModelByName("ideal_stabilizer");
        // TODO: Add assertions here to check properties of each noise model.
    }

    [Fact]
    public void GetNoiseModelByNameThrowsExceptionForInvalidNames()
    {
        Assert.Throws<SimulationException>(() => {
            OpenSystemsSimulatorNativeInterface.GetNoiseModelByName("invalid");
        });
    }

}