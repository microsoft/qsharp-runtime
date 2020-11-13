// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Microsoft.Quantum.Simulation.Core;

using NativeOperations;

using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class NativeOperationTests
    {
        [Fact]
        public void NativeIntrinsicOperation()
        {
            OperationsTestHelper.RunWithMultipleSimulators((sim) => 
            {
                var actual = IntrinsicBody.Run(sim).Result;
                Assert.Equal(IntrinsicBody.RESULT, actual);
            });
        }

        [Fact]
        public void NativeOperationWithSimulatorSpecificEmulation()
        {
            void TestOne(IOperationFactory sim, string expected)
            {
                var actual = DefaultBody.Run(sim).Result;
                Assert.Equal(expected, actual);

                if (sim is IDisposable dis) dis.Dispose();
            }

            TestOne(new QuantumSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics)), "Simulator");
            TestOne(new ToffoliSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics)), "Toffoli");
            TestOne(new ResourcesEstimator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics)), "hello");
        }

        [Fact]
        public void NativeIntrinsicGenericOperation()
        {
            OperationsTestHelper.RunWithMultipleSimulators((sim) =>
            {
                var actual = IntrinsicBodyGeneric<string>.Run(sim, "hello").Result;
                Assert.Equal(IntrinsicBody.RESULT, actual);

                actual = IntrinsicBodyGeneric<long>.Run(sim, 1234).Result;
                Assert.Equal("1234", actual);
            });
        }


        [Fact]
        public void NativeGenericOperation()
        {
            OperationsTestHelper.RunWithMultipleSimulators((sim) =>
            {
                var actual1 = DefaultBodyGeneric<string>.Run(sim, "hello").Result;
                Assert.Equal(IntrinsicBody.RESULT, actual1);

                var actual2 = DefaultBodyGeneric<long>.Run(sim, 1234).Result;
                Assert.Equal(1234, actual2);
            });
        }
    }
}
