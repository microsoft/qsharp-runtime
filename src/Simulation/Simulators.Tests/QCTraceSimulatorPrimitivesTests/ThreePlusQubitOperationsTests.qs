// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Simulation.TestSuite.Math;

    operation ThreeQubitPlusOperationsWithControllsTest () : Unit {

        let paramFreeList = [
            (
                OnFirstThreeQubitsAC(_Decomposer_CCNOT, _),
                OnFirstThreeQubitsAC(CCNOT, _)
            )
        ];

        for ((actual, expected) in paramFreeList) {
            ControlledOperationTester(actual, expected, 3, 5);
        }

        //TODO: rethinking testing scope to optimize execution time
        IterateThroughCartesianPower(3, NumberOfPaulies(), ExpTester);
        IterateThroughCartesianPower(4, NumberOfPaulies() - 1, ExpTester);
    }

}
