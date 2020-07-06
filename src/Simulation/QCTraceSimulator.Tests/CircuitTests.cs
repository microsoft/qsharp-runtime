// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using NewTracer;
using NewTracer.MetricCollectors;
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
            //TODO: configuration
            var distinctChecker = new NewTracer.MetricCollectors.DistinctInputsChecker(true);
            var sim = NewTracerCore.CreateTracer(new[] { distinctChecker }, true, out _);
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCapturedTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured2Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured3Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured4Test>(sim));
        }

        [Fact]
        public void UseReleasedQubitsTests()
        {
            var invalidatedChecker = new InvalidatedQubitUseChecker(true);
            var sim = NewTracerCore.CreateTracer(new[] { invalidatedChecker }, true, out _);
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

            //TODO: define metric constants
            double cxCount = tracerCore.GetOperationMetric<TCatState>("CZ");
            Assert.Equal( (1 << powerOfTwo) - 1, (long) cxCount);

            double depth = tracerCore.GetOperationMetric<TCatState>(DepthCounter.Metrics.Depth );
            Assert.Equal(HTime + powerOfTwo * CXTime, depth);

            void AssertEqualMetric( double value, string metric )
            {
                Assert.Equal(value, tracerCore.GetOperationMetric<TCatState>(metric));
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
            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, tracerCore.GetOperationMetric<ThreeCNOTsTest>(metric));
            }
            //TODO: define metric constants
            AssertEqualMetric(3, DepthCounter.Metrics.Depth);
            AssertEqualMetric(3, "CZ");
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);

            Dictionary<string, string> csvRes = tracerCore.ToCSV();
            foreach (KeyValuePair<string, string> kv in csvRes)
            {
                output.WriteLine($"Result of running {kv.Key} are:");
                output.WriteLine(kv.Value);
            }
        }

        [Fact]
        public void TwoCNOTs()
        {
            SimulatorBase sim = GetTraceSimForMetrics(out NewTracerCore core);
            GetTest<TwoCNOTsTest>(sim)();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, core.GetOperationMetric<TwoCNOTsTest>(metric));
            }
            AssertEqualMetric(2, DepthCounter.Metrics.Depth);
            AssertEqualMetric(2, "CZ");
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);
        }
    }
}
