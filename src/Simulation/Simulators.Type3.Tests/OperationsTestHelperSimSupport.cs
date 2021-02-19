// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    static partial class OperationsTestHelper
    {
        public static bool ShouldPerformQubitUniquenessTest = false;

        private static void InitSimulator(SimulatorBase sim)
        {
            sim.InitBuiltinOperations(typeof(OperationsTestHelper));
        }

        public static void RunWithMultipleSimulators(Action<SimulatorBase> test)
        {
            var simulators = new SimulatorBase[] { new QuantumSimulator() };

            foreach (var s in simulators)
            {
                try
                {
                    InitSimulator(s);

                    test(s);
                }
                finally
                {
                    if (s is IDisposable sim)
                    {
                        sim.Dispose();
                    }
                }
            }
        }
    }
}