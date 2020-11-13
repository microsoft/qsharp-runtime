// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests
{
    public class CircuitTests
    {
        private readonly ITestOutputHelper output;

        public CircuitTests(ITestOutputHelper output)
        {
            this.output = output;
        }

        private static Action GetTest<T>( IOperationFactory sim  ) where T : AbstractCallable, ICallable<QVoid, QVoid>
        {
            return () => sim.Get<ICallable<QVoid, QVoid>, T>().Apply(QVoid.Instance);
        }

        [Fact]
        public void DistinctQubitsTests()
        {
            QCTraceSimulator sim = new QCTraceSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics), new QCTraceSimulatorConfiguration() { UseDistinctInputsChecker = true } );
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCapturedTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured2Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured3Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured4Test>(sim));
        }

        [Fact]
        public void UseReleasedQubitsTests()
        {
            QCTraceSimulator sim = new QCTraceSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics), new QCTraceSimulatorConfiguration() { UseInvalidatedQubitsUseChecker = true });
            Assert.Throws<InvalidatedQubitsUseCheckerException>(GetTest<UseReleasedQubitTest>(sim));
        }

        [Fact]
        public void CatStateTestsCore()
        {
            for (int i = 1; i < 11; ++i)
            {
                CatStateTestCore<CatStateCore>(i);
            }
            //CatStateTestCore<CatStatePrep>(20);
        }

        [Fact]
        public void CatStateTestsPrimitives()
        {
            for (int i = 1; i < 11; ++i)
            {
                CatStateTestCore<CatState>(i);
            }
            //CatStateTestCore<Circuits.CatState>(20);
        }

        [Fact]
        public void SimpleMeasurement()
        {
            var sim = GetTraceSimForMetrics();
            GetTest<SimpleMeasurementTest>(sim)();
        }

        [Fact]
        public void SwappedMeasurement()
        {
            var sim = GetTraceSimForMetrics();
            GetTest<SwappedMeasurementTest>(sim)();
        }

        [Fact]
        public void ForcedMeasuremenet()
        {
            var sim = GetTraceSimForMetrics();
            GetTest<ForcedMeasurementTest>(sim)();
        }

        [Fact]
        public void AllocatedConstraint()
        {
            var sim = GetTraceSimForMetrics();
            GetTest<AllocatedConstraintTest>(sim)();
        }

        [Fact]
        public void MeausermentPreverseConstraint()
        {
            var sim = GetTraceSimForMetrics();
            GetTest<MeausermentPreverseConstraintTest>(sim)();
        }

        [Fact]
        public void UnconstrainedMeasurement()
        {
            var sim = GetTraceSimForMetrics();
            Assert.Throws<UnconstrainedMeasurementException>(GetTest<UnconstrainedMeasurement1Test>(sim));
            Assert.Throws<UnconstrainedMeasurementException>(GetTest<UnconstrainedMeasurement2Test>(sim));
        }

        void CatStateTestCore<TCatState>( int powerOfTwo ) where TCatState : AbstractCallable, ICallable<long,QVoid>
        {
            Debug.Assert(powerOfTwo > 0);

            double CXTime = 5;
            double HTime = 1;

            QCTraceSimulatorConfiguration traceSimCfg = new QCTraceSimulatorConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = CXTime;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.QubitClifford] = HTime;

            QCTraceSimulator traceSim = new QCTraceSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics), traceSimCfg);

            output.WriteLine(string.Empty);
            output.WriteLine($"Starting cat state preparation on {1u << powerOfTwo} qubits");
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            traceSim.Run<TCatState, long, QVoid>(powerOfTwo).Wait();
            stopwatch.Stop();

            double cxCount = traceSim.GetMetric<TCatState>(PrimitiveOperationsGroupsNames.CNOT);
            Assert.Equal( (1 << powerOfTwo) - 1, (long) cxCount);

            double depth = traceSim.GetMetric<TCatState>(DepthCounter.Metrics.Depth );
            Assert.Equal(HTime + powerOfTwo * CXTime, depth);

            void AssertEqualMetric( double value, string metric )
            {
                Assert.Equal(value, traceSim.GetMetric<TCatState>(metric));
            }

            AssertEqualMetric(1u << powerOfTwo, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.BorrowedWith);
            AssertEqualMetric(0, WidthCounter.Metrics.InputWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.ReturnWidth);

            output.WriteLine($"Calculation of metrics took: {stopwatch.ElapsedMilliseconds} ms");
            output.WriteLine($"The depth is: {depth} given depth of CNOT was {CXTime} and depth of H was {HTime}");
            output.WriteLine($"Number of CNOTs used is {cxCount}");
        }

        QCTraceSimulator GetTraceSimForMetrics()
        {
            QCTraceSimulatorConfiguration traceSimCfg = new QCTraceSimulatorConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = 1;
            return new QCTraceSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics), traceSimCfg);
        }

        [Fact]
        public void ThreeCNOTs()
        {
            QCTraceSimulator sim = GetTraceSimForMetrics();
            GetTest<ThreeCNOTsTest>(sim)();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, sim.GetMetric<ThreeCNOTsTest>(metric));
            }
            AssertEqualMetric(3, DepthCounter.Metrics.Depth);
            AssertEqualMetric(3, PrimitiveOperationsGroupsNames.CNOT);
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);

            Dictionary<string, string> csvRes = sim.ToCSV();
            foreach ( KeyValuePair<string,string> kv in csvRes )
            {
                output.WriteLine($"Result of running {kv.Key} are:");
                output.WriteLine(kv.Value);
            }
        }

        [Fact]
        public void TwoCNOTs()
        {
            QCTraceSimulator sim = GetTraceSimForMetrics();
            GetTest<TwoCNOTsTest>(sim)();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, sim.GetMetric<TwoCNOTsTest>(metric));
            }
            AssertEqualMetric(2, DepthCounter.Metrics.Depth);
            AssertEqualMetric(2, PrimitiveOperationsGroupsNames.CNOT);
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);
        }

    }
}
