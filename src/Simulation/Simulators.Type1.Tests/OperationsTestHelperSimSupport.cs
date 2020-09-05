// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    static partial class OperationsTestHelper
    {
        private static void InitSimulator(SimulatorBase sim)
        {
            sim.InitBuiltinOperations(typeof(OperationsTestHelper));
        }

        public static void RunWithMultipleSimulators(Action<SimulatorBase> test)
        {
            var simulators = new SimulatorBase[] { new QuantumSimulator() };

            foreach (var s in simulators)
            {
                InitSimulator(s);

                test(s);

                if (s is IDisposable sim)
                {
                    sim.Dispose();
                }
            }
        }
    }
}
