// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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
            Assert.Equal(2, cols.Length);

            var cliffords = rows.First(r => r.StartsWith("QubitClifford")).Split('\t');
            Assert.Equal(2, cliffords.Length);
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
    }
}
