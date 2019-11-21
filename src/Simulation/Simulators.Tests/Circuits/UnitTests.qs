// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Tests.QsUnitTests {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    @TestOperation("QuantumSimulator")
    @TestOperation("ToffoliSimulator")
    operation QsharpUnitTest() : Unit {
		Message("Worked!");
	}
    
}


