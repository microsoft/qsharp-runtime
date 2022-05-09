// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Experimental.Tests;

public partial class NativeInterfaceTests
{
    [Fact]
    public void GetIdealNoiseModelByNameWorks()
    {
        var ideal = NativeInterface.GetNoiseModelByName("ideal");
        // TODO: Add assertions here to check properties of the above noise model.
    }

    [Fact]
    public void GetIdealStabilizerNoiseModelByNameWorks()
    {
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