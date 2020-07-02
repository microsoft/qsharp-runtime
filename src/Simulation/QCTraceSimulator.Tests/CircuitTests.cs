// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using NewTracer;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using Xunit;
using Xunit.Abstractions;
using DistinctInputsCheckerException = NewTracer.DistinctInputsCheckerException;
using InvalidatedQubitsUseCheckerException = NewTracer.InvalidatedQubitsUseCheckerException;
using UnconstrainedMeasurementException = NewTracer.UnconstrainedMeasurementException;

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
            //QCTraceSimulator sim = new QCTraceSimulator( new QCTraceSimulatorConfiguration() { UseDistinctInputsChecker = true } );
            var sim = GetTraceSimForMetrics(out _); //TODO: configuration
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCapturedTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured2Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured3Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured4Test>(sim));
        }

        [Fact]
        public void UseReleasedQubitsTests()
        {
            var sim = GetTraceSimForMetrics(out _);
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
            var sim = GetTraceSimForMetrics(out _);
            GetTest<SimpleMeasurementTest>(sim)();
        }

        [Fact]
        public void SwappedMeasurement()
        {
            var sim = GetTraceSimForMetrics(out _);
            GetTest<SwappedMeasurementTest>(sim)();
        }

        [Fact]
        public void ForcedMeasuremenet()
        {
            var sim = GetTraceSimForMetrics(out _);
            GetTest<ForcedMeasurementTest>(sim)();
        }

        [Fact]
        public void AllocatedConstraint()
        {
            var sim = GetTraceSimForMetrics(out _);
            GetTest<AllocatedConstraintTest>(sim)();
        }

        [Fact]
        public void MeausermentPreverseConstraint()
        {
            var sim = GetTraceSimForMetrics(out _);
            GetTest<MeausermentPreverseConstraintTest>(sim)();
        }

        [Fact]
        public void UnconstrainedMeasurement()
        {
            var sim = GetTraceSimForMetrics(out _);
            Assert.Throws<UnconstrainedMeasurementException>(GetTest<UnconstrainedMeasurement1Test>(sim));
            Assert.Throws<UnconstrainedMeasurementException>(GetTest<UnconstrainedMeasurement2Test>(sim));
        }

        void CatStateTestCore<TCatState>( int powerOfTwo ) where TCatState : AbstractCallable, ICallable<long,QVoid>
        {
            Debug.Assert(powerOfTwo > 0);

            double CXTime = 5;
            double HTime = 1;

            /*QCTraceSimulatorConfiguration traceSimCfg = new QCTraceSimulatorConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = CXTime;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.QubitClifford] = HTime;

            QCTraceSimulator traceSim = new QCTraceSimulator(traceSimCfg);*/
            //TODO: configure

            //TODO: rethink results extraction

            var traceSim = GetTraceSimForMetrics(out NewTracerCore tracerCore);

            output.WriteLine(string.Empty);
            output.WriteLine($"Starting cat state preparation on {1u << powerOfTwo} qubits");
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            traceSim.Run<TCatState, long, QVoid>(powerOfTwo).Wait();
            stopwatch.Stop();
            var results = tracerCore.ExtractCurrentResults();

            double cxCount = results.GetOperationMetric<TCatState>(PrimitiveOperationsGroupsNames.CNOT);
            Assert.Equal( (1 << powerOfTwo) - 1, (long) cxCount);

            double depth = results.GetOperationMetric<TCatState>(DepthCounter.Metrics.Depth );
            Assert.Equal(HTime + powerOfTwo * CXTime, depth);

            void AssertEqualMetric( double value, string metric )
            {
                Assert.Equal(value, results.GetOperationMetric<TCatState>(metric));
            }

            AssertEqualMetric(1u << powerOfTwo, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.BorrowedWith);
            AssertEqualMetric(0, WidthCounter.Metrics.InputWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.ReturnWidth);

            output.WriteLine($"Calculation of metrics took: {stopwatch.ElapsedMilliseconds} ms");
            output.WriteLine($"The depth is: {depth} given depth of CNOT was {CXTime} and depth of H was {HTime}");
            output.WriteLine($"Number of CNOTs used is {cxCount}");
        }

        SimulatorBase GetTraceSimForMetrics(out NewTracerCore core)
        {
            //TODO: implement configuring Depth Counter

            /*QCTraceSimulatorConfiguration traceSimCfg = new QCTraceSimulatorConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CNOT] = 1;*/
            return NewTracerCore.DefaultTracer(out core);
        }

        [Fact]
        public void ThreeCNOTs()
        {
            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore tracerCore);
            GetTest<ThreeCNOTsTest>(sim)();

            var results = tracerCore.ExtractCurrentResults();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, results.GetOperationMetric<ThreeCNOTsTest>(metric));
            }
            AssertEqualMetric(3, DepthCounter.Metrics.Depth);
            AssertEqualMetric(3, PrimitiveOperationsGroupsNames.CNOT);
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);

            string csvRes = results.ToCSV();
            output.WriteLine($"Result are:");
            output.WriteLine(csvRes);
        }

        [Fact]
        public void TwoCNOTs()
        {
            SimulatorBase sim = GetTraceSimForMetrics(out NewTracerCore core);
            GetTest<TwoCNOTsTest>(sim)();
            var results = core.ExtractCurrentResults();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, results.GetOperationMetric<TwoCNOTsTest>(metric));
            }
            AssertEqualMetric(2, DepthCounter.Metrics.Depth);
            AssertEqualMetric(2, PrimitiveOperationsGroupsNames.CNOT);
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);
        }
    }
}
