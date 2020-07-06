// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using NewTracer;
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
            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore core);
            var res = CCNOTDriver.Run(sim).Result;

            double tCount = core.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>("T");
            double tCountAll = core.GetOperationMetric<CCNOTDriver>(PrimitiveOperationsGroupsNames.T);

            double cxCount = core.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>("CZ");

            string csvSummary = core.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];

            // above code is an example used in the documentation

            Assert.Equal( 7.0, core.GetAggregateEdgeMetricStatistic<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
            Assert.Equal( 7.0, tCount );
            Assert.Equal( 8.0, core.GetOperationMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
           //TODO: implement variance
            // Assert.Equal( 0.0, core.GetOperationMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal( 8.0, tCountAll );            
            Assert.Equal(10.0, cxCount);
            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }

        //TODO: do we need a call stack depth limit for these like in old tests?

        [Fact]
        void TCountTest()
        {
            /*var config = new QCTraceSimulatorConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            config.CallStackDepthLimit = 2;
            QCTraceSimulator sim = new QCTraceSimulator(config);*/

            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore core);

            var res = TCountOneGatesTest.Run(sim).Result;
            var res2 = TCountZeroGatesTest.Run(sim).Result;
            var tcount = PrimitiveOperationsGroupsNames.T;


            string csvSummary = core.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];
            output.WriteLine(csvSummary);

            //TODO: implement variance
            //Assert.Equal(Double.NaN, core.GetAggregateEdgeMetricStatistic<Intrinsic.T, TCountOneGatesTest>(
             //   PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal(1, core.GetAggregateEdgeMetric<Intrinsic.T, TCountOneGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(1, core.GetAggregateEdgeMetric<Intrinsic.T, TCountOneGatesTest>(tcount));
            Assert.Equal(1, core.GetAggregateEdgeMetric<Intrinsic.RFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, core.GetAggregateEdgeMetric<Intrinsic.ExpFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, core.GetAggregateEdgeMetric<Intrinsic.R1Frac, TCountOneGatesTest>(tcount));

            Assert.Equal(0, core.GetAggregateEdgeMetric<Intrinsic.S, TCountZeroGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(0, core.GetAggregateEdgeMetric<Intrinsic.S, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, core.GetAggregateEdgeMetric<Intrinsic.RFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, core.GetAggregateEdgeMetric<Intrinsic.ExpFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, core.GetAggregateEdgeMetric<Intrinsic.R1Frac, TCountZeroGatesTest>(tcount));
        }

        [Fact]
        void TDepthTest()
        {
            /*var config = new QCTraceSimulatorConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 1;
            QCTraceSimulator sim = new QCTraceSimulator(config);*/

            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore core);

            var res = TDepthOne.Run(sim).Result;

            string csvSummary = core.ToCSV()[MetricsCountersNames.depthCounter];
            Assert.Equal(1, core.GetOperationMetric<TDepthOne>(MetricsNames.DepthCounter.Depth));
        }

        [Fact]
        void CCNOTDepthCountExample()
        {
            /*var config = new QCTraceSimulatorConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 2;
            QCTraceSimulator sim = new QCTraceSimulator(config);*/
            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore core);

            var res = CCNOTDriver.Run(sim).Result;

            double tDepth = core.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>(MetricsNames.DepthCounter.Depth);
            double tDepthAll = core.GetOperationMetric<CCNOTDriver>(MetricsNames.DepthCounter.Depth);

            string csvSummary = core.ToCSV()[MetricsCountersNames.depthCounter];

            // above code is an example used in the documentation

            Assert.Equal(5.0, tDepth);
            Assert.Equal(6.0, tDepthAll);

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }

        [Fact]
        void MultiControilledXWidthExample()
        {
            /*var config = new QCTraceSimulatorConfiguration();
            config.UseWidthCounter = true;
            config.CallStackDepthLimit = 2;
            var sim = new QCTraceSimulator(config);*/

            SimulatorBase sim = NewTracerCore.DefaultTracer(out NewTracerCore core);

            int totalNumberOfQubits = 5;
            var res = MultiControlledXDriver.Run(sim, totalNumberOfQubits).Result;

            double allocatedQubits =
                core.GetAggregateEdgeMetric<Intrinsic.X, MultiControlledXDriver>(
                    MetricsNames.WidthCounter.ExtraWidth,
                    functor: OperationFunctor.Controlled); 

            double inputWidth =
                core.GetAggregateEdgeMetric<Intrinsic.X, MultiControlledXDriver>(
                    MetricsNames.WidthCounter.InputWidth,
                    functor: OperationFunctor.Controlled);

            string csvSummary = core.ToCSV()[MetricsCountersNames.widthCounter];

            // above code is an example used in the documentation

            Assert.Equal( totalNumberOfQubits, inputWidth);
            Assert.Equal( totalNumberOfQubits - 3, allocatedQubits);

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }
    }
}
