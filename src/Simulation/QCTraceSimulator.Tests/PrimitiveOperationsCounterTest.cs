// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
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
        void MultiControlledXGateCountTest()
        {
            var config = new NewTracerConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            var sim = new TracerSimulator(config);

            int numControls = 3;
            QVoid res;
            res = MultiControlledXDriver.Run(sim, numControls + 1).Result;

            string csvSummary = sim.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];
            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);


            Assert.Equal(2.0, sim.GetMetric("CCZ"), 3);
            //TODO: non-deterministic! either 1 or 0 depending on measurement of aux qubit
            Assert.Equal(1.0, sim.GetMetric("CZ"), 3);
        }

        //TODO: re-enable after fixing op lookup bug
        [Fact (Skip ="Old Decomposition")]
        void CCNOTGateCountExample()
        {
            var config = new QCTraceSimConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            var sim = new TracerSimulator(config);

            QVoid res;
            res = CCNOTDriver.Run(sim).Result;
            res = CCNOTDriver.Run(sim).Result;

            string csvSummary = sim.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);

            
            double tCount = sim.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.T);
            double tCountAll = sim.GetOperationMetric<CCNOTDriver>(PrimitiveOperationsGroupsNames.T);

            double cxCount = sim.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>("CNOT");

            // above code is an example used in the documentation

            Assert.Equal( 7.0, sim.GetAggregateEdgeMetricStatistic<Intrinsic.CCNOT, CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
            Assert.Equal( 7.0, tCount );
            Assert.Equal( 8.0, sim.GetOperationMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Average));
            //TODO: not implemented
            //Assert.Equal( 0.0, sim.GetOperationMetricStatistic<CCNOTDriver>(PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal( 8.0, tCountAll );            
            Assert.Equal(10.0, cxCount);
            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
            
        }

        [Fact]
        void TCountTest()
        {
            var config = new NewTracerConfiguration();
            config.UsePrimitiveOperationsCounter = true;
            config.CallStackDepthLimit = 2;
            var sim = new TracerSimulator(config);
            var res = TCountOneGatesTest.Run(sim).Result;
            var res2 = TCountZeroGatesTest.Run(sim).Result;
            var tcount = PrimitiveOperationsGroupsNames.T;
            string csvSummary = sim.ToCSV()[MetricsCountersNames.primitiveOperationsCounter];
            output.WriteLine(csvSummary);

            //TODO: not implemented
            //Assert.Equal(Double.NaN, sim.GetAggregateEdgeMetricStatistic<Intrinsic.T, TCountOneGatesTest>(
            //    PrimitiveOperationsGroupsNames.T, MomentsStatistic.Statistics.Variance));
            Assert.Equal(1, sim.GetAggregateEdgeMetric<Intrinsic.T, TCountOneGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(1, sim.GetAggregateEdgeMetric<Intrinsic.T, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetAggregateEdgeMetric<Intrinsic.RFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetAggregateEdgeMetric<Intrinsic.ExpFrac, TCountOneGatesTest>(tcount));
            Assert.Equal(1, sim.GetAggregateEdgeMetric<Intrinsic.R1Frac, TCountOneGatesTest>(tcount));

            Assert.Equal(0, sim.GetAggregateEdgeMetric<Intrinsic.S, TCountZeroGatesTest>(tcount,
                functor: OperationFunctor.Adjoint));
            Assert.Equal(0, sim.GetAggregateEdgeMetric<Intrinsic.S, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetAggregateEdgeMetric<Intrinsic.RFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetAggregateEdgeMetric<Intrinsic.ExpFrac, TCountZeroGatesTest>(tcount));
            Assert.Equal(0, sim.GetAggregateEdgeMetric<Intrinsic.R1Frac, TCountZeroGatesTest>(tcount));
        }

        [Fact]
        void TDepthTest()
        {
            var config = new NewTracerConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 1;
            var sim = new TracerSimulator(config);
            var res = TDepthOne.Run(sim).Result;
            string csvSummary = sim.ToCSV()[MetricsCountersNames.depthCounter];
            Assert.Equal(1, sim.GetOperationMetric<TDepthOne>(MetricsNames.DepthCounter.Depth));
        }

        //TODO: re-enable after fixing op lookup bug
        [Fact(Skip = "Old Decomposition")]
        void CCNOTDepthCountExample()
        {
            var config = new NewTracerConfiguration();
            config.UseDepthCounter = true;
            config.CallStackDepthLimit = 2;
            var sim = new TracerSimulator(config);
            var res = CCNOTDriver.Run(sim).Result;

            double tDepth = sim.GetAggregateEdgeMetric<Intrinsic.CCNOT, CCNOTDriver>(MetricsNames.DepthCounter.Depth);
            double tDepthAll = sim.GetOperationMetric<CCNOTDriver>(MetricsNames.DepthCounter.Depth);

            string csvSummary = sim.ToCSV()[MetricsCountersNames.depthCounter];

            // above code is an example used in the documentation

            Assert.Equal(5.0, tDepth);
            Assert.Equal(6.0, tDepthAll);

            Debug.WriteLine(csvSummary);
            output.WriteLine(csvSummary);
        }

        [Fact]
        void MultiControlledXWidthExample()
        {
            var config = new NewTracerConfiguration();
            config.UseWidthCounter = true;
            config.CallStackDepthLimit = 2;
            var sim = new TracerSimulator(config);
            int totalNumberOfQubits = 5;
            var res = MultiControlledXDriver.Run(sim, totalNumberOfQubits).Result;

            double allocatedQubits = 
                sim.GetAggregateEdgeMetric<Intrinsic.X, MultiControlledXDriver>(
                    MetricsNames.WidthCounter.ExtraWidth,
                    functor: OperationFunctor.Controlled); 

            double inputWidth =
                sim.GetAggregateEdgeMetric<Intrinsic.X, MultiControlledXDriver>(
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
