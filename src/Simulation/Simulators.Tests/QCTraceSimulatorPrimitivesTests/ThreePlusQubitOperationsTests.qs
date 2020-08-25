// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;

    operation ThreeQubitPlusOperationsWithControllsTest () : Unit {

        let paramFreeList = [
            (
                OnFirstThreeQubitsAC(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.CCNOT, _),
                OnFirstThreeQubitsAC(CCNOT, _)
            )
        ];

        for (i in 0 .. Length(paramFreeList) - 1) {
            let (actual, expected) = paramFreeList[i];
            ControlledOperationTester(actual, expected, 3, 5);
        }

        IterateThroughCartesianPower(3, 2, ExpTester);
        IterateThroughCartesianPower(4, 2, ExpTester);
    }

}
