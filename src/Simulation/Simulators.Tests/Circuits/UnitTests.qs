// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    @Test("QuantumSimulator")
    @Test("ToffoliSimulator")
    @Test("ResourcesEstimator")
    operation QSharpUnitTest() : Unit {
		Message("Worked!");
	}
        
    @Test("QuantumSimulator")
    @Test("Microsoft.Quantum.Simulation.Simulators.Tests.TrivialSimulator")
    @Test("Microsoft.Quantum.Simulation.Simulators.Tests.ModifiedTrivialSimulator")
    @Test("Microsoft.Quantum.Simulation.Simulators.Tests.UnitTests.TrivialSimulator")
    operation ArbitraryUnitTestTarget() : Unit {
		Message("Worked!");
	}
    
}

