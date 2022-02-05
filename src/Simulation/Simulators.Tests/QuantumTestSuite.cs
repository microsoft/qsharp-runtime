// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.XUnit;
using System;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class QuantumTestSuite
    {
        private readonly ITestOutputHelper output;

        public QuantumTestSuite(ITestOutputHelper output)
        {
            this.output = output;
        }

        [OperationDriver(TestCasePrefix = "QSim:", TestNamespace = "Microsoft.Quantum.Simulation.TestSuite")]
        public void QSimTestTarget(TestOperation op)
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true),
                new SparseSimulator(throwOnReleasingQubitsNotInZeroState: true)
            };

            foreach (var sim in simulators)
            {
                try
                {
                    sim.OnLog += (msg) => { output.WriteLine(msg); };
                    op.TestOperationRunner(sim);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        //[OperationDriver(TestCasePrefix = "QSim:", TestNamespace = "Microsoft.Quantum.Simulation.TestSuite.VeryLong")]
        private void QSimTestTargetVeryLong(TestOperation op)
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true),
                new SparseSimulator(throwOnReleasingQubitsNotInZeroState: true)
            };

            foreach (var sim in simulators)
            {
                try
                {
                    sim.OnLog += (msg) => { output.WriteLine(msg); };
                    op.TestOperationRunner(sim);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        //[OperationDriver(TestCasePrefix = "⊗ Fail QSim:", TestNamespace = "Microsoft.Quantum.Simulation.TestSuite", Suffix = "QSimFail")]
        [OperationDriver(TestCasePrefix = "⊗ Fail QSim:", TestNamespace = "Microsoft.Quantum.Simulation.TestSuite", Suffix = "QSimFail", Skip = "These tests are known to fail" )]
        public void QSimTestTargetFailures(TestOperation op)
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true),
                new SparseSimulator(throwOnReleasingQubitsNotInZeroState: true)
            };

            foreach (var sim in simulators)
            {
                try
                {
                    sim.OnLog += (msg) => { output.WriteLine(msg); };
                    Action action = () => op.TestOperationRunner(sim);
                    bool hasThrown = false;
                    try
                    {
                        action.IgnoreDebugAssert();
                    }
                    catch (ExecutionFailException)
                    {
                        hasThrown = true;
                    }
                    Assert.True(hasThrown, "The operation was known to throw. It does not throw anymore. Congratulations ! You fixed the bug.");
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }
    }

    public class QuantumTestSuiteSelf
    {
        private readonly ITestOutputHelper output;
        public QuantumTestSuiteSelf(ITestOutputHelper output)
        {
            this.output = output;
        }

        [OperationDriver(TestCasePrefix = "QuantumTestSuite:", TestNamespace = "Microsoft.Quantum.Simulation.TestSuite.SelfTests")]
        public void QuantumTestSuiteSelfTests(TestOperation op)
        {
            var sim = new TrivialSimulator(); //these tests do not do anything quantum
            sim.OnLog += (msg) => { output.WriteLine(msg); };
            op.TestOperationRunner(sim);
        }
    }
}
