// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
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
            NewTracerSim sim = new NewTracerSim( new NewTracerConfiguration() { UseDistinctInputsChecker = true } );
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCapturedTest>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured2Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured3Test>(sim));
            Assert.Throws<DistinctInputsCheckerException>(GetTest<DisctinctQubitCaptured4Test>(sim));
        }

        [Fact]
        public void UseReleasedQubitsTests()
        {
            NewTracerSim sim = new NewTracerSim(new NewTracerConfiguration() { UseInvalidatedQubitsUseChecker = true });
            Assert.Throws<InvalidatedQubitsUseCheckerException>(GetTest<UseReleasedQubitTest>(sim));
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


        //TODO: discuss if force measure is necessary    
        [Fact(Skip = "operation not implemented")]
        public void ForcedMeasuremenet()
        {
            //var sim = GetTraceSimForMetrics();
            //GetTest<ForcedMeasurementTest>(sim)();
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
            //double HTime = 1;

            NewTracerConfiguration traceSimCfg = new NewTracerConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CZ] = CXTime;
           // traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.QubitClifford] = HTime;

            NewTracerSim traceSim = new NewTracerSim(traceSimCfg);

            output.WriteLine(string.Empty);
            output.WriteLine($"Starting cat state preparation on {1u << powerOfTwo} qubits");
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            traceSim.Run<TCatState, long, QVoid>(powerOfTwo).Wait();
            stopwatch.Stop();

            double czCount = traceSim.GetOperationMetric<TCatState>(PrimitiveOperationsGroups.CZ.ToString());
            Assert.Equal( (1 << powerOfTwo) - 1, (long) czCount);

            double depth = traceSim.GetOperationMetric<TCatState>(DepthCounter.Metrics.Depth );
            Assert.Equal(powerOfTwo * CXTime, depth);

            void AssertEqualMetric( double value, string metric )
            {
                Assert.Equal(value, traceSim.GetOperationMetric<TCatState>(metric));
            }

            AssertEqualMetric(1u << powerOfTwo, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.BorrowedWith);
            AssertEqualMetric(0, WidthCounter.Metrics.InputWidth);
            AssertEqualMetric(0, WidthCounter.Metrics.ReturnWidth);

            output.WriteLine($"Calculation of metrics took: {stopwatch.ElapsedMilliseconds} ms");
            output.WriteLine($"The depth is: {depth} given depth of CNOT was {CXTime}");
            output.WriteLine($"Number of CNOTs used is {czCount}");
        }

        NewTracerSim GetTraceSimForMetrics()
        {
            NewTracerConfiguration traceSimCfg = new NewTracerConfiguration();
            traceSimCfg.UsePrimitiveOperationsCounter = true;
            traceSimCfg.UseDepthCounter = true;
            traceSimCfg.UseWidthCounter = true;
            traceSimCfg.TraceGateTimes[PrimitiveOperationsGroups.CZ] = 1;
            return new NewTracerSim(traceSimCfg);
        }

        [Fact]
        public void ThreeCNOTs()
        {
            NewTracerSim sim = GetTraceSimForMetrics();
            GetTest<ThreeCNOTsTest>(sim)();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, sim.GetOperationMetric<ThreeCNOTsTest>(metric));
            }
            AssertEqualMetric(3, DepthCounter.Metrics.Depth);
            AssertEqualMetric(3, PrimitiveOperationsGroups.CZ.ToString());
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
            NewTracerSim sim = GetTraceSimForMetrics();
            GetTest<TwoCNOTsTest>(sim)();

            void AssertEqualMetric(double value, string metric)
            {
                Assert.Equal(value, sim.GetOperationMetric<TwoCNOTsTest>(metric));
            }
            AssertEqualMetric(2, DepthCounter.Metrics.Depth);
            AssertEqualMetric(2, PrimitiveOperationsGroups.CZ.ToString());
            AssertEqualMetric(3, WidthCounter.Metrics.ExtraWidth);
            AssertEqualMetric(0, DepthCounter.Metrics.StartTimeDifference);
        }

    }
}
