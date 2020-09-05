// Copyright (c) Microsoft Corporation. All rights reserved.
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
            sim.Register(typeof(Tests.Circuits.Generics.Trace<>), typeof(TraceImpl<>), typeof(IUnitary));

            // For Toffoli, replace H with I.
            if (sim is ToffoliSimulator)
            {
                sim.Register(typeof(Intrinsic.H), typeof(Intrinsic.I), typeof(IUnitary));
            }
        }

        public static void RunWithMultipleSimulators(Action<SimulatorBase> test)
        {
            var simulators = new SimulatorBase[] { new QuantumSimulator(), new ToffoliSimulator() };

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