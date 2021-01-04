// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using System;
using System.Diagnostics;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests
{
    public class PrimitiveOperationsCounterExamples
    {
        private readonly ITestOutputHelper output;
        public PrimitiveOperationsCounterExamples(ITestOutputHelper output)
        {
            this.output = output;
        }

        [Fact]
        void CCNOTGateCountExample()
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            QCTraceSimulator sim = new QCTraceSimulator(config);
            QVoid res;
            res = CCNOTDriver.Run(sim).Result;
            res = CCNOTDriver.Run(sim).Result;

            double tCount = sim.GetMetric<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.T);
            double tCountAll = sim.GetMetric<CCNOTDriver>(PrimitiveOperationsGroupsNames.T);

            double cxCount = sim.GetMetric<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.CNOT);

            string csvSummary = sim.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];

            // above code is an example used in the documentation

            Assert.Equal( 7.0, sim.GetMetricStatistic<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
            Assert.Equal( 7.0, tCount );
            Assert.Equal( 8.0, sim.GetMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
            Assert.Equal( 0.0, sim.GetMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal( 8.0, tCountAll );            
            Assert.Equal(10.0, cxCount);
            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }

        [Fact]
        void TCountTest()
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            config.CallStackDepthLimit = 2;
            QCTraceSimulator sim = new QCTraceSimulator(config);
            var res = TCountOneGatesTest.Run(sim).Result;
            var res2 = TCountZeroGatesTest.Run(sim).Result;
            var tcount = PrimitiveOperationsGroupsNames.T;
            string csvSummary = sim.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];
            output.WriteLine(csvSummary);

            Assert.Equal(Double.NaN, sim.GetMetricStatistic<Intrinsic.T, TCountOneGatesTest>(
                PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal(1, sim.GetMetric<Intrinsic.T, TCountOneGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(1, sim.GetMetric<Intrinsic.T, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetMetric<Intrinsic.RFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetMetric<Intrinsic.ExpFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetMetric<Intrinsic.R1Frac, TCountOneGatesTest>(tcount));

            Assert.Equal(0, sim.GetMetric<Intrinsic.S, TCountZeroGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(0, sim.GetMetric<Intrinsic.S, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetMetric<Intrinsic.RFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetMetric<Intrinsic.ExpFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetMetric<Intrinsic.R1Frac, TCountZeroGatesTest>(tcount));
        }

        [Fact]
        void TDepthTest()
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 1;
            QCTraceSimulator sim = new QCTraceSimulator(config);
            var res = TDepthOne.Run(sim).Result;
            string csvSummary = sim.ToCSV()[MetricsCountersNames.depthCounter];
            Assert.Equal(1, sim.GetMetric<TDepthOne>(MetricsNames.DepthCounter.Depth));
        }

        [Fact]
        void CCNOTDepthCountExample()
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 2;
            QCTraceSimulator sim = new QCTraceSimulator( config);
            var res = CCNOTDriver.Run(sim).Result;

            double tDepth = sim.GetMetric<Intrinsic.CCNOT, CCNOTDriver>(MetricsNames.DepthCounter.Depth);
            double tDepthAll = sim.GetMetric<CCNOTDriver>(MetricsNames.DepthCounter.Depth);

            string csvSummary = sim.ToCSV()[MetricsCountersNames.depthCounter];

            // above code is an example used in the documentation

            Assert.Equal(5.0, tDepth);
            Assert.Equal(6.0, tDepthAll);

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }

        [Fact]
        void MultiControilledXWidthExample()
        {
            var config = new QCTraceSimulatorConfiguration();
            config.UseWidthCounter = true;
            config.CallStackDepthLimit = 2;
            var sim = new QCTraceSimulator( config);
            int totalNumberOfQubits = 5;
            var res = MultiControlledXDriver.Run(sim, totalNumberOfQubits).Result;

            double allocatedQubits = 
                sim.GetMetric<Intrinsic.X, MultiControlledXDriver>(
                    MetricsNames.WidthCounter.ExtraWidth,
                    functor: OperationFunctor.Controlled); 

            double inputWidth =
                sim.GetMetric<Intrinsic.X, MultiControlledXDriver>(
                    MetricsNames.WidthCounter.InputWidth,
                    functor: OperationFunctor.Controlled);

            string csvSummary = sim.ToCSV()[MetricsCountersNames.widthCounter];

            // above code is an example used in the documentation

            Assert.Equal( totalNumberOfQubits, inputWidth);
            Assert.Equal( totalNumberOfQubits - 3, allocatedQubits);

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }
    }
}
