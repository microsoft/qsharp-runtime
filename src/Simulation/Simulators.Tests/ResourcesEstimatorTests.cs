﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Data;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class ResourcesEstimatorTests
    {
        /// <summary>
        /// Check the parameters of the suggested config, just to track changes.
        /// </summary>
        [Fact]
        public void RecommendedConfigTest()
        {
            var actual = ResourcesEstimator.RecommendedConfig();

            Assert.Equal(1u, actual.CallStackDepthLimit);

            // This disabled by default:
            Assert.False(actual.ThrowOnUnconstrainedMeasurement);
            Assert.False(actual.UseDistinctInputsChecker);
            Assert.False(actual.UseInvalidatedQubitsUseChecker);

            // Counters that we're expecting:
            Assert.True(actual.UsePrimitiveOperationsCounter);
            Assert.True(actual.UseDepthCounter);
            Assert.True(actual.UseWidthCounter);
        }

        /// <summary>
        /// Verifies that the statistics configured in the ResourcesEstimator
        /// matches what the Results method expects.
        /// </summary>
        [Fact]
        public void VerifyCollectorsTest()
        {
            var sim = new ResourcesEstimator();

            foreach(var l in sim.CoreConfig.Listeners)
            {
                // All listeners we expected are ICallGraphStatistics
                var collector = l as ICallGraphStatistics;
                Assert.NotNull(collector);

                // We expect all of them to have the Moment (with Sum)
                var stats = collector.Results.GetStatisticsNamesCopy();
                var expected = new MomentsStatistic().GetStatisticsNames();
                foreach (var n in expected)
                {
                    Assert.Contains(n, stats);
                }
            }
        }


        /// <summary>
        /// Verifies that the statistics configured in the ResourcesEstimator
        /// matches what the Results method expects.
        /// </summary>
        [Fact]
        public void VerifyDataTest()
        {
            var sim = new ResourcesEstimator();

            VerySimpleEstimate.Run(sim).Wait();
            var data = sim.Data;

            Assert.Equal(1.0, data.Rows.Find("CNOT")["Sum"]);
            Assert.Equal(0.0, data.Rows.Find("R")["Sum"]);
            Assert.Equal(2.0, data.Rows.Find("QubitClifford")["Sum"]);
            Assert.Equal(3.0, data.Rows.Find("Width")["Sum"]);
        }

        /// <summary>
        /// Verifies the calls ToCSV returns a non-empty string.
        /// </summary>
        [Fact]
        public void ToTSVTest()
        {
            var sim = new ResourcesEstimator();

            VerySimpleEstimate.Run(sim).Wait();
            var data = sim.ToTSV();
            Console.WriteLine(data);

            Assert.NotNull(data);
            var rows = data.Split('\n');
            Assert.Equal(9, rows.Length);

            var cols = rows[0].Split('\t');
            Assert.Equal("Metric", cols[0].Trim());
            Assert.Equal(3, cols.Length);

            var cliffords = rows.First(r => r.StartsWith("QubitClifford")).Split('\t');
            Assert.Equal(3, cliffords.Length);
            Assert.Equal("2", cliffords[1]);
        }

        /// <summary>
        /// Shows that T gates on different qubits are counted for depth purposes as 
        /// executing in parallel.
        /// </summary>
        [Fact]
        public void DepthDifferentQubitsTest()
        {
            var sim = new ResourcesEstimator();

            // using(q = Qubit[3]) { T(q[0]); T(q[1]); T(q[3]); T(q[0]); }
            DepthDifferentQubits.Run(sim).Wait();
            var data = sim.Data;

            Assert.Equal(4.0, data.Rows.Find("T")["Sum"]);
            Assert.Equal(3.0, data.Rows.Find("Width")["Sum"]);
            Assert.Equal(2.0, data.Rows.Find("Depth")["Sum"]);
        }

        /// <summary>
        /// Documents that the width and depth statistics reflect independent lower
        /// bounds for each (two T gates cannot be combined into a circuit of depth
        /// one and width one).
        /// </summary>
        [Fact]
        public void DepthVersusWidthTest()
        {
            var sim = new ResourcesEstimator();

            // using(q = Qubit()) { T(q); } using(q = Qubit()) { T(q); } (yes, twice)
            DepthVersusWidth.Run(sim).Wait();
            var data = sim.Data;

            Assert.Equal(2.0, data.Rows.Find("T")["Sum"]);
            Assert.Equal(1.0, data.Rows.Find("Width")["Sum"]);
            Assert.Equal(1.0, data.Rows.Find("Depth")["Sum"]);
        }

        /// <summary>
        /// Verifies that for multiple separately traced operations, the final
        /// statistics are cumulative.
        /// </summary>
        [Fact]
        public void VerifyTracingMultipleOperationsTest()
        {
            ResourcesEstimator sim = new ResourcesEstimator();

            Operation_1_of_2.Run(sim).Wait();
            DataTable data1 = sim.Data;

            Assert.Equal(1.0, data1.Rows.Find("CNOT")["Sum"]);
            Assert.Equal(1.0, data1.Rows.Find("QubitClifford")["Sum"]);
            Assert.Equal(1.0, data1.Rows.Find("T")["Sum"]);
            Assert.Equal(0.0, data1.Rows.Find("R")["Sum"]);
            Assert.Equal(0.0, data1.Rows.Find("Measure")["Sum"]);
            Assert.Equal(2.0, data1.Rows.Find("Width")["Sum"]);

            Operation_2_of_2.Run(sim).Wait();
            DataTable data2 = sim.Data;

            // Aggregated stats for both operations.
            Assert.Equal(1.0 + 2.0, data2.Rows.Find("CNOT")["Sum"]);
            Assert.Equal(1.0 + 1.0, data2.Rows.Find("QubitClifford")["Sum"]);
            Assert.Equal(1.0 + 0.0, data2.Rows.Find("T")["Sum"]);
            Assert.Equal(0.0 + 1.0, data2.Rows.Find("R")["Sum"]);
            Assert.Equal(0.0 + 1.0, data2.Rows.Find("Measure")["Sum"]);
            Assert.Equal(2.0 + 3.0, data2.Rows.Find("Width")["Sum"]);
            Assert.Equal(System.Math.Max(2.0, 3.0), data2.Rows.Find("Width")["Max"]);

            // Run again to confirm two operations isn't the limit!
            VerySimpleEstimate.Run(sim).Wait();
            DataTable data3 = sim.Data;
            Assert.Equal(2.0 + 3.0 + 3.0, data3.Rows.Find("Width")["Sum"]);
            Assert.Equal(3.0, data3.Rows.Find("Width")["Max"]);
        }
    }
}
